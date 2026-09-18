# Changelog

All notable changes to this project will be documented in this file.

## 0.2.0 — 2026-09-18

Split **Materials** and **Liquid Glass** into two named systems (Sketch /
iOS 27 kit). Old Thin→Clear / Thick→Widget Glass mappings are gone.

### Added

- `MaterialTier.ultrathin` plus `MaterialCatalog` (Light / Dark × four fills).
- `LiquidGlassStyle` / `LiquidGlassCatalog`: Clear, Regular Small / Medium /
  Large, Dock, Widget Glass.
- `LiquidGlassLabels` — Light Primary `#1A1A1A`, Dark Primary `#EDEDED`.
- `GlassButton` / `GlassButton.label` — default **Regular Small** (Clear
  optional). Materials Thick is not a button recipe.
- `LiquidGlassTheme.materialOf` / `styleOf`; theme now carries both catalogs.
- `GlassSurface.style` for Liquid Glass; `material` is Materials-only.
- Gallery **Glass** page; Materials page no longer prints blur / sat as kit
  values. Spec: `docs/SPEC.md`.

### Changed

- Rim is a shared ~0.5px hairline + Clear-like multi-layer specular. No
  0.55→0.85 thickening by tier.
- Radii 18 / 26 / 34 marked **待核验 (unverified vs Sketch)**.
- `blurSigma` / `saturation` documented as implementation approximations,
  not official Design Tokens.
- `LiquidGlassTheme.tokens` is Liquid Glass Regular Large (not Materials
  Regular). `tokensOf` resolves Materials.

### Deprecated

- `GlassMaterialTier` → `MaterialTier`
- `LiquidGlassMaterials` → `MaterialCatalog`

## 0.1.1 — 2026-09-18

Material fidelity pass against the public iOS 27 Sketch / Figma Liquid Glass
layer styles (Clear, Regular Large / Medium / Small, Widget Glass). Descriptive
labels only — not an official Apple API.

### Changed

- Retuned `LiquidGlassTokens` light/dark × thin/regular/thick: warmer Regular
  veil (~60–70%), quieter hairline, grey rim ring, multi-shadow (soft deep +
  crisp side hairlines), restrained saturation.
- `GlassSurface` compositing: luminosity/lighten overlay, inner-lip shadows,
  tight top-leading specular, directional inner refraction (not a double white
  border). Still `ImageFilter.blur` + `TileMode.clamp` — no `bounds` named param.
- Example gallery wallpaper is a muted system wash (light + dark) instead of
  neon orbs.

### Added

- `GlassRadiusScale` / `LiquidGlassRadii` (`small` 18 / `medium` 26 / `large` 34).
- `GlassSurface.radiusScale` / `borderRadius` and `LiquidGlassTokens.withRadiusScale`.
- Token fields: `overlayColor`, `overlayBlend`, `shadowSpread`, `rimColor`,
  `rimSpread`, `rimSideOffset`, `rimSideSpread`, `innerShadowColor`,
  `innerShadowExtent`, plus `shadows` getter.

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
