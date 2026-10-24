import Flutter
import SwiftUI
import UIKit

/// Owns spec + metrics for one platform view and pushes them to Flutter.
final class LYPageSession: ObservableObject {
  @Published var spec: LYPageSpec
  @Published var metrics: LYPageMetrics

  var onPayload: (([String: Any]) -> Void)?

  init(spec: LYPageSpec) {
    self.spec = spec
    self.metrics = .empty
  }

  func replaceSpec(_ spec: LYPageSpec) {
    guard spec != self.spec else { return }
    self.spec = spec
    emit()
  }

  func updateHost(
    bounds: CGSize,
    horizontal: UIUserInterfaceSizeClass,
    vertical: UIUserInterfaceSizeClass,
    insets: UIEdgeInsets,
    layoutDirection: UIUserInterfaceLayoutDirection
  ) {
    guard bounds.width > 0, bounds.height > 0 else { return }
    var next = metrics
    next.widthBucket = LYPageWidthBucket.resolve(
      horizontal: horizontal,
      availableWidth: bounds.width
    )
    next.horizontalSizeClass = LYPageSizeClassName(horizontal)
    next.verticalSizeClass = LYPageSizeClassName(vertical)
    next.boundsWidth = bounds.width
    next.boundsHeight = bounds.height
    next.hostSafeArea = LYPageEdgeInsets.host(
      insets: insets,
      layoutDirection: layoutDirection
    )
    next.arrangementLinked = LYPageSDK.arrangementLinked
    guard next != metrics else { return }
    metrics = next
    emit()
  }

  func updateContentSafeArea(_ insets: LYPageEdgeInsets) {
    guard insets != metrics.contentSafeArea else { return }
    metrics.contentSafeArea = insets
    emit()
  }

  func updateRegions(_ regions: [LYPageRegionSnapshot], supported: Bool) {
    guard regions != metrics.regions || supported != metrics.reservedRegionsSupported else {
      return
    }
    metrics.regions = regions
    metrics.reservedRegionsSupported = supported
    emit()
  }

  func payload() -> [String: Any] {
    let container = LYPageContainer.resolve(
      spec: spec,
      bucket: metrics.widthBucket
    )
    let mountedRoot: String
    if container.usesArrangement && !metrics.arrangementLinked {
      mountedRoot = "NavigationStack"
    } else {
      mountedRoot = container.root
    }
    let host = metrics.hostSafeArea
    let content = metrics.contentSafeArea
    return [
      "chrome": spec.chrome.rawValue,
      "navigation": spec.navigation.rawValue,
      "primaryLabel": spec.primaryLabel,
      "secondaryLabel": spec.secondaryLabel,
      "widthBucket": metrics.widthBucket.rawValue,
      "horizontalSizeClass": metrics.horizontalSizeClass.rawValue,
      "verticalSizeClass": metrics.verticalSizeClass.rawValue,
      "boundsWidth": metrics.boundsWidth,
      "boundsHeight": metrics.boundsHeight,
      "safeLeading": host.leading,
      "safeTrailing": host.trailing,
      "safeTop": host.top,
      "safeBottom": host.bottom,
      "safeLeft": host.left,
      "safeRight": host.right,
      "contentSafeLeading": content.leading,
      "contentSafeTrailing": content.trailing,
      "contentSafeTop": content.top,
      "contentSafeBottom": content.bottom,
      "arrangementLinked": metrics.arrangementLinked,
      "reservedRegionsSupported": metrics.reservedRegionsSupported,
      "regions": metrics.regions.map { $0.encode() },
      "root": container.root,
      "mountedRoot": mountedRoot,
      "wrapsTabView": container.wrapsTabView,
      "wrapsSplitView": container.wrapsSplitView,
      "usesArrangement": container.usesArrangement,
      "columns": container.columns,
      "chromeApplied": container.chromeApplied,
      "note": container.note,
    ]
  }

  private func emit() {
    onPayload?(payload())
  }
}

final class LYPageContainerView: UIView {
  let hosting: UIHostingController<LYPageScaffold>
  let session: LYPageSession

  init(session: LYPageSession) {
    self.session = session
    self.hosting = UIHostingController(rootView: LYPageScaffold(session: session))
    super.init(frame: .zero)
    backgroundColor = .systemBackground
    insetsLayoutMarginsFromSafeArea = false
    hosting.view.backgroundColor = .clear
    hosting.view.insetsLayoutMarginsFromSafeArea = true
    hosting.edgesForExtendedLayout = .all
    hosting.extendedLayoutIncludesOpaqueBars = true
    hosting.additionalSafeAreaInsets = .zero
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not used")
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window == nil {
      detach()
      return
    }
    attach()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if hosting.parent == nil {
      attach()
    }
    if hosting.view.superview !== self {
      addSubview(hosting.view)
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    hosting.view.frame = bounds
    publishHost()
  }

  override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    publishHost()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    publishHost()
  }

  private func attach() {
    guard hosting.parent == nil, let parent = nearestViewController() else { return }
    parent.addChild(hosting)
    addSubview(hosting.view)
    hosting.view.frame = bounds
    hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hosting.didMove(toParent: parent)
  }

  private func detach() {
    guard hosting.parent != nil else {
      hosting.view.removeFromSuperview()
      return
    }
    hosting.willMove(toParent: nil)
    hosting.view.removeFromSuperview()
    hosting.removeFromParent()
  }

  private func nearestViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while let current = responder {
      if let controller = current as? UIViewController {
        return controller
      }
      responder = current.next
    }
    return nil
  }

  private func publishHost() {
    session.updateHost(
      bounds: bounds.size,
      horizontal: traitCollection.horizontalSizeClass,
      vertical: traitCollection.verticalSizeClass,
      insets: safeAreaInsets,
      layoutDirection: effectiveUserInterfaceLayoutDirection
    )
  }
}

final class LYPagePlatformView: NSObject, FlutterPlatformView {
  private let container: LYPageContainerView
  private let channel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewId: Int64,
    args: [String: Any]?,
    messenger: FlutterBinaryMessenger
  ) {
    let session = LYPageSession(spec: LYPageSpec.decode(args))
    container = LYPageContainerView(session: session)
    container.frame = frame
    channel = FlutterMethodChannel(
      name: "lingyun_ui_flutter/ly_page_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()
    session.onPayload = { [weak self] payload in
      self?.channel.invokeMethod("metrics", arguments: payload)
    }
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "released", message: "LYPage view released", details: nil))
        return
      }
      switch call.method {
      case "updateSpec":
        let arguments = call.arguments as? [String: Any]
        self.container.session.replaceSpec(LYPageSpec.decode(arguments))
        result(nil)
      case "snapshot":
        result(self.container.session.payload())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView {
    container
  }
}

final class LYPagePlatformViewFactory: NSObject, FlutterPlatformViewFactory {
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
    LYPagePlatformView(
      frame: frame,
      viewId: viewId,
      args: args as? [String: Any],
      messenger: messenger
    )
  }
}
