/// Material thickness for Liquid Glass surfaces.
///
/// Inspired by the iOS 27 Liquid Glass material stack, but this enum is a
/// **visual recipe**, not a UIKit / AppKit type. The same three tiers render
/// on iPhone, foldables, iPad, macOS, and web.
enum GlassMaterialTier {
  /// Light frost — more of the wallpaper / content shows through.
  /// Typical uses: compact toolbars, inline chips, hover previews.
  thin,

  /// Default panel / card material.
  regular,

  /// Heavier frost for elevated chrome, sheets, and sidebars.
  thick,
}
