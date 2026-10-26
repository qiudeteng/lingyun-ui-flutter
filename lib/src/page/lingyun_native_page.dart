import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'lingyun_host_io.dart'
    if (dart.library.js_interop) 'lingyun_host_web.dart';
import 'lingyun_page_spec.dart';

/// Method-channel and platform-view names shared with `LYPagePlatformView`.
class LingyunPageHost {
  const LingyunPageHost._();

  static const String viewType = 'lingyun_ui_flutter/ly_page';

  static String channelName(int viewId) => 'lingyun_ui_flutter/ly_page_$viewId';

  /// Widget-test stand-in for [lingyunProcessIsIOS].
  ///
  /// The VM is not an iOS process, so tests that need the host branch set
  /// this and clear it afterwards. A null value leaves [isIOSHost] on the
  /// real process check. Production code leaves it null.
  @visibleForTesting
  static bool? debugIsIOSHostOverride;

  /// True when a test has set [debugIsIOSHostOverride].
  ///
  /// Production leaves the override null. `LingyunTabBar` reads this so a
  /// widget test can still tap the Flutter dock; there is no UITabBar in
  /// that binding. The real iOS process hides the dock once the platform
  /// view exists.
  static bool get debugHostOverrideActive => debugIsIOSHostOverride != null;

  /// True only when this process is iOS.
  ///
  /// `Platform.isIOS`, not `defaultTargetPlatform`. A gallery board may set
  /// `debugDefaultTargetPlatformOverride` so controls resemble iOS; that
  /// must not swap this page for a [UiKitView] on hosts with no LYPage embed.
  /// [debugIsIOSHostOverride] is the only stand-in, and only for tests.
  static bool get isIOSHost => debugIsIOSHostOverride ?? lingyunProcessIsIOS;
}

/// Embeds the iOS `LYPage` host. On other platforms, builds [placeholder].
///
/// The view reports horizontal size class and its own bounds. Callers do
/// not pass a device size. FlutterUI's `LingyunPage` should use this on iOS
/// for system tab, split, and arrangement chrome.
class LingyunNativePage extends StatefulWidget {
  const LingyunNativePage({
    super.key,
    required this.spec,
    this.onSnapshot,
    this.placeholder,
  });

  final LingyunPageSpec spec;
  final ValueChanged<LingyunPageSnapshot>? onSnapshot;
  final Widget? placeholder;

  @override
  State<LingyunNativePage> createState() => _LingyunNativePageState();
}

class _LingyunNativePageState extends State<LingyunNativePage> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(LingyunNativePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spec != widget.spec) {
      _pushSpec();
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onCreated(int id) {
    final channel = MethodChannel(LingyunPageHost.channelName(id));
    _channel = channel;
    channel.setMethodCallHandler((call) async {
      if (call.method != 'metrics') return;
      final snapshot = LingyunPageSnapshot.fromWire(call.arguments);
      if (snapshot != null) {
        widget.onSnapshot?.call(snapshot);
      }
    });
    _pushSpec();
  }

  Future<void> _pushSpec() async {
    final channel = _channel;
    if (channel == null) return;
    try {
      await channel.invokeMethod<void>('updateSpec', widget.spec.toWire());
    } on MissingPluginException {
      // The view was created, then the engine dropped the channel.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!LingyunPageHost.isIOSHost) {
      return widget.placeholder ?? const SizedBox.expand();
    }
    return UiKitView(
      viewType: LingyunPageHost.viewType,
      creationParams: widget.spec.toWire(),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onCreated,
    );
  }
}
