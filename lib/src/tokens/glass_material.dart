import 'package:flutter/painting.dart';

/// **A. Materials** — translucent fills in the content layer.
///
/// Official kit names (do **not** mix with [LiquidGlassStyle]):
/// Ultrathin / Thin / Regular / Thick, each Light + Dark.
///
/// These are **not** Liquid Glass styles. Thick is reserved for Sheet /
/// Sidebar chrome — never the default button treatment.
///
/// Inspired by the iOS / iPadOS standard material stack, but this enum
/// is a visual recipe, not a UIKit / AppKit type.
enum MaterialTier {
  /// Lightest content-layer frost. Most of the wallpaper shows through.
  ultrathin,

  /// Light frost — compact content chrome, inline grouping.
  thin,

  /// Default content-layer fill (not a Liquid Glass Regular style).
  regular,

  /// Heaviest fill. **Sheet / Sidebar chrome only** — not buttons.
  thick,
}

/// Official Materials kit label (Ultrathin / Thin / Regular / Thick).
extension MaterialTierKit on MaterialTier {
  String get kitName => switch (this) {
    MaterialTier.ultrathin => 'Ultrathin',
    MaterialTier.thin => 'Thin',
    MaterialTier.regular => 'Regular',
    MaterialTier.thick => 'Thick',
  };

  String get usage => switch (this) {
    MaterialTier.ultrathin =>
      'Lightest content fill; wallpaper-forward grouping.',
    MaterialTier.thin => 'Light content frost; inline grouping.',
    MaterialTier.regular => 'Default content-layer separation.',
    MaterialTier.thick => 'Sheet / Sidebar chrome — not default buttons.',
  };
}

/// @nodoc Backward-compatible alias. Prefer [MaterialTier].
@Deprecated(
  'Use MaterialTier. GlassMaterialTier mixed Materials fills with '
  'Liquid Glass style names (Clear / Regular Large / Widget Glass).',
)
typedef GlassMaterialTier = MaterialTier;

/// Corner-radius scale for glass and material surfaces.
///
/// Values 18 / 26 / 34 are **待核验 (unverified vs Sketch)** until measured
/// in the official Sketch UI Kit. They are working steps, not kit tokens.
enum GlassRadiusScale {
  /// Compact chrome / chips.
  small,

  /// Nested cards and mid-size panels.
  medium,

  /// Sheets, prominent cards, Regular Large-sized panels.
  large,
}

/// Logical-pixel corner radii for [GlassRadiusScale].
///
/// **待核验 (unverified vs Sketch):** 18 / 26 / 34 are retained as useful
/// working steps. Do not treat them as official Design Tokens until they
/// are measured in
/// https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02
class LiquidGlassRadii {
  const LiquidGlassRadii._();

  /// Compact rectangular chrome.
  ///
  /// **待核验 (unverified vs Sketch)** — 18 is a working step. Kit Regular
  /// Small is often a 48pt capsule; use a stadium [BorderRadius] for pills
  /// (see [GlassButton]).
  static const double small = 18;

  /// Nested / mid-size panels.
  ///
  /// **待核验 (unverified vs Sketch)** — 26 is a working mid step. Some
  /// public kit notes measure Regular Medium at the same 34 as Large.
  static const double medium = 26;

  /// Regular Large / sheets.
  ///
  /// **待核验 (unverified vs Sketch)** — 34 matches some public kit notes
  /// for Regular Large, but is not yet verified in this repo's Sketch file.
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
