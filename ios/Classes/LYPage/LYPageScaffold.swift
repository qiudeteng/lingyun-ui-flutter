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
    .navigationTitle("Sidebar")
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
    Bucket \(metrics.widthBucket.rawValue) \
    H \(metrics.horizontalSizeClass.rawValue) \
    V \(metrics.verticalSizeClass.rawValue)
    Bounds \(format(metrics.boundsWidth))×\(format(metrics.boundsHeight)) pt
    Host safe LTRB \
    \(format(host.leading)) \(format(host.top)) \
    \(format(host.trailing)) \(format(host.bottom))
    Content safe LTRB \
    \(format(content.leading)) \(format(content.top)) \
    \(format(content.trailing)) \(format(content.bottom))
    """
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
      let state = region.isActive ? "active" : "inactive"
      return "\(region.kind) \(state) \
        x \(format(region.x)) y \(format(region.y)) \
        \(format(region.width))×\(format(region.height))"
    }.joined(separator: "\n")
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
    "Content stays in the safe area on every edge. When the system places "
    + "the tab bar or toolbar on the side, the leading or trailing inset "
    + "grows. This skeleton does not add a fixed bottom inset."

  static let regionsUnavailable =
    "Reserved regions are not readable in this binary. Build with the "
    + "iOS 27.1 SDK and LY_IOS_27_1_SDK to query division and occlusion."

  static let regionsEmpty =
    "No reserved regions intersect this view. An active division is the "
    + "hinge. Half-open and fully open stay Regular. Folded outer stays Compact."
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
