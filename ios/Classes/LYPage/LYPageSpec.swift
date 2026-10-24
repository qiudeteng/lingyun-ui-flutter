import Foundation

/// Business contract shared with Dart `LingyunPageSpec`.
///
/// Chrome and navigation describe content roles. There is no folded /
/// half-open / open pose for callers to switch on.
enum LYPageChrome: String, Equatable {
  case tab
  case sidebar
  case none

  init(wire: String?) {
    self = LYPageChrome(rawValue: wire ?? "") ?? .tab
  }
}

enum LYPageNavigation: String, Equatable {
  case stack
  case split
  case arrangementSplit
  case arrangementOverlay

  init(wire: String?) {
    self = LYPageNavigation(rawValue: wire ?? "") ?? .stack
  }

  var isArrangement: Bool {
    switch self {
    case .arrangementSplit, .arrangementOverlay:
      return true
    case .stack, .split:
      return false
    }
  }
}

struct LYPageSpec: Equatable {
  var chrome: LYPageChrome
  var navigation: LYPageNavigation
  var primaryLabel: String
  var secondaryLabel: String

  static let placeholder = LYPageSpec(
    chrome: .tab,
    navigation: .stack,
    primaryLabel: "Primary",
    secondaryLabel: "Secondary"
  )

  static func decode(_ args: [String: Any]?) -> LYPageSpec {
    let primary = (args?["primaryLabel"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let secondary = (args?["secondaryLabel"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    return LYPageSpec(
      chrome: LYPageChrome(wire: args?["chrome"] as? String),
      navigation: LYPageNavigation(wire: args?["navigation"] as? String),
      primaryLabel: (primary?.isEmpty == false) ? primary! : "Primary",
      secondaryLabel: (secondary?.isEmpty == false) ? secondary! : "Secondary"
    )
  }

  func encode() -> [String: String] {
    [
      "chrome": chrome.rawValue,
      "navigation": navigation.rawValue,
      "primaryLabel": primaryLabel,
      "secondaryLabel": secondaryLabel,
    ]
  }
}
