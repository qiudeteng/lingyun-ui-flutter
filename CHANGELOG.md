# Changelog

All notable changes to this project will be documented in this file.

## 0.1.0 — 2026-09-18

Phase 0 — materials, conventions, and multi-platform layout foundation.
No Phase 1+ components (buttons, etc.).

### Added

- `GlassMaterialTier` (`thin` / `regular` / `thick`) plus `LiquidGlassMaterials`
  light/dark sets; `GlassSurface.material` and `LiquidGlassTheme.tokensOf(..., tier:)`.
- Specular (top-leading face wash) and refraction (inner rim) tokens, documented
  in `LiquidGlassTokens` and README.
- `LiquidGlassMotion` curves; reduce-motion via `MediaQuery.disableAnimations`
  or `LingyunAdaptivity.reduceMotion`.
- `LingyunAdaptivity` for Reduce Transparency / Reduce Motion / high contrast;
  opaque `GlassSurface` fallback.
- `LingyunLayout` width classes (compact / regular / expanded / large),
  safe-area + layout margins, hinge/division band, wide-short cover heuristic,
  `LingyunLayoutBuilder`, `LingyunSideChrome`, `LingyunSplitBody`.
- Example gallery: colorful wallpaper; Materials, Themes, Layout (phone / Duo
  cover / Duo inner / iPad / macOS presets), Accessibility toggles.
- Multi-platform docs: iPhone, iPhone Duo, iPad, macOS. Example keeps ios,
  macos, web (android bonus).
- `GlassSurface` uses bounded `ImageFilter.blur` (iOS-style frosted glass,
  no neighbor bleed) plus a two-layer specular (face wash + top sheen).

### Public API (Phase 0)

- `GlassMaterialTier`, `LiquidGlassTokens`, `LiquidGlassMaterials`
- `LiquidGlassTheme`
- `GlassSurface`, `GlassCard`
- `LiquidGlassMotion`
- `LingyunAdaptivity`
- `LingyunWidthClass`, `LingyunBreakpoints`, `LingyunLayout`, `LingyunLayoutData`
- `LingyunLayoutBuilder`, `LingyunSideChrome`, `LingyunSplitBody`
