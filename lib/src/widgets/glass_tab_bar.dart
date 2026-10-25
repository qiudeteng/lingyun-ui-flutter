import 'dart:math' as math;

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/liquid_glass_theme.dart';
import '../tokens/liquid_glass_labels.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import '../tokens/liquid_glass_tokens.dart';
import 'glass_surface.dart';

/// How [GlassTabBar] is arranged.
///
/// Sketch UI Kit page 「Tab Bars」 (iPhone) is a floating capsule. [standard]
/// is the full-width, edge-to-bottom bar. [sidebar] is a vertical Dock rail
/// the Flutter page shell can place on regular / wide widths. It is not
/// iOS 27.1 vertical system chrome.
enum GlassTabBarStyle {
  /// Full-width bar, flush to the bottom edge. Icon + caption sit above the
  /// Home Indicator inset.
  standard,

  /// Floating Liquid Glass capsule. Width follows the kit group widths
  /// (3 → 266, 4 and 5 share the 352 cap on a 402pt board).
  floatingPill,

  /// Vertical Liquid Glass Dock rail (icon + caption column).
  ///
  /// The Flutter page shell uses this on regular and wide widths. It does
  /// not replicate the iOS 27.1 vertical system Toolbar / Tab Bar.
  ///
  /// Not the formal Materials Thick sidebar. That column is a separate
  /// widget and stays Thick. This rail stays Liquid Glass Dock, including
  /// when a Flutter demo moves it between the bottom tab and the rail.
  /// The system Tab-to-Sidebar fluid transition lives in UIKit (`ios/`).
  sidebar,
}

/// One destination in a [GlassTabBar].
///
/// The glyph is an icon; the caption is [label] (Caption, not Body).
@immutable
class GlassTabBarItem {
  const GlassTabBarItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.enabled = true,
  });

  final IconData icon;

  /// Drawn when this item is the selected index. Falls back to [icon].
  final IconData? selectedIcon;

  /// Caption under the icon. Not a Body label.
  final String label;

  /// Badge text, for example `'3'`.
  ///
  /// `null` hides the badge. An empty string draws a dot.
  final String? badge;

  /// Disabled items stay visible at reduced contrast and do not call
  /// [GlassTabBar.onChanged].
  final bool enabled;
}

/// iOS 27 **Liquid Glass** tab bar.
///
/// Chrome is [LiquidGlassStyle] — default [LiquidGlassStyle.dock] — drawn
/// by [GlassSurface]. It is **not** a Materials tier and it does not use
/// toolbar materials. The rim is the shared ~0.5px hairline plus the same
/// specular stack as [GlassButton].
///
/// Selection is a System Blue tint on the icon and caption
/// ([systemBlueLight] / [systemBlueDark], the kit Tint). Unselected items
/// use [LiquidGlassLabels] at [unselectedOpacity]. There is no Material
/// indicator bar. The selected slot is a darker glass lens nested in the
/// Dock platter: a sheer dark veil, a thin edge catch, and a faint
/// caustic, so the platter and the backdrop stay visible. It is not a
/// white capsule and it is not a second
/// [GlassSurface]: a nested blur would stack glass on glass. The lens
/// stretches while it travels, then settles into a capsule. A drag lags
/// behind the finger; release selects the item under the pointer and
/// settles. Press lifts the glyph and lights the lens from within.
///
/// The spring reuses [LiquidGlassMotion.quick] as a time base
/// ([SpringDescription.withDurationAndBounce], bounce left at the API
/// default). Apple has not published tab-lens ω/ζ (WWDC25 219). Stretch,
/// lift, and distance scaling are provisional — 待核验 vs 真机/Sketch —
/// and are not [LiquidGlassMotion] tokens.
///
/// [tintedBar] fills the whole platter with [tint] (System Blue by default)
/// and draws white icons.
///
/// The floating capsule uses a stadium radius (`BorderRadius.circular(100)`,
/// kit `cornerRadius: 100`), not the unverified 18 / 26 / 34 steps.
/// `blurSigma` / `saturation` stay implementation approximations inside the
/// Dock tokens.
///
/// [GlassTabBarStyle.sidebar] is the Flutter glass rail. iOS 27.1 vertical
/// system chrome stays on the native track.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.style = GlassTabBarStyle.floatingPill,
    this.glassStyle = LiquidGlassStyle.dock,
    this.tint,
    this.brightness,
    this.tintedBar = false,
  });

  /// Kit Tint on the Tab Bars page — System Blue, light.
  static const Color systemBlueLight = Color(0xFF0088FF);

  /// Kit Tint on the Tab Bars page — System Blue, dark.
  static const Color systemBlueDark = Color(0xFF0091FF);

  /// Unselected icon/caption opacity on [LiquidGlassLabels] primary.
  ///
  /// Approximates the kit LINEAR_BURN / LINEAR_DODGE mix so unselected
  /// glyphs stay near Primary (`#1A1A1A` / `#EDEDED`) instead of a mid
  /// grey. Not a published percentage, not a selected color.
  static const double unselectedOpacity = 0.92;

  /// Unselected icon/caption opacity when [tintedBar] is on.
  static const double tintedUnselectedOpacity = 0.72;

  /// Disabled items are multiplied by this opacity.
  static const double disabledOpacity = 0.38;

  final List<GlassTabBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  /// [GlassTabBarStyle.standard], [GlassTabBarStyle.floatingPill], or the
  /// vertical Dock rail [GlassTabBarStyle.sidebar].
  final GlassTabBarStyle style;

  /// Liquid Glass recipe for the platter. Default is Dock.
  ///
  /// Not a [MaterialTier]. Materials Thick is sheet / sidebar chrome.
  final LiquidGlassStyle glassStyle;

  /// Selected tint, and the platter fill when [tintedBar] is true.
  ///
  /// Null uses [systemBlueFor].
  final Color? tint;

  /// Overrides [ThemeData.brightness] for this bar only (labels + glass).
  final Brightness? brightness;

  /// Active / Tinted whole-bar variant: System Blue (or [tint]) fill and
  /// white icons. The platter is still Liquid Glass, not a flat Material
  /// banner.
  final bool tintedBar;

  static Color systemBlueFor(Brightness brightness) {
    return brightness == Brightness.dark ? systemBlueDark : systemBlueLight;
  }

  @override
  Widget build(BuildContext context) {
    assert(items.isNotEmpty, 'GlassTabBar.items must not be empty.');
    assert(
      currentIndex >= 0 && currentIndex < items.length,
      'GlassTabBar.currentIndex ($currentIndex) is outside items '
      '(${items.length}).',
    );

    final bar = Builder(builder: (context) => _GlassTabBarBody(bar: this));
    final override = brightness;
    if (override == null) return bar;

    final theme = Theme.of(context);
    final glass = override == Brightness.dark
        ? LiquidGlassTheme.dark
        : LiquidGlassTheme.light;
    return Theme(
      data: theme.copyWith(brightness: override, extensions: [glass]),
      child: bar,
    );
  }
}

/// Alias so call sites can say Liquid Glass by name.
typedef LiquidGlassTabBar = GlassTabBar;

class _GlassTabBarBody extends StatelessWidget {
  const _GlassTabBarBody({required this.bar});

  final GlassTabBar bar;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.brightnessOf(context);
    final tint = bar.tint ?? GlassTabBar.systemBlueFor(brightness);
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    final child = switch (bar.style) {
      GlassTabBarStyle.standard => _StandardPlatter(
        bar: bar,
        tint: tint,
        brightness: brightness,
        safeBottom: safeBottom,
      ),
      GlassTabBarStyle.floatingPill => _FloatingPlatter(
        bar: bar,
        tint: tint,
        brightness: brightness,
        safeBottom: safeBottom,
      ),
      GlassTabBarStyle.sidebar => _SidebarStub(
        bar: bar,
        tint: tint,
        brightness: brightness,
      ),
    };

    return Semantics(container: true, explicitChildNodes: true, child: child);
  }
}

/// Kit geometry for the iPhone Tab Bars page (402pt board, Minimized=False).
///
/// Widths are measured group widths, not Design Tokens. `blurSigma` is not
/// part of this geometry.
class _TabBarMetrics {
  const _TabBarMetrics._();

  static const double controlHeight = 54;
  static const double platterOutset = 4;
  static const double platterHeight = controlHeight + platterOutset * 2;
  static const double symbolSize = 18;
  static const double symbolBox = 28;
  static const double labelSize = 10;
  static const double itemGap = 4;

  /// Kit tab-button padding is 8. Kept greater than [itemGap].
  static const double itemPaddingH = 8;
  static const double floatingTopGap = 16;

  /// Content-group width on a 402pt board (kit Type=Default).
  ///
  /// 2 → 180, 3 → 266, 4 → 352, 5 → 352. Four and five items share the
  /// side-inset cap; the pill grows from 3 to that cap, then slots shrink.
  static double kitGroupWidth(int itemCount) {
    return switch (itemCount) {
      1 => 120.0,
      2 => 180.0,
      3 => 266.0,
      _ => 352.0,
    };
  }

  static double floatingContentWidth(int itemCount, double boardWidth) {
    final n = itemCount < 1 ? 1 : itemCount;
    final kit = kitGroupWidth(n);
    final board = boardWidth.isFinite && boardWidth > 0 ? boardWidth : 402.0;
    final scaled = board >= 402 ? kit : kit * board / 402.0;
    // 25pt side inset on the 402pt board (kit padding L/R for 4–5 tabs).
    final cap = math.max(96.0, board - 50);
    return math.min(scaled, cap);
  }

  /// Kit frame bottom padding is 25 when the home-indicator inset is 34,
  /// so the platter overlaps that inset by 9pt.
  static double floatingBottomGap(double safeBottom) {
    if (safeBottom <= 0) return 12;
    return math.max(8, safeBottom - 9);
  }
}

class _ItemLayout {
  const _ItemLayout({
    required this.groupWidth,
    required this.itemExtent,
    required this.itemGap,
    required this.count,
  });

  final double groupWidth;
  final double itemExtent;
  final double itemGap;
  final int count;

  double itemLeft(int index) => index * stride;

  double get stride => itemExtent + itemGap;

  /// Left edge of a fractional slot. RTL mirrors the row.
  double leftFor(double index, {required bool rtl}) {
    final ltr = index * stride;
    if (!rtl) return ltr;
    return groupWidth - ltr - itemExtent;
  }

  /// Slot index under [dx], 0 at the leading item. Clamped to the row.
  double indexForDx(double dx, {required bool rtl}) {
    if (count <= 1 || stride <= 0) return 0;
    final fromLeading = rtl ? groupWidth - dx : dx;
    final raw = (fromLeading - itemExtent / 2) / stride;
    return raw.clamp(0.0, count - 1.0);
  }

  static _ItemLayout even({
    required int count,
    required double groupWidth,
    required double gap,
  }) {
    final gaps = gap * (count - 1);
    final extent = count == 0 ? groupWidth : (groupWidth - gaps) / count;
    return _ItemLayout(
      groupWidth: groupWidth,
      itemExtent: extent,
      itemGap: gap,
      count: count,
    );
  }
}

class _StandardPlatter extends StatelessWidget {
  const _StandardPlatter({
    required this.bar,
    required this.tint,
    required this.brightness,
    required this.safeBottom,
  });

  final GlassTabBar bar;
  final Color tint;
  final Brightness brightness;
  final double safeBottom;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 402.0;
        final layout = _ItemLayout.even(
          count: bar.items.length,
          groupWidth: width,
          gap: 0,
        );
        return SizedBox(
          width: width,
          height: _TabBarMetrics.controlHeight + safeBottom,
          child: _Platter(
            bar: bar,
            tint: tint,
            brightness: brightness,
            layout: layout,
            borderRadius: BorderRadius.zero,
            width: width,
            height: _TabBarMetrics.controlHeight + safeBottom,
            padding: EdgeInsets.only(bottom: safeBottom),
          ),
        );
      },
    );
  }
}

class _FloatingPlatter extends StatelessWidget {
  const _FloatingPlatter({
    required this.bar,
    required this.tint,
    required this.brightness,
    required this.safeBottom,
  });

  final GlassTabBar bar;
  final Color tint;
  final Brightness brightness;
  final double safeBottom;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final board = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 402.0;
        final content = _TabBarMetrics.floatingContentWidth(
          bar.items.length,
          board,
        );
        final layout = _ItemLayout.even(
          count: bar.items.length,
          groupWidth: content,
          gap: _TabBarMetrics.itemGap,
        );
        final glassWidth = content + _TabBarMetrics.platterOutset * 2;
        return Padding(
          padding: EdgeInsets.only(
            top: _TabBarMetrics.floatingTopGap,
            bottom: _TabBarMetrics.floatingBottomGap(safeBottom),
          ),
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: _Platter(
              bar: bar,
              tint: tint,
              brightness: brightness,
              layout: layout,
              borderRadius: BorderRadius.circular(100),
              width: glassWidth,
              height: _TabBarMetrics.platterHeight,
              padding: const EdgeInsets.all(_TabBarMetrics.platterOutset),
            ),
          ),
        );
      },
    );
  }
}

class _Platter extends StatelessWidget {
  const _Platter({
    required this.bar,
    required this.tint,
    required this.brightness,
    required this.layout,
    required this.borderRadius,
    required this.width,
    required this.height,
    required this.padding,
  });

  final GlassTabBar bar;
  final Color tint;
  final Brightness brightness;
  final _ItemLayout layout;
  final BorderRadius borderRadius;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final base = LiquidGlassTheme.styleOf(context, bar.glassStyle);
    final tokens = bar.tintedBar ? _tintedTokens(base, tint) : base;
    return GlassSurface(
      tokens: tokens,
      borderRadius: borderRadius,
      width: width,
      height: height,
      padding: padding,
      child: _ItemRow(
        bar: bar,
        tint: tint,
        brightness: brightness,
        layout: layout,
      ),
    );
  }
}

LiquidGlassTokens _tintedTokens(LiquidGlassTokens base, Color tint) {
  return base.copyWith(
    tintColor: tint.withValues(alpha: 0.94),
    overlayColor: const Color(0x1FFFFFFF),
    overlayBlend: BlendMode.softLight,
    edgeHighlightColor: const Color(0x66FFFFFF),
    opaqueFallbackColor: tint,
  );
}

class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.bar,
    required this.tint,
    required this.brightness,
    required this.layout,
  });

  final GlassTabBar bar;
  final Color tint;
  final Brightness brightness;
  final _ItemLayout layout;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

/// Provisional lens motion. Not a [LiquidGlassMotion] token.
///
/// WWDC25 219 describes the tab lens as gel that follows the finger and
/// settles, without publishing ω/ζ. The simulation is
/// [SpringDescription.withDurationAndBounce] on the existing
/// [LiquidGlassMotion.quick] duration; bounce stays at that API's default
/// (0). Farther settles stretch that duration. Drag retargets the same
/// spring so the lens lags. Release injects a capped finger velocity.
///
/// Magnitudes below are geometry, not stiffness.
/// 待核验 vs 真机/Sketch.
class _LensMotion {
  const _LensMotion._();

  static const double pressLift = 1.14;
  static const Offset pressSlide = Offset(0, -0.08);
  static const double lensPressScale = 1.08;
  static const double pulseAmp = 0.055;
  static const double travelStretch = 0.30;
  static const double speedStretch = 0.028;
  static const double maxStretch = 0.58;
  static const double squash = 0.12;
  static const double maxLeadPx = 14;
  static const double leadPerSlot = 2.4;
  static const double maxReleaseSlotsPerSecond = 4;

  /// Farther than a neighbor takes longer. Base is [LiquidGlassMotion.quick].
  static Duration settleDuration(double slots) {
    final scale = (0.7 + 0.4 * slots).clamp(0.7, 2.4);
    final ms = LiquidGlassMotion.defaults.quick.inMilliseconds * scale;
    return Duration(milliseconds: math.max(1, ms.round()));
  }

  static double capVelocity(double slotsPerSecond) {
    return slotsPerSecond.clamp(
      -maxReleaseSlotsPerSecond,
      maxReleaseSlotsPerSecond,
    );
  }
}

class _IndexSample {
  const _IndexSample(this.time, this.index);

  final Duration time;
  final double index;
}

/// Index-space spring for the selection lens.
///
/// Reduce Motion writes the target immediately (WWDC25 219 drops
/// elasticity; [LiquidGlassMotion.durationOf] is the same zero-duration
/// path). No new token.
class _LensDriver {
  _LensDriver({required TickerProvider vsync, required double index})
    : _controller = AnimationController.unbounded(vsync: vsync, value: index),
      _target = index;

  final AnimationController _controller;
  double _target;
  bool reduceMotion = false;

  Listenable get listenable => _controller;
  double get position => _controller.value;
  double get velocity => _controller.velocity;
  double get target => _target;

  void go(double target, {double? velocity, required bool distanceScaled}) {
    final previous = _target;
    _target = target;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = target;
      return;
    }
    final sameTarget =
        (target - previous).abs() < 1e-4 &&
        (target - _controller.value).abs() < 1e-3 &&
        velocity == null;
    if (sameTarget) return;

    final from = _controller.value;
    final duration = distanceScaled
        ? _LensMotion.settleDuration((target - from).abs())
        : LiquidGlassMotion.defaults.quick;
    _controller.animateWith(
      SpringSimulation(
        SpringDescription.withDurationAndBounce(duration: duration),
        from,
        target,
        velocity ?? _controller.velocity,
        snapToEnd: true,
      ),
    );
  }

  void dispose() => _controller.dispose();
}

class _LensFrame {
  const _LensFrame({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class _ItemRowState extends State<_ItemRow> with TickerProviderStateMixin {
  late final _LensDriver _lens;
  late final AnimationController _pulse;
  final List<_IndexSample> _trail = [];

  int? _pointer;
  int? _pressedIndex;
  bool _interacting = false;
  bool _claimedDrag = false;
  Offset? _downLocal;
  int? _pendingCommit;

  @override
  void initState() {
    super.initState();
    _lens = _LensDriver(vsync: this, index: widget.bar.currentIndex.toDouble());
    _pulse = AnimationController(
      vsync: this,
      duration: LiquidGlassMotion.defaults.quick,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = LiquidGlassMotion.reduceMotionOf(context);
    final flipped = _lens.reduceMotion != reduce;
    _lens.reduceMotion = reduce;
    if (reduce && flipped && !_interacting) {
      _lens.go(widget.bar.currentIndex.toDouble(), distanceScaled: false);
    }
  }

  @override
  void didUpdateWidget(covariant _ItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _lens.reduceMotion = LiquidGlassMotion.reduceMotionOf(context);
    if (_pendingCommit != null && widget.bar.currentIndex == _pendingCommit) {
      _pendingCommit = null;
    }
    if (_interacting) return;
    final indexChanged = oldWidget.bar.currentIndex != widget.bar.currentIndex;
    final countChanged = oldWidget.bar.items.length != widget.bar.items.length;
    if (indexChanged || countChanged) {
      _lens.go(widget.bar.currentIndex.toDouble(), distanceScaled: true);
    }
  }

  @override
  void dispose() {
    _lens.dispose();
    _pulse.dispose();
    super.dispose();
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  bool _enabled(int index) {
    if (index < 0 || index >= widget.bar.items.length) return false;
    return widget.bar.items[index].enabled;
  }

  void _remember(Duration time, double index) {
    _trail.add(_IndexSample(time, index));
    final cutoff = time - const Duration(milliseconds: 90);
    while (_trail.length > 2 && _trail.first.time < cutoff) {
      _trail.removeAt(0);
    }
  }

  double _trailVelocity() {
    if (_trail.length < 2) return 0;
    final first = _trail.first;
    final last = _trail.last;
    final dt = (last.time - first.time).inMicroseconds / 1000000.0;
    if (dt < 0.008) return 0;
    return _LensMotion.capVelocity((last.index - first.index) / dt);
  }

  void _startPulse() {
    if (_lens.reduceMotion) return;
    _pulse.forward(from: 0);
  }

  void _stopPulse() {
    _pulse.stop();
    _pulse.value = 0;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_pointer != null) return;
    final index = widget.layout.indexForDx(event.localPosition.dx, rtl: _rtl);
    final slot = index.round();
    _pointer = event.pointer;
    _downLocal = event.localPosition;
    _claimedDrag = false;
    _trail
      ..clear()
      ..add(_IndexSample(event.timeStamp, index));
    if (!_enabled(slot)) return;
    setState(() {
      _interacting = true;
      _pressedIndex = slot;
    });
    _lens.go(slot.toDouble(), distanceScaled: true);
    if (slot == widget.bar.currentIndex) _startPulse();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _downLocal == null) return;
    final delta = event.localPosition - _downLocal!;
    if (!_claimedDrag) {
      if (delta.dx.abs() < kTouchSlop && delta.dy.abs() < kTouchSlop) return;
      if (delta.dy.abs() > delta.dx.abs()) {
        _abandon();
        return;
      }
      _claimedDrag = true;
      _stopPulse();
    }
    final index = widget.layout.indexForDx(event.localPosition.dx, rtl: _rtl);
    _remember(event.timeStamp, index);
    final nearest = index.round().clamp(0, widget.bar.items.length - 1);
    setState(() {
      _interacting = true;
      _pressedIndex = _enabled(nearest) ? nearest : null;
    });
    _lens.go(index, distanceScaled: false);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    final fromDrag = _claimedDrag;
    final origin = _downLocal;
    final dx = fromDrag
        ? event.localPosition.dx
        : (origin?.dx ?? event.localPosition.dx);
    final index = widget.layout
        .indexForDx(dx, rtl: _rtl)
        .round()
        .clamp(0, widget.bar.items.length - 1);
    final velocity = fromDrag ? _trailVelocity() : 0.0;
    _pointer = null;
    _downLocal = null;
    _claimedDrag = false;
    _trail.clear();
    _finish(index, velocity: velocity, fromDrag: fromDrag);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _pointer) return;
    _abandon();
  }

  void _abandon() {
    _pointer = null;
    _downLocal = null;
    _claimedDrag = false;
    _trail.clear();
    _stopPulse();
    setState(() {
      _interacting = false;
      _pressedIndex = null;
    });
    _lens.go(widget.bar.currentIndex.toDouble(), distanceScaled: true);
  }

  void _finish(int index, {required double velocity, required bool fromDrag}) {
    final current = widget.bar.currentIndex;
    final enabled = _enabled(index);
    final reselect = !fromDrag && enabled && index == current;
    setState(() {
      _interacting = false;
      _pressedIndex = null;
    });
    if (!reselect) _stopPulse();
    final settle = enabled ? index : current;
    final alreadyThere = !fromDrag && (settle - _lens.target).abs() < 0.01;
    if (!alreadyThere) {
      _lens.go(
        settle.toDouble(),
        velocity: fromDrag ? velocity : null,
        distanceScaled: true,
      );
    }
    if (!enabled) return;
    // Reselect still notifies. Gallery shells pop back to the workbench
    // when the current tab is tapped again.
    _pendingCommit = index;
    widget.bar.onChanged(index);
    if (index == current) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _interacting) return;
        if (_pendingCommit != index) return;
        _pendingCommit = null;
        if (widget.bar.currentIndex != index) {
          _lens.go(widget.bar.currentIndex.toDouble(), distanceScaled: true);
        }
      });
    });
  }

  _LensFrame _frameFor(double position, double velocity, double target) {
    const insetH = 1.0;
    const insetV = 2.0;
    final layout = widget.layout;
    final baseWidth = math.max(36.0, layout.itemExtent - insetH * 2);
    final baseHeight = _TabBarMetrics.controlHeight - insetV * 2;
    final travel = (target - position).abs();
    final speed = velocity.abs();
    final stretch =
        (travel * _LensMotion.travelStretch + speed * _LensMotion.speedStretch)
            .clamp(0.0, _LensMotion.maxStretch);
    final width = math.min(baseWidth * (1 + stretch), layout.groupWidth);
    final height = baseHeight * (1 - stretch * _LensMotion.squash);
    final visualLead = _rtl ? -velocity : velocity;
    final lead = (visualLead * _LensMotion.leadPerSlot).clamp(
      -_LensMotion.maxLeadPx,
      _LensMotion.maxLeadPx,
    );
    final rawLeft =
        layout.leftFor(position, rtl: _rtl) +
        insetH -
        (width - baseWidth) / 2 +
        lead;
    final maxLeft = math.max(0.0, layout.groupWidth - width);
    return _LensFrame(
      left: rawLeft.clamp(0.0, maxLeft),
      top: insetV + (baseHeight - height) / 2,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bar = widget.bar;
    final layout = widget.layout;
    final pressDuration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
    final pressCurve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
    final solid = GlassSurface.shouldUseOpaqueFallback(
      context,
      forceOpaque: false,
    );

    return SizedBox(
      width: layout.groupWidth,
      height: _TabBarMetrics.controlHeight,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([_lens.listenable, _pulse]),
          builder: (context, child) {
            final frame = _frameFor(
              _lens.position,
              _lens.velocity,
              _lens.target,
            );
            final pulse = math.sin(math.pi * _pulse.value.clamp(0.0, 1.0));
            final lensScale =
                (_interacting ? _LensMotion.lensPressScale : 1.0) *
                (1 + _LensMotion.pulseAmp * pulse);
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: frame.left,
                  width: frame.width,
                  top: frame.top,
                  height: frame.height,
                  child: IgnorePointer(
                    child: Transform.scale(
                      key: const Key('glass-tab-lens-transform'),
                      scale: lensScale,
                      child: _SelectionLens(
                        brightness: widget.brightness,
                        tintedBar: bar.tintedBar,
                        solid: solid,
                        illuminated: _interacting,
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          child: Row(
            children: [
              for (var i = 0; i < bar.items.length; i++) ...[
                if (i > 0) SizedBox(width: layout.itemGap),
                SizedBox(
                  width: layout.itemExtent,
                  height: _TabBarMetrics.controlHeight,
                  child: _TabItem(
                    key: Key('glass-tab-item-$i'),
                    item: bar.items[i],
                    index: i,
                    selected: i == bar.currentIndex,
                    tint: widget.tint,
                    brightness: widget.brightness,
                    tintedBar: bar.tintedBar,
                    onChanged: bar.onChanged,
                    pressed: _pressedIndex == i,
                    ownsPointer: false,
                    pressDuration: pressDuration,
                    pressCurve: pressCurve,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Darker glass lens nested in the Dock platter.
///
/// The body is a sheer dark veil so the platter and the backdrop read
/// through it. It is not a white capsule and not a second [GlassSurface].
/// A nested backdrop blur would stack glass on glass (WWDC25 219
/// principles) and would sample the Dock's own blur. A thin edge catch
/// and a faint caustic keep the thickness. It does not draw the Dock
/// rim's side hairlines, and it does not change the Dock optics recipe.
///
/// Fill alphas are provisional appearance, not Dock recipe tokens.
/// 待核验 vs 真机/Sketch.
class _SelectionLens extends StatelessWidget {
  const _SelectionLens({
    required this.brightness,
    required this.tintedBar,
    required this.solid,
    required this.illuminated,
  });

  final Brightness brightness;
  final bool tintedBar;
  final bool solid;
  final bool illuminated;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      key: const Key('glass-tab-selection-lens'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _LiquidLensPainter(
              brightness: brightness,
              tintedBar: tintedBar,
              solid: solid,
            ),
            child: const SizedBox.expand(),
          ),
          Opacity(
            key: const Key('glass-tab-lens-glow'),
            opacity: illuminated ? 1 : 0,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                gradient: RadialGradient(
                  center: Alignment(0, -0.15),
                  radius: 0.9,
                  colors: [Color(0xA6FFFFFF), Color(0x00FFFFFF)],
                  stops: [0.0, 0.8],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidLensPainter extends CustomPainter {
  const _LiquidLensPainter({
    required this.brightness,
    required this.tintedBar,
    required this.solid,
  });

  final Brightness brightness;
  final bool tintedBar;
  final bool solid;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final bounds = Offset.zero & size;
    final stadium = BorderRadius.circular(100).toRRect(bounds);
    canvas.save();
    canvas.clipRRect(stadium);

    final Color top;
    final Color bottom;
    final Color caustic;
    final Color lip;
    final Color shade;
    if (solid) {
      // Opaque fallback cannot show the backdrop. A darker chip keeps
      // the selection readable without turning into a white pill.
      top = brightness == Brightness.dark
          ? const Color(0xF0141418)
          : const Color(0xE6D5D5DC);
      bottom = brightness == Brightness.dark
          ? const Color(0xF0101014)
          : const Color(0xE6C6C6CE);
      caustic = const Color(0x33FFFFFF);
      lip = const Color(0x99FFFFFF);
      shade = const Color(0x22000000);
    } else if (tintedBar) {
      top = const Color(0x4D000000);
      bottom = const Color(0x26000000);
      caustic = const Color(0x33FFFFFF);
      lip = const Color(0x80FFFFFF);
      shade = const Color(0x40000000);
    } else if (brightness == Brightness.dark) {
      top = const Color(0x66101418);
      bottom = const Color(0x33101418);
      caustic = const Color(0x22FFFFFF);
      lip = const Color(0x66FFFFFF);
      shade = const Color(0x80000000);
    } else {
      // Sheer dark veil on the see-through Dock. White body fill read
      // as a solid pill. 待核验 vs 真机/Sketch.
      top = const Color(0x4A12141A);
      bottom = const Color(0x2412141A);
      caustic = const Color(0x28FFFFFF);
      lip = const Color(0x73FFFFFF);
      shade = const Color(0x38000000);
    }

    canvas.drawRRect(
      stadium,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(bounds),
    );

    canvas.drawRRect(
      stadium,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.55),
          radius: 0.62,
          colors: [
            caustic.withValues(alpha: (caustic.a * 0.55).clamp(0.0, 1.0)),
            caustic.withValues(alpha: 0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(bounds),
    );

    // Hairline catch only. A tall white lip becomes a white cap.
    final lipHeight = math.min(size.height * 0.08, 3.0);
    final lipRect = Rect.fromLTWH(0, 0, size.width, lipHeight);
    canvas.drawRect(
      lipRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lip, lip.withValues(alpha: 0)],
        ).createShader(lipRect),
    );

    final shadeHeight = math.min(size.height * 0.22, 8.0);
    final shadeRect = Rect.fromLTWH(
      0,
      size.height - shadeHeight,
      size.width,
      shadeHeight,
    );
    canvas.drawRect(
      shadeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [shade, shade.withValues(alpha: 0)],
        ).createShader(shadeRect),
    );

    final stroke = LiquidGlassTokens.hairlineWidth;
    final inset = stadium.deflate(stroke);
    canvas.drawRRect(
      inset,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lip,
            lip.withValues(alpha: (lip.a * 0.25).clamp(0.0, 1.0)),
            shade.withValues(alpha: (shade.a + 0.08).clamp(0.0, 0.35)),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(bounds),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidLensPainter oldDelegate) {
    return oldDelegate.brightness != brightness ||
        oldDelegate.tintedBar != tintedBar ||
        oldDelegate.solid != solid;
  }
}

class _TabItem extends StatefulWidget {
  const _TabItem({
    super.key,
    required this.item,
    required this.index,
    required this.selected,
    required this.tint,
    required this.brightness,
    required this.tintedBar,
    required this.onChanged,
    this.pressed = false,
    this.ownsPointer = true,
    this.pressDuration,
    this.pressCurve,
  });

  final GlassTabBarItem item;
  final int index;
  final bool selected;
  final Color tint;
  final Brightness brightness;
  final bool tintedBar;
  final ValueChanged<int> onChanged;

  /// Parent-owned press, used when [ownsPointer] is false.
  final bool pressed;

  /// Sidebar items own the pointer. The bottom row handles drag itself.
  final bool ownsPointer;
  final Duration? pressDuration;
  final Curve? pressCurve;

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _localPressed = false;

  bool get _down => widget.ownsPointer ? _localPressed : widget.pressed;

  Color get _color {
    if (widget.tintedBar) {
      return widget.selected
          ? Colors.white
          : Colors.white.withValues(alpha: GlassTabBar.tintedUnselectedOpacity);
    }
    if (widget.selected) return widget.tint;
    return LiquidGlassLabels.primaryFor(widget.brightness)
        .withValues(alpha: GlassTabBar.unselectedOpacity);
  }

  String get _semanticsLabel {
    final badge = widget.item.badge;
    if (badge == null) return widget.item.label;
    if (badge.isEmpty) return '${widget.item.label}, badge';
    return '${widget.item.label}, $badge';
  }

  void _setDown(bool down) {
    if (!widget.item.enabled || _localPressed == down) return;
    setState(() => _localPressed = down);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = _color;
    final icon = widget.selected ? (item.selectedIcon ?? item.icon) : item.icon;
    final gap = widget.selected ? 1.0 : 0.5;
    final duration =
        widget.pressDuration ??
        LiquidGlassMotion.durationOf(context, LiquidGlassMotion.defaults.quick);
    final curve =
        widget.pressCurve ??
        LiquidGlassMotion.curveOf(
          context,
          LiquidGlassMotion.defaults.quickCurve,
        );
    final lifted = _down && item.enabled;

    final visual = AnimatedSlide(
      offset: lifted ? _LensMotion.pressSlide : Offset.zero,
      duration: duration,
      curve: curve,
      child: AnimatedScale(
        scale: lifted ? _LensMotion.pressLift : 1,
        duration: duration,
        curve: curve,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _TabBarMetrics.itemPaddingH,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: _TabBarMetrics.symbolBox,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, size: _TabBarMetrics.symbolSize, color: color),
                    if (item.badge != null)
                      Positioned(
                        top: -2,
                        right: -6,
                        child: _TabBadge(text: item.badge!),
                      ),
                  ],
                ),
              ),
              SizedBox(height: gap),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: _TabBarMetrics.labelSize,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: widget.selected ? -0.1 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: item.enabled,
      label: _semanticsLabel,
      onTap: item.enabled ? () => widget.onChanged(widget.index) : null,
      child: ExcludeSemantics(
        child: MouseRegion(
          cursor: item.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Opacity(
            opacity: item.enabled ? 1 : GlassTabBar.disabledOpacity,
            child: widget.ownsPointer
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: item.enabled ? (_) => _setDown(true) : null,
                    onTapUp: item.enabled
                        ? (_) {
                            _setDown(false);
                            widget.onChanged(widget.index);
                          }
                        : null,
                    onTapCancel: item.enabled ? () => _setDown(false) : null,
                    child: visual,
                  )
                : visual,
          ),
        ),
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final dot = text.isEmpty;
    return Container(
      constraints: BoxConstraints(
        minWidth: dot ? 8 : 16,
        minHeight: dot ? 8 : 16,
      ),
      padding: dot
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFFF3B30),
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: dot
          ? null
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

/// Vertical Dock column for [GlassTabBarStyle.sidebar].
///
/// A Flutter glass rail (Liquid Glass Dock), not the iOS 27.1 vertical
/// system Toolbar / Tab Bar and not a Materials Thick sidebar.
class _SidebarStub extends StatelessWidget {
  const _SidebarStub({
    required this.bar,
    required this.tint,
    required this.brightness,
  });

  final GlassTabBar bar;
  final Color tint;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    const extent = 76.0;
    final layout = _ItemLayout.even(
      count: bar.items.length,
      groupWidth: extent,
      gap: 0,
    );
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      widthFactor: 1,
      child: GlassSurface(
        key: const Key('glass-tab-bar-sidebar-stub'),
        tokens: LiquidGlassTheme.styleOf(context, bar.glassStyle),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < bar.items.length; i++)
              SizedBox(
                width: layout.itemExtent,
                height: _TabBarMetrics.controlHeight,
                child: _TabItem(
                  item: bar.items[i],
                  index: i,
                  selected: i == bar.currentIndex,
                  tint: tint,
                  brightness: brightness,
                  tintedBar: bar.tintedBar,
                  onChanged: bar.onChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
