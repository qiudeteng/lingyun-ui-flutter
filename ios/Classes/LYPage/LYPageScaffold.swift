import SwiftUI
import UIKit

/// SwiftUI page shell. System containers adapt; this view does not switch
/// on vertical size class.
struct LYPageScaffold: View {
  @ObservedObject var session: LYPageSession

  var body: some View {
    let container = LYPageContainer.resolve(
      spec: session.spec,
      bucket: session.metrics.widthBucket
    )
    ZStack {
      Color(.systemBackground)
        .ignoresSafeArea()
      mounted(container)
    }
    .background(LYPageReservedRegionReader(session: session))
  }

  @ViewBuilder
  private func mounted(_ container: LYPageContainer) -> some View {
    if container.usesArrangement {
      LYPageArrangementHost(session: session)
    } else if container.wrapsTabView {
      LYPageTabHost(session: session, split: container.wrapsSplitView)
    } else if container.wrapsSplitView {
      LYPageSplitHost(
        session: session,
        columns: LYPageContainer.splitColumns(
          session.metrics.widthBucket,
          allowThree: session.spec.chrome == .sidebar
        ),
        sidebar: session.spec.chrome == .sidebar
      )
    } else {
      NavigationStack {
        LYPagePane(role: session.spec.primaryLabel, session: session)
          .navigationTitle(session.spec.primaryLabel)
      }
    }
  }
}

struct LYPageTabHost: View {
  @ObservedObject var session: LYPageSession
  var split: Bool

  var body: some View {
    TabView {
      tabRoot(role: session.spec.primaryLabel)
        .tabItem {
          Label(session.spec.primaryLabel, systemImage: "rectangle.split.2x1")
        }
        .tag(0)
      tabRoot(role: session.spec.secondaryLabel)
        .tabItem {
          Label(session.spec.secondaryLabel, systemImage: "rectangle.trailinghalf.inset.filled")
        }
        .tag(1)
    }
  }

  @ViewBuilder
  private func tabRoot(role: String) -> some View {
    if split {
      NavigationSplitView {
        LYPagePane(role: role, session: session)
          .navigationTitle(role)
      } detail: {
        LYPagePane(role: session.spec.secondaryLabel, session: session)
          .navigationTitle(session.spec.secondaryLabel)
      }
    } else {
      NavigationStack {
        LYPagePane(role: role, session: session)
          .navigationTitle(role)
      }
    }
  }
}

struct LYPageSplitHost: View {
  @ObservedObject var session: LYPageSession
  var columns: Int
  var sidebar: Bool

  var body: some View {
    if sidebar && columns >= 3 {
      NavigationSplitView {
        sidebarColumn
      } content: {
        LYPagePane(role: session.spec.primaryLabel, session: session)
          .navigationTitle(session.spec.primaryLabel)
      } detail: {
        LYPagePane(role: session.spec.secondaryLabel, session: session)
          .navigationTitle(session.spec.secondaryLabel)
      }
    } else if sidebar {
      NavigationSplitView {
        sidebarColumn
      } detail: {
        NavigationStack {
          LYPagePane(role: session.spec.primaryLabel, session: session)
            .navigationTitle(session.spec.primaryLabel)
        }
      }
    } else {
      NavigationSplitView {
        LYPagePane(role: session.spec.primaryLabel, session: session)
          .navigationTitle(session.spec.primaryLabel)
      } detail: {
        LYPagePane(role: session.spec.secondaryLabel, session: session)
          .navigationTitle(session.spec.secondaryLabel)
      }
    }
  }

  private var sidebarColumn: some View {
    List {
      Text(session.spec.primaryLabel)
      Text(session.spec.secondaryLabel)
    }
    .navigationTitle("侧栏")
  }
}

struct LYPagePane: View {
  let role: String
  @ObservedObject var session: LYPageSession

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 10) {
        Text(role)
          .font(.title2)
        Text(summary)
          .font(.footnote)
          .foregroundStyle(.secondary)
        Text(LYPagePaneCopy.safeArea)
          .font(.footnote)
        Text(regionCopy)
          .font(.footnote)
        Text(containerNote)
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
    }
    .background(Color(.secondarySystemBackground))
    .background(LYPageContentSafeAreaProbe(session: session))
    .accessibilityIdentifier("ly-page-pane")
  }

  private var summary: String {
    let metrics = session.metrics
    let host = metrics.hostSafeArea
    let content = metrics.contentSafeArea
    return """
    宽度档 \(bucketLabel(metrics.widthBucket)) \
    水平 \(sizeClassLabel(metrics.horizontalSizeClass)) \
    垂直 \(sizeClassLabel(metrics.verticalSizeClass))
    范围 \(format(metrics.boundsWidth))×\(format(metrics.boundsHeight)) pt
    宿主安全区 左上右下 \
    \(format(host.leading)) \(format(host.top)) \
    \(format(host.trailing)) \(format(host.bottom))
    内容安全区 左上右下 \
    \(format(content.leading)) \(format(content.top)) \
    \(format(content.trailing)) \(format(content.bottom))
    """
  }

  private func bucketLabel(_ bucket: LYPageWidthBucket) -> String {
    switch bucket {
    case .compact: return "紧凑"
    case .regular: return "常规"
    case .wide: return "宽屏"
    }
  }

  private func sizeClassLabel(_ name: LYPageSizeClassName) -> String {
    switch name {
    case .compact: return "紧凑"
    case .regular: return "常规"
    case .unspecified: return "未指定"
    }
  }

  private var regionCopy: String {
    let metrics = session.metrics
    if !metrics.reservedRegionsSupported {
      return LYPagePaneCopy.regionsUnavailable
    }
    if metrics.regions.isEmpty {
      return LYPagePaneCopy.regionsEmpty
    }
    return metrics.regions.map { region in
      let state = region.isActive ? "激活" : "未激活"
      return "\(regionKindLabel(region.kind)) \(state) \
        横 \(format(region.x)) 纵 \(format(region.y)) \
        \(format(region.width))×\(format(region.height))"
    }.joined(separator: "\n")
  }

  private func regionKindLabel(_ kind: String) -> String {
    switch kind {
    case "division": return "分割"
    case "occlusion": return "遮挡"
    default: return kind
    }
  }

  private var containerNote: String {
    LYPageContainer.resolve(
      spec: session.spec,
      bucket: session.metrics.widthBucket
    ).note
  }

  private func format(_ value: CGFloat) -> String {
    String(format: "%.1f", value)
  }
}

enum LYPagePaneCopy {
  static let safeArea =
    "内容在每一边都留在安全区内。系统把标签栏或工具栏放到侧面时，"
    + "前缘或后缘的内边距会变大。这个骨架不加固定的底部内边距。"

  static let regionsUnavailable =
    "当前二进制读不到预留区域。请用 iOS 27.1 SDK，并打开 LY_IOS_27_1_SDK，"
    + "才能查询分割和遮挡。"

  static let regionsEmpty =
    "没有预留区域和这个视图相交。处于激活状态的分割区域就是铰链。"
    + "半开和全开都是常规。外屏折叠是紧凑。"
}

/// Reads the safe area the pane actually sees, inside the system container.
struct LYPageContentSafeAreaProbe: View {
  @ObservedObject var session: LYPageSession

  var body: some View {
    GeometryReader { proxy in
      Color.clear
        .onAppear { push(proxy.safeAreaInsets) }
        .onChange(of: proxy.size) { _ in
          push(proxy.safeAreaInsets)
        }
        .onChange(of: proxy.safeAreaInsets) { insets in
          push(insets)
        }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func push(_ insets: EdgeInsets) {
    session.updateContentSafeArea(
      LYPageEdgeInsets(
        leading: insets.leading,
        trailing: insets.trailing,
        top: insets.top,
        bottom: insets.bottom,
        left: 0,
        right: 0
      )
    )
  }
}
