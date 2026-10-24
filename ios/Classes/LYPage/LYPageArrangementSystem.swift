import SwiftUI
import UIKit

/// Arrangement entry used by the scaffold.
///
/// The system types live in `LYPageSystemArrangementHost` and are compiled
/// only with `LY_IOS_27_1_SDK`. The fallback lists both roles in a
/// `NavigationStack` and does not draw a hinge.
struct LYPageArrangementHost: View {
  @ObservedObject var session: LYPageSession

  var body: some View {
    #if LY_IOS_27_1_SDK
    NavigationStack {
      LYPageSystemArrangementHost(navigation: session.spec.navigation) {
        LYPagePane(role: session.spec.primaryLabel, session: session)
      } secondary: {
        LYPagePane(role: session.spec.secondaryLabel, session: session)
      }
      .navigationTitle(session.spec.primaryLabel)
    }
    #else
    NavigationStack {
      LYPageArrangementUnavailable(session: session)
        .navigationTitle(session.spec.primaryLabel)
    }
    #endif
  }
}

struct LYPageArrangementUnavailable: View {
  @ObservedObject var session: LYPageSession

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        Text("ArrangementView is not linked")
          .font(.title3)
        Text(LYPageContainer.arrangementNote)
          .font(.footnote)
        Text("Primary: \(session.spec.primaryLabel)")
        Text("Secondary: \(session.spec.secondaryLabel)")
        Text(LYPagePaneCopy.safeArea)
          .font(.footnote)
        Text(LYPagePaneCopy.regionsUnavailable)
          .font(.footnote)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
    }
    .background(LYPageContentSafeAreaProbe(session: session))
  }
}

#if LY_IOS_27_1_SDK
/// System `ArrangementView` sample. Apple documents the trailing-closure
/// initializer and `.arrangementViewStyle(.split | .overlay)`.
/// Axis choice stays with the system.
struct LYPageSystemArrangementHost<Primary: View, Secondary: View>: View {
  let navigation: LYPageNavigation
  @ViewBuilder var primary: () -> Primary
  @ViewBuilder var secondary: () -> Secondary

  var body: some View {
    switch navigation {
    case .arrangementOverlay:
      ArrangementView {
        primary()
      } secondary: {
        secondary()
      }
      .arrangementViewStyle(.overlay)
    default:
      ArrangementView {
        primary()
      } secondary: {
        secondary()
      }
      .arrangementViewStyle(.split)
    }
  }
}

/// UIKit sample for add-to-app hosts. Not used by the SwiftUI platform view.
/// `UINavigationController` wraps the arrangement; the arrangement does not
/// wrap a navigation split or a tab controller.
enum LYPageUIKitArrangement {
  @MainActor
  static func makeNavigationController(
    overlay: Bool,
    primary: UIViewController,
    secondary: UIViewController
  ) -> UINavigationController {
    let arrangement = UIArrangementViewController()
    arrangement.setViewController(
      primary,
      for: UIArrangementViewController.ViewPlacement.primary
    )
    arrangement.setViewController(
      secondary,
      for: UIArrangementViewController.ViewPlacement.secondary
    )
    if overlay {
      arrangement.updateArrangement(UIOverlayArrangement())
    } else {
      arrangement.updateArrangement(UISplitArrangement())
    }
    return UINavigationController(rootViewController: arrangement)
  }
}
#endif
