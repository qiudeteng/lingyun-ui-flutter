import Foundation

/// Which system container `LYPage` mounts.
///
/// Keep this in sync with Dart `resolveLingyunPageContainer`.
struct LYPageContainer: Equatable {
  var root: String
  var wrapsTabView: Bool
  var wrapsSplitView: Bool
  var usesArrangement: Bool
  var columns: Int
  var chromeApplied: Bool
  var note: String

  static let arrangementNote =
    "ArrangementView stays outside TabView and NavigationSplitView. "
    + "A NavigationStack may wrap the arrangement. "
    + "The iOS 27.1 compile flag LY_IOS_27_1_SDK links the system type. "
    + "Without it this host does not invent a hinge layout."

  static let splitNote =
    "NavigationSplitView collapses to one column when the horizontal size "
    + "class is compact. Wide (regular, and available width >= "
    + "LingyunBreakpoints.large) adds a third column only when chrome is "
    + "sidebar. Tab chrome keeps two columns so the tab bar is not also a sidebar."

  static let tabNote =
    "TabView is the system tab bar. On an iOS 27.1 build it may sit on the "
    + "side. Content uses each safe-area edge and does not assume a bottom dock."

  static let stackNote =
    "NavigationStack fills the available bounds. Safe area is per edge."

  static func resolve(spec: LYPageSpec, bucket: LYPageWidthBucket) -> LYPageContainer {
    if spec.navigation.isArrangement {
      return LYPageContainer(
        root: "ArrangementView",
        wrapsTabView: false,
        wrapsSplitView: false,
        usesArrangement: true,
        columns: 0,
        chromeApplied: false,
        note: arrangementNote
      )
    }

    let sidebar = spec.chrome == .sidebar
    let split = spec.navigation == .split || sidebar

    if spec.chrome == .tab {
      if split {
        return LYPageContainer(
          root: "TabView",
          wrapsTabView: true,
          wrapsSplitView: true,
          usesArrangement: false,
          columns: splitColumns(bucket, allowThree: false),
          chromeApplied: true,
          note: tabNote + " " + splitNote
        )
      }
      return LYPageContainer(
        root: "TabView",
        wrapsTabView: true,
        wrapsSplitView: false,
        usesArrangement: false,
        columns: 1,
        chromeApplied: true,
        note: tabNote
      )
    }

    if split {
      return LYPageContainer(
        root: "NavigationSplitView",
        wrapsTabView: false,
        wrapsSplitView: true,
        usesArrangement: false,
        columns: splitColumns(bucket, allowThree: sidebar),
        chromeApplied: sidebar,
        note: splitNote
      )
    }

    return LYPageContainer(
      root: "NavigationStack",
      wrapsTabView: false,
      wrapsSplitView: false,
      usesArrangement: false,
      columns: 1,
      chromeApplied: false,
      note: stackNote
    )
  }

  /// Reported column count after the system collapses a split.
  /// The mounted view is still `NavigationSplitView` for split requests.
  static func splitColumns(_ bucket: LYPageWidthBucket, allowThree: Bool) -> Int {
    switch bucket {
    case .compact:
      return 1
    case .regular:
      return 2
    case .wide:
      return allowThree ? 3 : 2
    }
  }
}
