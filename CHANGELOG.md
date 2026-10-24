# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- `ControlLayerCatalog`, `ControlLayerView`, and `ControlKnobStack` — Sketch iOS 27 Controls layer styles for form tracks and knobs (`Controls/Light` and `Controls/Dark`: Knobs - Toggle, Tracks). Filled tracks use System Blue. Light idle knob is white with the kit shadow (blur 36, offset `(0, 3)`, black 5%). Clicked glow and clicked shadow (gaussian radius 3) are included. Dark idle knob and filled-disabled tracks are absent from the kit and stay null. Not Materials, not Liquid Glass Clear / Regular / Dock. No backdrop sigma and no corner radius on the style. See [`docs/CONTROLS.md`](docs/CONTROLS.md).
- Example **旋钮** page (`?page=knob`, also `track` / `controls`) with 浅色 / 深色. Gallery copy is Simplified Chinese.
- iOS `LYPage` host under `ios/` (Flutter plugin). Layout uses horizontal size class and the view's bounds. System `TabView` and `NavigationSplitView` are always compiled. `ArrangementView`, `UIArrangementViewController`, and `reservedRegions` compile only with `-D LY_IOS_27_1_SDK` on the iOS 27.1 SDK.
- Shared contract: `LingyunPageSpec`, `LingyunPageWidthBucket`, `LingyunNativePage`. No Duo pose enum. Native mapping: [`docs/IOS-LYPAGE.md`](docs/IOS-LYPAGE.md).
- `LingyunPage` Flutter skeleton for non-iOS and for size-class simulation. It consumes that spec. Compact → tab + stack (bottom Dock). Regular → sidebar + split. Wide sidebar → three columns. Arrangement is a note, not a drawn hinge. [`docs/PAGE.md`](docs/PAGE.md).
- Layout gallery presets: compact, compact bounds with an explicit size class, regular, regular + division, wide.
- Example gallery **Native** page (`?page=native`). The UIKit skeleton runs on iOS only.
- Wave 2 Alerts probe. `showLingyunAlert` / `LingyunAlertDialog` present the iOS system alert through `package:cupertino_ui` (`showCupertinoDialog` + `CupertinoAlertDialog`). Sketch states: one button, two buttons (Cancel leading), destructive (system red), title + message, message only. Not Liquid Glass, not a glass button, not Materials Thick. No `CupertinoUiCompatibilityBridge`. Gallery demo copy is Simplified Chinese. See `docs/ALERTS.md`.
- `LingyunColors` — Sketch iOS 27 color variables (system colors, labels, liquid-glass labels, backgrounds, fills, grays, separators) for light and dark. Wired through `LingyunTheme` (`cupertino_ui`) and `LingyunMaterialTheme` (`ColorScheme` / `TextTheme` on `material_ui` only).
- `LingyunTextStyles` — Sketch text styles at the Large content size, plus loose / tight leading. SF Pro is not bundled. Dynamic Type ramps other than Large stay unverified.
- Example foundation gallery (`flutter run -t lib/foundation_app.dart`). The page copy is Simplified Chinese.
- Main example **主题** page (nav label, not `Themes`) shows the same color swatches and Large text specimens, with 浅色 / 深色. `?page=themes`, `?page=colors`, or `?page=text`.

### Notes

- Wide breakpoint **1200** matches `LingyunBreakpoints.large` and is not a kit token. Flutter rail width **96** is **待核验 vs design**.
- The Flutter skeleton does not paint iOS 27.1 vertical system chrome, `ArrangementView`, or real reserved regions. Those link in `ios/` when `LY_IOS_27_1_SDK=1`.

### Changed

- Minimum SDK floor is Dart `^3.13.7` and Flutter `>=3.47.8` (stable 2026-10-23).
- Materials Ultrathin → Thick stay visually apart on the stripe specimen. The backdrop underlay is only the blurred drop shadow. Opaque zero-blur rim fills were sampling as a solid plate on Linux and web, so every tier looked like the same milk. The ~0.5px grey ring and side hairlines are foreground strokes. Liquid Glass paths (GlassButton Regular Small, GlassTabBar Dock) are unchanged. Materials page copy in the example is Simplified Chinese.
- Design libraries moved off the Flutter SDK. `lib/` and `example/` no longer import `package:flutter/material.dart` or `package:flutter/cupertino.dart`. Files that do not need a Material API import `package:cupertino_ui/cupertino_ui.dart`. Material APIs (`Theme` / `ThemeExtension`, `Icons`, `Colors`, `Material`, gallery `Scaffold` / `NavigationBar`) stay on `package:material_ui/material_ui.dart`. The example depends on `cupertino_icons` so the few Cupertino glyphs Material still draws have a font. No `CompatibilityBridge`. Materials and Liquid Glass names are unchanged.
- `GlassButton` matches the Figma Liquid Glass button matrix (acceptance brief): control sizes Small / Medium / Large (about 28 / 34 / 50, padding 10×5 / 12×8 / 20×16), default size Small, capsule radius 1000 rather than panel radii 18 / 26 / 34. Regular Small stays the **material**.
- Glass Prominent is White Backing plus an opaque System Blue (`#0088FF` light) or system red, white label, SF Pro Medium weight on the ambient font. Disabled Prominent keeps that fill at 50% opacity. Disabled Glass uses tertiary `#BFBFBF` in light and Labels-LG Dark Tertiary `#404040` in dark.
- `GlassButton.icon` is the Symbol variant (circle at the text size's height).
- Gallery button section shows sizes, states, Clear, Destructive, Prominent, and Symbol. Pressed remains scale 0.97 plus a lighter press veil so the capsule stays readable (approximation, not a kit token; Figma has no Pressed axis).
- Gallery **Tabs** page adds a floating pill with 4 items. It uses the same 352pt cap as the 5-item pill.
- Example gallery default backdrop is a flat design canvas (light `#D1D1D6`, dark `#000000`). A control on every page switches canvas, muted wash, nature, abstract color, and a busy UI pattern (`?bg=`).

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
