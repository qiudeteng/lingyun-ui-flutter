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
    "ArrangementView 放在 TabView 和 NavigationSplitView 外面。"
    + "NavigationStack 可以包住排列。"
    + "iOS 27.1 的编译标记 LY_IOS_27_1_SDK 才会链接系统类型。"
    + "没有这个标记时，宿主不会自己编一套铰链布局。"

  static let splitNote =
    "水平尺寸类别为紧凑时，NavigationSplitView 收成一列。"
    + "宽屏（已经是常规，且可用宽度至少 LingyunBreakpoints.large）"
    + "只有饰条是侧栏时才加第三列。标签饰条保持两列，避免标签栏再变成一条侧栏。"

  static let tabNote =
    "TabView 是系统标签栏。在 iOS 27.1 上它可能贴在侧面。"
    + "内容按每一边的安全区留白，不假设底栏程序坞。"

  static let stackNote =
    "NavigationStack 铺满可用范围。安全区按每一边计算。"

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
