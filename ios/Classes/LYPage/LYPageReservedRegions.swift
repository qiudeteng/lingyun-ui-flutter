import SwiftUI

/// Queries division (hinge) and occlusion (camera) regions when the
/// iOS 27.1 SDK flag is set. Frames stay in this view's coordinates.
struct LYPageReservedRegionReader: View {
  @ObservedObject var session: LYPageSession

  var body: some View {
    GeometryReader { proxy in
      Color.clear
        .onAppear { publish(proxy) }
        .onChange(of: proxy.size) { _ in
          publish(proxy)
        }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func publish(_ proxy: GeometryProxy) {
    #if LY_IOS_27_1_SDK
    let division = proxy.reservedRegions(
      kind: .division,
      options: .includeInactive
    )
    let occlusion = proxy.reservedRegions(
      kind: .occlusion,
      options: .includeInactive
    )
    var regions: [LYPageRegionSnapshot] = []
    regions.append(contentsOf: division.map { snapshot(kind: "division", region: $0) })
    regions.append(contentsOf: occlusion.map { snapshot(kind: "occlusion", region: $0) })
    session.updateRegions(regions, supported: true)
    #else
    _ = proxy.size
    session.updateRegions([], supported: false)
    #endif
  }

  #if LY_IOS_27_1_SDK
  private func snapshot(kind: String, region: ReservedRegion) -> LYPageRegionSnapshot {
    LYPageRegionSnapshot(
      kind: kind,
      isActive: region.isActive,
      x: region.frame.origin.x,
      y: region.frame.origin.y,
      width: region.frame.size.width,
      height: region.frame.size.height
    )
  }
  #endif
}
