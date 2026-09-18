/// **B. Liquid Glass** — kit styles for the floating controls / chrome layer.
///
/// Official kit names (do **not** mix with [MaterialTier]):
/// Clear / Regular Small · Medium · Large / Dock / Widget Glass.
/// Light / Dark where applicable.
///
/// These are **not** Materials tiers. Button default is [regularSmall]
/// (or [clear] over rich media). Materials Thick is never a button style.
enum LiquidGlassStyle {
  /// Highly translucent glass for rich media backgrounds.
  clear,

  /// Compact control glass. **Button default.**
  regularSmall,

  /// Mid-size Regular glass (nested panels / grouped controls).
  regularMedium,

  /// Large Regular glass (prominent panels).
  regularLarge,

  /// Dock / floating-bar glass.
  dock,

  /// Widget tile glass.
  widgetGlass,
}

/// Official Liquid Glass kit label.
extension LiquidGlassStyleKit on LiquidGlassStyle {
  String get kitName => switch (this) {
    LiquidGlassStyle.clear => 'Clear',
    LiquidGlassStyle.regularSmall => 'Regular Small',
    LiquidGlassStyle.regularMedium => 'Regular Medium',
    LiquidGlassStyle.regularLarge => 'Regular Large',
    LiquidGlassStyle.dock => 'Dock',
    LiquidGlassStyle.widgetGlass => 'Widget Glass',
  };

  String get usage => switch (this) {
    LiquidGlassStyle.clear =>
      'Over rich media. Alternate button style when wallpaper must stay vivid.',
    LiquidGlassStyle.regularSmall => 'Default button / compact control glass.',
    LiquidGlassStyle.regularMedium =>
      'Nested glass panels and grouped controls.',
    LiquidGlassStyle.regularLarge =>
      'Prominent glass panels (not Materials Regular).',
    LiquidGlassStyle.dock => 'Dock / floating-bar chrome.',
    LiquidGlassStyle.widgetGlass => 'Home-screen-style widget tiles.',
  };
}
