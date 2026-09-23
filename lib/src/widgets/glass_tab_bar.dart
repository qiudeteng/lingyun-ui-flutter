import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/liquid_glass_theme.dart';
import '../tokens/liquid_glass_labels.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import '../tokens/liquid_glass_tokens.dart';
import 'glass_surface.dart';

/// How [GlassTabBar] is arranged.
///
/// Sketch UI Kit page 「Tab Bars」 (iPhone) is a floating capsule. [standard]
/// is the full-width, edge-to-bottom bar. [sidebar] is reserved for a later
/// iPad vertical pass — the widget only lays items out so the API exists.
enum GlassTabBarStyle {
  /// Full-width bar, flush to the bottom edge. Icon + caption sit above the
  /// Home Indicator inset.
  standard,

  /// Floating Liquid Glass capsule. Width follows the kit group widths
  /// (3 → 266, 4 and 5 share the 352 cap on a 402pt board).
  floatingPill,

  /// Reserved. iPad vertical / sidebar tab — not a finished UI.
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
/// indicator bar; a short lens slides behind the selected item.
///
/// [tintedBar] fills the whole platter with [tint] (System Blue by default)
/// and draws white icons.
///
/// The floating capsule uses a stadium radius (`BorderRadius.circular(100)`,
/// kit `cornerRadius: 100`), not the unverified 18 / 26 / 34 steps.
/// `blurSigma` / `saturation` stay implementation approximations inside the
/// Dock tokens.
///
/// [GlassTabBarStyle.sidebar] is an API stub for a later iPad pass.
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
  /// Approximates the kit LINEAR_BURN / LINEAR_DODGE mix. Not a selected
  /// color, and not a custom grey used as the selection tint.
  static const double unselectedOpacity = 0.58;

  /// Unselected icon/caption opacity when [tintedBar] is on.
  static const double tintedUnselectedOpacity = 0.72;

  /// Disabled items are multiplied by this opacity.
  static const double disabledOpacity = 0.38;

  final List<GlassTabBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  /// [GlassTabBarStyle.standard], [GlassTabBarStyle.floatingPill], or the
  /// reserved [GlassTabBarStyle.sidebar].
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

  double itemLeft(int index) => index * (itemExtent + itemGap);

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
    tintColor: tint.withValues(alpha: 0.88),
    overlayColor: const Color(0x40FFFFFF),
    overlayBlend: BlendMode.softLight,
    edgeHighlightColor: const Color(0x73FFFFFF),
    opaqueFallbackColor: tint,
  );
}

class _ItemRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
    final curve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
    const lensInset = 2.0;
    final lensLeft = layout.itemLeft(bar.currentIndex) + lensInset;
    final lensWidth = math.max(36.0, layout.itemExtent - lensInset * 2);

    return SizedBox(
      width: layout.groupWidth,
      height: _TabBarMetrics.controlHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: duration,
            curve: curve,
            left: lensLeft,
            width: lensWidth,
            top: 4,
            height: _TabBarMetrics.controlHeight - 8,
            child: IgnorePointer(
              child: DecoratedBox(
                key: const Key('glass-tab-selection-lens'),
                decoration: BoxDecoration(
                  color: _lensColor(
                    brightness: brightness,
                    tintedBar: bar.tintedBar,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < bar.items.length; i++) ...[
                if (i > 0) SizedBox(width: layout.itemGap),
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
            ],
          ),
        ],
      ),
    );
  }
}

Color _lensColor({required Brightness brightness, required bool tintedBar}) {
  if (tintedBar) return const Color(0x40FFFFFF);
  if (brightness == Brightness.dark) return const Color(0x33FFFFFF);
  return const Color(0x99FFFFFF);
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.item,
    required this.index,
    required this.selected,
    required this.tint,
    required this.brightness,
    required this.tintedBar,
    required this.onChanged,
  });

  final GlassTabBarItem item;
  final int index;
  final bool selected;
  final Color tint;
  final Brightness brightness;
  final bool tintedBar;
  final ValueChanged<int> onChanged;

  Color get _color {
    if (tintedBar) {
      return selected
          ? Colors.white
          : Colors.white.withValues(alpha: GlassTabBar.tintedUnselectedOpacity);
    }
    if (selected) return tint;
    return LiquidGlassLabels.primaryFor(
      brightness,
    ).withValues(alpha: GlassTabBar.unselectedOpacity);
  }

  String get _semanticsLabel {
    final badge = item.badge;
    if (badge == null) return item.label;
    if (badge.isEmpty) return '${item.label}, badge';
    return '${item.label}, $badge';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final icon = selected ? (item.selectedIcon ?? item.icon) : item.icon;
    final gap = selected ? 1.0 : 0.5;

    return Semantics(
      button: true,
      selected: selected,
      enabled: item.enabled,
      label: _semanticsLabel,
      child: ExcludeSemantics(
        child: MouseRegion(
          cursor: item.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!item.enabled) return;
              onChanged(index);
            },
            child: Opacity(
              opacity: item.enabled ? 1 : GlassTabBar.disabledOpacity,
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
                          Icon(
                            icon,
                            size: _TabBarMetrics.symbolSize,
                            color: color,
                          ),
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
                        letterSpacing: selected ? -0.1 : 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

/// Vertical Dock column so [GlassTabBarStyle.sidebar] is callable.
///
/// Not the finished iPad sidebar. A later pass replaces this layout.
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
