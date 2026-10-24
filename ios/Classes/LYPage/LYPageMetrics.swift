import CoreGraphics
import UIKit

/// Width buckets from the plan. `wideMinimumPoints` matches Dart
/// `LingyunBreakpoints.large`. It is not an iOS kit token.
enum LYPageBreakpoints {
  static let wideMinimumPoints: CGFloat = 1200
}

enum LYPageWidthBucket: String, Equatable {
  case compact
  case regular
  case wide

  /// Compact comes only from a compact horizontal size class.
  /// Wide is a regular (or unspecified) class whose available width reaches
  /// `LYPageBreakpoints.wideMinimumPoints`. Vertical size class is ignored.
  static func resolve(
    horizontal: UIUserInterfaceSizeClass,
    availableWidth: CGFloat
  ) -> LYPageWidthBucket {
    switch horizontal {
    case .compact:
      return .compact
    case .regular, .unspecified:
      if availableWidth >= LYPageBreakpoints.wideMinimumPoints {
        return .wide
      }
      return .regular
    @unknown default:
      if availableWidth >= LYPageBreakpoints.wideMinimumPoints {
        return .wide
      }
      return .regular
    }
  }
}

enum LYPageSizeClassName: String, Equatable {
  case compact
  case regular
  case unspecified

  init(_ sizeClass: UIUserInterfaceSizeClass) {
    switch sizeClass {
    case .compact:
      self = .compact
    case .regular:
      self = .regular
    case .unspecified:
      self = .unspecified
    @unknown default:
      self = .unspecified
    }
  }
}

struct LYPageRegionSnapshot: Equatable {
  var kind: String
  var isActive: Bool
  var x: CGFloat
  var y: CGFloat
  var width: CGFloat
  var height: CGFloat

  func encode() -> [String: Any] {
    [
      "kind": kind,
      "isActive": isActive,
      "x": x,
      "y": y,
      "width": width,
      "height": height,
    ]
  }
}

struct LYPageEdgeInsets: Equatable {
  var leading: CGFloat
  var trailing: CGFloat
  var top: CGFloat
  var bottom: CGFloat
  var left: CGFloat
  var right: CGFloat

  static let zero = LYPageEdgeInsets(
    leading: 0, trailing: 0, top: 0, bottom: 0, left: 0, right: 0
  )

  static func host(
    insets: UIEdgeInsets,
    layoutDirection: UIUserInterfaceLayoutDirection
  ) -> LYPageEdgeInsets {
    let leading: CGFloat
    let trailing: CGFloat
    if layoutDirection == .rightToLeft {
      leading = insets.right
      trailing = insets.left
    } else {
      leading = insets.left
      trailing = insets.right
    }
    return LYPageEdgeInsets(
      leading: leading,
      trailing: trailing,
      top: insets.top,
      bottom: insets.bottom,
      left: insets.left,
      right: insets.right
    )
  }
}

/// Live geometry for one platform view. Bounds and traits come from that
/// view, not from a screen singleton.
struct LYPageMetrics: Equatable {
  var widthBucket: LYPageWidthBucket
  var horizontalSizeClass: LYPageSizeClassName
  var verticalSizeClass: LYPageSizeClassName
  var boundsWidth: CGFloat
  var boundsHeight: CGFloat
  var hostSafeArea: LYPageEdgeInsets
  var contentSafeArea: LYPageEdgeInsets
  var arrangementLinked: Bool
  var reservedRegionsSupported: Bool
  var regions: [LYPageRegionSnapshot]

  static let empty = LYPageMetrics(
    widthBucket: .regular,
    horizontalSizeClass: .unspecified,
    verticalSizeClass: .unspecified,
    boundsWidth: 0,
    boundsHeight: 0,
    hostSafeArea: .zero,
    contentSafeArea: .zero,
    arrangementLinked: LYPageSDK.arrangementLinked,
    reservedRegionsSupported: false,
    regions: []
  )
}

enum LYPageSDK {
  static var arrangementLinked: Bool {
    #if LY_IOS_27_1_SDK
    return true
    #else
    return false
    #endif
  }
}
