import Flutter
import UIKit

/// Registers the LYPage metrics host and the system tab bar.
///
/// `LingyunNativePage` embeds `ly_page` (the metrics scaffold).
/// `LingyunTabBar` embeds `ly_tab_bar` (`UITabBarController`) and keeps the
/// Flutter body. The two hosts are separate so a gallery can use system
/// tab chrome without replacing its workbenches.
public class LingyunUiFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    registrar.register(
      LYPagePlatformViewFactory(messenger: messenger),
      withId: "lingyun_ui_flutter/ly_page"
    )
    registrar.register(
      LYTabBarPlatformViewFactory(messenger: messenger),
      withId: "lingyun_ui_flutter/ly_tab_bar"
    )
  }
}

final class LYTabBarPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    LYTabBarPlatformView(
      frame: frame,
      viewId: viewId,
      args: args as? [String: Any],
      messenger: messenger
    )
  }
}
