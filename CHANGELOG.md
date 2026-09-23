# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Changed

- Gallery **Tabs** page adds a floating pill with 4 items. It uses the same 352pt cap as the 5-item pill.

## 0.4.0 — 2026-09-23

`GlassButton` grows the Sketch Buttons treatments without a second widget.

### Added

- `GlassButtonRole.destructive` — kit **Destructive**. Red label on Glass;
  filled system red + white label on Glass Prominent.
- `GlassButtonProminence.prominent` — kit **Glass Prominent**, tinted /
  filled System Blue, white label.
- `GlassButtonPalette` on `LiquidGlassTheme.buttons` (Light / Dark System
  Blue, system red, filled label, disabled label).
- `GlassButton.forcePressed` so a gallery can pin the pressed treatment.
- Gallery states Default / Pressed / Disabled and the variants above,
  including a live tap row. Clear still sits on rich media.

### Changed

- Disabled no longer fades the whole control to 45% opacity. The label
  switches to the kit muted color, and a disabled Glass Prominent fill
  drops back to glass.
- Pressed keeps the 0.97 scale and adds a press veil (implementation
  approximation — not a Design Token).
- Gallery Clear sits on a muted media plate. That color is not a focus
  ring and not the Sketch Clear rim (still the shared ~0.5px hairline).

## 0.3.0 — 2026-09-23

iOS 27 **Liquid Glass tab bar** (Sketch page 「Tab Bars」). Chrome is Dock glass, not Materials Thick and not a toolbar material.

### Added

- `GlassTabBar` / `LiquidGlassTabBar` — `items`, `currentIndex` / `onChanged`, `style` (`standard` / `floatingPill` / reserved `sidebar`), `glassStyle` (default Dock), `tint`, `brightness`, `tintedBar`.
- Standard bar: full width, edge to bottom, icon + Caption, Home Indicator inset.
- Floating pill: stadium capsule. On a 402pt board the content group is 266 (3 items) and 352 (4 and 5 share the side-inset cap).
- Selected icon + caption use System Blue (`#0088FF` / `#0091FF`). Unselected copy is Liquid Glass Primary at reduced opacity. `tintedBar` fills the platter with that tint and uses white icons.
- Short selection lens (not a Material indicator). Badges and disabled items.
- Gallery **Tabs** page. Spec: `docs/SPEC.md`.

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
