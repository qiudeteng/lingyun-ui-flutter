import 'package:flutter/painting.dart';

/// Material thickness for Liquid Glass surfaces.
///
/// Inspired by the iOS 27 Liquid Glass material stack, but this enum is a
/// **visual recipe**, not a UIKit / AppKit type. The same three tiers render
/// on iPhone, foldables, iPad, macOS, and web.
///
/// Sketch / kit counterparts (descriptive labels only — not an official API):
/// * [thin] ≈ Liquid Glass **Clear** / Regular Small (more wallpaper shows)
/// * [regular] ≈ Liquid Glass **Regular** Large / Medium
/// * [thick] ≈ Widget Glass / elevated chrome / dense desktop sheets
enum GlassMaterialTier {
  /// Light frost — more of the wallpaper / content shows through.
  /// Typical uses: compact toolbars, inline chips, hover previews.
  thin,

  /// Default panel / card material.
  regular,

  /// Heavier frost for elevated chrome, sheets, and sidebars.
  thick,
}

/// Corner-radius scale for glass surfaces.
///
/// Sketch counterparts (descriptive labels only — not an official API):
/// * [large] ≈ Liquid Glass Regular **Large** (kit measures 34pt)
/// * [medium] ≈ mid-size nested panels (26pt). Kit Regular Medium measures
///   the same 34pt as Large; we keep a tighter mid step so cards can nest.
/// * [small] ≈ compact chrome (18pt). Kit Regular Small is often a 48pt
///   capsule — use a stadium [BorderRadius] for pills.
enum GlassRadiusScale {
  /// Compact chrome / chips.
  small,

  /// Nested cards and mid-size panels.
  medium,

  /// Sheets, prominent cards, Regular Large.
  large,
}

/// Logical-pixel corner radii for [GlassRadiusScale].
class LiquidGlassRadii {
  const LiquidGlassRadii._();

  /// Compact chrome. Sketch-adjacent: Regular Small (rectangular).
  static const double small = 18;

  /// Nested / mid-size panels.
  static const double medium = 26;

  /// Regular Large / sheets. Measured 34pt in the iOS 27 kit.
  static const double large = 34;

  static double value(GlassRadiusScale scale) {
    return switch (scale) {
      GlassRadiusScale.small => small,
      GlassRadiusScale.medium => medium,
      GlassRadiusScale.large => large,
    };
  }

  static BorderRadius borderRadius(GlassRadiusScale scale) {
    return BorderRadius.all(Radius.circular(value(scale)));
  }
}
