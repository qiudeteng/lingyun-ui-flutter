import Flutter
import UIKit

/// One destination. Mirrors `GlassTabBarItem` fields the system bar can draw.
struct LYTabBarItemSpec: Equatable {
  var label: String
  var systemImage: String
  var selectedSystemImage: String
  var badge: String?
  var enabled: Bool
}

/// Selection and items for `UITabBarController`.
struct LYTabBarWire: Equatable {
  var items: [LYTabBarItemSpec]
  var currentIndex: Int
  var tintedBar: Bool
  var tint: UIColor?

  static func decode(_ args: [String: Any]?) -> LYTabBarWire {
    let rawItems = args?["items"] as? [Any] ?? []
    var items: [LYTabBarItemSpec] = []
    for entry in rawItems {
      guard let raw = entry as? [String: Any] else { continue }
      let label = (raw["label"] as? String) ?? ""
      let symbol = nonEmpty(raw["systemImage"] as? String) ?? "circle"
      let selected = nonEmpty(raw["selectedSystemImage"] as? String) ?? symbol
      let badge = badgeValue(raw["badge"])
      let enabled = raw["enabled"] as? Bool ?? true
      items.append(
        LYTabBarItemSpec(
          label: label,
          systemImage: symbol,
          selectedSystemImage: selected,
          badge: badge,
          enabled: enabled
        )
      )
    }
    if items.isEmpty {
      items.append(
        LYTabBarItemSpec(
          label: "Tab",
          systemImage: "circle",
          selectedSystemImage: "circle.fill",
          badge: nil,
          enabled: true
        )
      )
    }
    let requested = intValue(args?["currentIndex"]) ?? 0
    let index = min(max(0, requested), items.count - 1)
    return LYTabBarWire(
      items: items,
      currentIndex: index,
      tintedBar: args?["tintedBar"] as? Bool ?? false,
      tint: colorValue(args?["tint"])
    )
  }
}

/// System tab chrome around Flutter content.
///
/// `UITabBarController` owns placement. Liquid Glass and an iOS 27.1
/// vertical bar come from the system when that OS provides them. This
/// controller does not draw a Flutter dock and does not require
/// `LY_IOS_27_1_SDK`. Content controllers are clear and do not take hits;
/// Flutter draws the destination body underneath and pads it with the
/// reported tab-bar frame.
final class LYSystemTabBarController: UITabBarController, UITabBarControllerDelegate {
  private var specs: [LYTabBarItemSpec] = []
  private var applyingRemote = false
  private var didCustomizeAppearance = false
  var onSelect: ((Int) -> Void)?
  var onChromeChanged: (() -> Void)?

  func apply(_ wire: LYTabBarWire) {
    let itemsChanged = wire.items != specs || viewControllers?.count != wire.items.count
    specs = wire.items
    if itemsChanged || viewControllers == nil {
      viewControllers = wire.items.enumerated().map { index, spec in
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        controller.view.isUserInteractionEnabled = false
        controller.tabBarItem = barItem(spec, tag: index)
        return controller
      }
    } else if let controllers = viewControllers {
      for (index, spec) in wire.items.enumerated() where index < controllers.count {
        controllers[index].tabBarItem = barItem(spec, tag: index)
      }
    }
    applyChrome(wire)
    applyingRemote = true
    selectedIndex = wire.currentIndex
    applyingRemote = false
    onChromeChanged?()
  }

  func tabBarController(
    _ tabBarController: UITabBarController,
    shouldSelect viewController: UIViewController
  ) -> Bool {
    guard let index = viewControllers?.firstIndex(of: viewController) else { return false }
    guard index < specs.count else { return false }
    return specs[index].enabled
  }

  func tabBarController(
    _ tabBarController: UITabBarController,
    didSelect viewController: UIViewController
  ) {
    guard !applyingRemote else { return }
    guard let index = viewControllers?.firstIndex(of: viewController) else { return }
    onSelect?(index)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    view.backgroundColor = .clear
    view.isOpaque = false
    if #available(iOS 18.0, *) {
      // Stay a tab bar on iPad. Automatic would become a sidebar and drop
      // the gallery's four destinations. Duo / 27.1 can still move this
      // tab bar to the side; that is the system tab bar, not the sidebar mode.
      mode = .tabBar
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    view.backgroundColor = .clear
    onChromeChanged?()
  }

  private func applyChrome(_ wire: LYTabBarWire) {
    if wire.tintedBar {
      let tint = wire.tint ?? UIColor.systemBlue
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = tint
      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = appearance
      tabBar.tintColor = .white
      tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.72)
      didCustomizeAppearance = true
      return
    }
    // Do not assign a background unless a tinted bar is leaving.
    // configureWithDefaultBackground opts out of iOS 26 Liquid Glass.
    // With the appearance left alone, UITabBarController floats the bar
    // and can move it to the side on iOS 27.1.
    if didCustomizeAppearance {
      let appearance = UITabBarAppearance()
      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = appearance
      didCustomizeAppearance = false
    }
    tabBar.tintColor = wire.tint
    tabBar.unselectedItemTintColor = nil
  }

  private func barItem(_ spec: LYTabBarItemSpec, tag: Int) -> UITabBarItem {
    let symbol = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    let selectedSymbol = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    let image = UIImage(systemName: spec.systemImage, withConfiguration: symbol)
      ?? UIImage(systemName: "circle", withConfiguration: symbol)
    let selected = UIImage(systemName: spec.selectedSystemImage, withConfiguration: selectedSymbol)
      ?? image
    let item = UITabBarItem(title: spec.label, image: image, selectedImage: selected)
    item.tag = tag
    item.badgeValue = spec.badge
    item.isEnabled = spec.enabled
    return item
  }
}

/// Platform view. Hits land on the tab bar only; the rest return nil so
/// Flutter receives the workbench and the pushed demos.
final class LYTabBarContainerView: UIView {
  let controller: LYSystemTabBarController

  init(controller: LYSystemTabBarController) {
    self.controller = controller
    super.init(frame: .zero)
    backgroundColor = .clear
    isOpaque = false
    insetsLayoutMarginsFromSafeArea = false
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
    if controller.parent == nil {
      attach()
    }
    if controller.view.superview !== self {
      addSubview(controller.view)
    }
    controller.view.frame = bounds
    controller.view.backgroundColor = .clear
    controller.view.isOpaque = false
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hit = super.hitTest(point, with: event)
    guard let hit, hit !== self else { return nil }
    if isTabChrome(hit) { return hit }
    return nil
  }

  override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    controller.onChromeChanged?()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    controller.onChromeChanged?()
  }

  private func attach() {
    guard controller.parent == nil, let parent = nearestViewController() else { return }
    parent.addChild(controller)
    addSubview(controller.view)
    controller.view.frame = bounds
    controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    controller.didMove(toParent: parent)
  }

  private func detach() {
    guard controller.parent != nil else {
      controller.view.removeFromSuperview()
      return
    }
    controller.willMove(toParent: nil)
    controller.view.removeFromSuperview()
    controller.removeFromParent()
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

  private func isTabChrome(_ view: UIView) -> Bool {
    let bar = controller.tabBar
    if !bar.isHidden, view === bar || view.isDescendant(of: bar) {
      return true
    }
    var current: UIView? = view
    while let node = current, node !== self {
      let name = String(describing: type(of: node))
      if name.contains("TabBar") || name.contains("TabGroup") || name.contains("Sidebar") {
        return true
      }
      if node === controller.view { break }
      current = node.superview
    }
    return false
  }

  func chromePayload() -> [String: Any] {
    let frame = chromeFrame()
    return [
      "edge": edge(for: frame),
      "x": frame.minX,
      "y": frame.minY,
      "width": frame.width,
      "height": frame.height,
    ]
  }

  private func chromeFrame() -> CGRect {
    let bar = controller.tabBar
    if !bar.isHidden, bar.bounds.width > 1, bar.bounds.height > 1 {
      return bar.convert(bar.bounds, to: self)
    }
    var best: CGRect?
    var bestArea: CGFloat = 0
    for subview in controller.view.subviews {
      let name = String(describing: type(of: subview))
      let chrome = name.contains("Tab") || name.contains("Sidebar") || name.contains("Platter")
      guard chrome else { continue }
      let frame = subview.convert(subview.bounds, to: self)
      let area = frame.width * frame.height
      if area > bestArea {
        best = frame
        bestArea = area
      }
    }
    return best ?? bar.convert(bar.bounds, to: self)
  }

  private func edge(for frame: CGRect) -> String {
    let bounds = self.bounds
    guard bounds.width > 0, bounds.height > 0, frame.width > 1, frame.height > 1 else {
      return "bottom"
    }
    let verticalBar = frame.height > frame.width && frame.height > bounds.height * 0.45
    if verticalBar {
      let midX = frame.midX
      let onLeading: Bool
      if effectiveUserInterfaceLayoutDirection == .rightToLeft {
        onLeading = midX > bounds.midX
      } else {
        onLeading = midX <= bounds.midX
      }
      return onLeading ? "leading" : "trailing"
    }
    if frame.midY < bounds.height * 0.35 {
      return "top"
    }
    return "bottom"
  }
}

final class LYTabBarPlatformView: NSObject, FlutterPlatformView {
  private let container: LYTabBarContainerView
  private let channel: FlutterMethodChannel
  private var lastPayload: [String: Any]?

  init(
    frame: CGRect,
    viewId: Int64,
    args: [String: Any]?,
    messenger: FlutterBinaryMessenger
  ) {
    let controller = LYSystemTabBarController()
    container = LYTabBarContainerView(controller: controller)
    container.frame = frame
    channel = FlutterMethodChannel(
      name: "lingyun_ui_flutter/ly_tab_bar_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()
    controller.onSelect = { [weak self] index in
      self?.channel.invokeMethod("select", arguments: index)
    }
    controller.onChromeChanged = { [weak self] in
      self?.publishChrome()
    }
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "released", message: "LYTabBar view released", details: nil))
        return
      }
      switch call.method {
      case "update":
        let arguments = call.arguments as? [String: Any]
        self.container.controller.apply(LYTabBarWire.decode(arguments))
        self.publishChrome()
        result(nil)
      case "snapshot":
        result(self.container.chromePayload())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    controller.apply(LYTabBarWire.decode(args))
  }

  func view() -> UIView {
    container
  }

  private func publishChrome() {
    let payload = container.chromePayload()
    if let lastPayload, payloadsEqual(lastPayload, payload) { return }
    lastPayload = payload
    channel.invokeMethod("metrics", arguments: payload)
  }
}

private func payloadsEqual(_ lhs: [String: Any], _ rhs: [String: Any]) -> Bool {
  guard lhs.count == rhs.count else { return false }
  for (key, value) in lhs {
    guard let other = rhs[key] else { return false }
    if "\(value)" != "\(other)" { return false }
  }
  return true
}

private func nonEmpty(_ value: String?) -> String? {
  let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  return trimmed.isEmpty ? nil : trimmed
}

private func badgeValue(_ value: Any?) -> String? {
  guard let text = value as? String else { return nil }
  return text.isEmpty ? " " : text
}

private func intValue(_ value: Any?) -> Int? {
  if let int = value as? Int { return int }
  if let number = value as? NSNumber { return number.intValue }
  return nil
}

private func colorValue(_ value: Any?) -> UIColor? {
  let raw = intValue(value)
  guard let raw else { return nil }
  let alpha = CGFloat((raw >> 24) & 0xFF) / 255
  let red = CGFloat((raw >> 16) & 0xFF) / 255
  let green = CGFloat((raw >> 8) & 0xFF) / 255
  let blue = CGFloat(raw & 0xFF) / 255
  return UIColor(red: red, green: green, blue: blue, alpha: alpha == 0 ? 1 : alpha)
}
