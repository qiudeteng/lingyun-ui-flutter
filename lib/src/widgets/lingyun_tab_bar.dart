import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../layout/lingyun_layout.dart';
import '../page/lingyun_native_page.dart';
import '../tokens/liquid_glass_style.dart';
import 'glass_tab_bar.dart';

/// View type and channel shared with `LYTabBarPlatformView`.
class LingyunTabBarHost {
  const LingyunTabBarHost._();

  static const String viewType = 'lingyun_ui_flutter/ly_tab_bar';

  static String channelName(int viewId) =>
      'lingyun_ui_flutter/ly_tab_bar_$viewId';
}

/// Where the system tab bar sits inside the host.
///
/// The iOS process reports this from `UITabBarController`. Flutter does not
/// invent a vertical bar; the system moves the real tab bar, including
/// Liquid Glass and iOS 27.1 side chrome when that OS provides them.
enum LingyunTabBarEdge { bottom, top, leading, trailing }

/// Frame of the system tab bar in the platform view's coordinates.
class LingyunTabBarMetrics {
  const LingyunTabBarMetrics({
    required this.edge,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final LingyunTabBarEdge edge;
  final double x;
  final double y;
  final double width;
  final double height;

  /// Padding that keeps Flutter content out of the system chrome.
  ///
  /// [bounds] is the platform view's size. Leading and trailing follow the
  /// edge the system reported, not a hardcoded left or right.
  EdgeInsetsDirectional contentPadding(Size bounds) {
    switch (edge) {
      case LingyunTabBarEdge.top:
        return EdgeInsetsDirectional.only(top: _positive(y + height));
      case LingyunTabBarEdge.leading:
        return EdgeInsetsDirectional.only(start: _positive(x + width));
      case LingyunTabBarEdge.trailing:
        return EdgeInsetsDirectional.only(end: _positive(bounds.width - x));
      case LingyunTabBarEdge.bottom:
        return EdgeInsetsDirectional.only(bottom: _positive(bounds.height - y));
    }
  }

  static LingyunTabBarMetrics? fromWire(Object? raw) {
    if (raw is! Map) return null;
    final edge = switch (raw['edge']?.toString()) {
      'top' => LingyunTabBarEdge.top,
      'leading' => LingyunTabBarEdge.leading,
      'trailing' => LingyunTabBarEdge.trailing,
      'bottom' => LingyunTabBarEdge.bottom,
      _ => null,
    };
    if (edge == null) return null;
    return LingyunTabBarMetrics(
      edge: edge,
      x: _asDouble(raw['x']),
      y: _asDouble(raw['y']),
      width: _asDouble(raw['width']),
      height: _asDouble(raw['height']),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LingyunTabBarMetrics &&
        other.edge == edge &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(edge, x, y, width, height);
}

double _positive(double value) => value < 0 ? 0 : value;

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return 0;
}

/// Whether the Flutter dock is still painted.
///
/// A real iOS process hides it once `UITabBarController` exists, so the
/// system bar is the only chrome. Widget tests set
/// [LingyunPageHost.debugIsIOSHostOverride] and have no UITabBar, so the
/// dock stays and selection still runs through the same [GlassTabBarItem]
/// callbacks. Before the platform view is ready the dock also stays, which
/// avoids a blank bar on the first frame.
bool lingyunTabBarPaintsFlutterDock({
  required bool isIOSHost,
  required bool debugOverride,
  required bool platformViewReady,
}) {
  if (!isIOSHost) return true;
  if (debugOverride) return true;
  return !platformViewReady;
}

/// One tab bar for every platform.
///
/// Callers pass [GlassTabBarItem]s, [currentIndex], and [onChanged]. On an
/// iOS process the chrome is `UITabBarController` (system Liquid Glass, and
/// a vertical bar when iOS 27.1 moves it). [child] stays in Flutter: the
/// workbench and pushed demos are not replaced by the LYPage metrics panes.
/// Other platforms paint [GlassTabBar] with [GlassTabBar.systemDock], the
/// same items, and the same callback. That dock floats over [child]. The
/// page keeps painting underneath, and the bar does not add an opaque fill
/// outside the glass capsule.
///
/// [style], [glassStyle], [tint], [brightness], and [tintedBar] match
/// [GlassTabBar]. [style] shapes the Flutter dock. The iOS bar is the
/// system tab bar; it does not restyle itself into the kit specimen.
///
/// Pass [child] for a page shell. The host then fills that box so the
/// system can place the bar on the bottom or the side. Without [child] the
/// widget is only the bar, and a real iOS process still mounts the system
/// bar in a bottom slot.
class LingyunTabBar extends StatefulWidget {
  const LingyunTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.child,
    this.barKey,
    this.style = GlassTabBarStyle.floatingPill,
    this.glassStyle = LiquidGlassStyle.dock,
    this.tint,
    this.brightness,
    this.tintedBar = false,
  });

  final List<GlassTabBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  /// Body laid out beside the chrome. Null paints only the bar.
  final Widget? child;

  /// Key for the chrome only, not for [child].
  ///
  /// Page tests look under `lingyun-page-tab-bar` for the dock's blur and
  /// labels. Putting that key on this shell would also see the workbench.
  final Key? barKey;

  final GlassTabBarStyle style;
  final LiquidGlassStyle glassStyle;
  final Color? tint;
  final Brightness? brightness;
  final bool tintedBar;

  /// Bottom space reserved before the system reports its frame.
  ///
  /// Matches a phone dock: 8pt top gap, 62pt capsule, and the home-indicator
  /// overlap the Flutter dock already uses. The Flutter dock also uses this
  /// as the content clearance while it floats over [child]. It is not a
  /// painted bar.
  static const double fallbackBottomInset = 96;

  /// Arguments for `LYTabBarPlatformView`. Same map as `update`.
  Map<String, Object?> toWire() {
    final tint = this.tint;
    return {
      'items': [
        for (final item in items)
          {
            'label': item.label,
            'systemImage': item.systemImage,
            'selectedSystemImage': item.selectedSystemImage ?? item.systemImage,
            'badge': item.badge,
            'enabled': item.enabled,
          },
      ],
      'currentIndex': currentIndex,
      'tintedBar': tintedBar,
      'tint': tint?.toARGB32(),
    };
  }

  @override
  State<LingyunTabBar> createState() => _LingyunTabBarState();
}

class _LingyunTabBarState extends State<LingyunTabBar> {
  MethodChannel? _channel;
  int? _viewId;
  LingyunTabBarMetrics? _metrics;
  Map<String, Object?>? _sent;

  bool get _showFlutterDock => lingyunTabBarPaintsFlutterDock(
    isIOSHost: LingyunPageHost.isIOSHost,
    debugOverride: LingyunPageHost.debugHostOverrideActive,
    platformViewReady: _viewId != null,
  );

  @override
  void didUpdateWidget(LingyunTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameWire(oldWidget.toWire(), widget.toWire())) {
      _push();
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onCreated(int id) {
    final channel = MethodChannel(LingyunTabBarHost.channelName(id));
    _channel = channel;
    channel.setMethodCallHandler((call) async {
      if (!mounted) return;
      switch (call.method) {
        case 'select':
          final index = _asInt(call.arguments);
          if (index == null) return;
          if (index < 0 || index >= widget.items.length) return;
          if (!widget.items[index].enabled) return;
          if (index != widget.currentIndex) widget.onChanged(index);
        case 'metrics':
          final next = LingyunTabBarMetrics.fromWire(call.arguments);
          if (next == null || next == _metrics) return;
          setState(() => _metrics = next);
      }
    });
    setState(() => _viewId = id);
    _push(force: true);
  }

  Future<void> _push({bool force = false}) async {
    final channel = _channel;
    final wire = widget.toWire();
    if (!force && _sameWire(_sent, wire) && channel != null) return;
    _sent = wire;
    if (channel == null) return;
    try {
      await channel.invokeMethod<void>('update', wire);
    } on MissingPluginException {
      // The view was created, then the engine dropped the channel.
    }
  }

  Widget _flutterDock() {
    return GlassTabBar(
      key: widget.barKey,
      items: widget.items,
      currentIndex: widget.currentIndex,
      onChanged: widget.onChanged,
      style: widget.style,
      glassStyle: widget.glassStyle,
      tint: widget.tint,
      brightness: widget.brightness,
      tintedBar: widget.tintedBar,
      systemDock: widget.style == GlassTabBarStyle.floatingPill,
    );
  }

  Widget _nativeView() {
    return UiKitView(
      key: _showFlutterDock ? null : widget.barKey,
      viewType: LingyunTabBarHost.viewType,
      creationParams: widget.toWire(),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onCreated,
      hitTestBehavior: _showFlutterDock
          ? PlatformViewHitTestBehavior.transparent
          : PlatformViewHitTestBehavior.translucent,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.items.isNotEmpty, 'LingyunTabBar.items must not be empty.');
    final dock = _showFlutterDock ? _flutterDock() : null;
    final native = LingyunPageHost.isIOSHost ? _nativeView() : null;
    final body = widget.child;

    if (body == null) {
      if (native != null && dock == null) {
        return SizedBox(
          height: LingyunTabBar.fallbackBottomInset,
          child: native,
        );
      }
      return dock ?? const SizedBox.shrink();
    }

    final flutterChrome = dock == null
        ? null
        : widget.style == GlassTabBarStyle.sidebar
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              dock,
              Expanded(child: body),
            ],
          )
        : _FloatingDockOverlay(dock: dock, child: body);

    if (native == null) {
      return flutterChrome ?? body;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bounds = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            if (flutterChrome != null)
              flutterChrome
            else
              Padding(padding: _nativePadding(bounds), child: body),
            Positioned.fill(
              child: IgnorePointer(ignoring: _showFlutterDock, child: native),
            ),
          ],
        );
      },
    );
  }

  EdgeInsetsGeometry _nativePadding(Size bounds) {
    final metrics = _metrics;
    if (metrics == null || bounds.isEmpty) {
      return const EdgeInsetsDirectional.only(
        bottom: LingyunTabBar.fallbackBottomInset,
      );
    }
    return metrics.contentPadding(bounds);
  }
}

/// Page full-bleed, dock painted on top. No color in the bar slot.
class _FloatingDockOverlay extends StatelessWidget {
  const _FloatingDockOverlay({required this.dock, required this.child});

  final Widget dock;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        LingyunOverlayClearance(
          bottom: LingyunTabBar.fallbackBottomInset,
          child: child,
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: dock),
      ],
    );
  }
}

bool _sameWire(Map<String, Object?>? a, Map<String, Object?>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!_sameValue(a[key], b[key])) return false;
  }
  return true;
}

bool _sameValue(Object? a, Object? b) {
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_sameValue(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!_sameValue(a[key], b[key])) return false;
    }
    return true;
  }
  return a == b;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is Map) return _asInt(value['index']);
  return null;
}
