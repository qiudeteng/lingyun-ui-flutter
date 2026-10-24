import Flutter
import UIKit

/// Registers the LYPage platform view. Dart `LingyunNativePage` is the caller.
/// FlutterUI's `LingyunPage` should embed that view on iOS rather than
/// painting a second vertical tab bar.
public class LingyunUiFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = LYPagePlatformViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "lingyun_ui_flutter/ly_page")
  }
}
