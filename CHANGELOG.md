# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- `showLingyunActionSheet` / `LingyunActionSheet` — Sketch **Action Sheets** hosted by `package:cupertino_ui` (`CupertinoModalPopupRoute` + `CupertinoActionSheet`). Regular, confirm (bold), destructive (system red), and a separated cancel. Enter / exit use the package spring; press is the package's immediate fill. Reduce Motion skips the spring (`Duration.zero`). No spring token, no Liquid Glass morph, not Materials Thick, not `LingyunSheet`. Gallery **操作表** (`?page=actions`) is Simplified Chinese. See [`docs/ACTION-SHEETS.md`](docs/ACTION-SHEETS.md).
- `LingyunSegmentedControl` — 2…N segments. The selection is one Liquid Glass lens (`LiquidGlassStyle.regularSmall` on `GlassSurface`, capsule, not Materials Thick) on a tertiary system fill. Selected labels use Liquid Glass Primary, the same rule as a Glass button; `tint` recolors only the label. Sizes small 32 and large 50 (specimen width 370). Press flex matches `GlassButton` (scale 0.97, quick duration, pressed veil). The lens travels with SwiftUI's `spring(duration:bounce:)` formula (`SpringDescription.withDurationAndBounce`, bounce left at the API default, duration `LiquidGlassMotion.quick`). No new spring token. Reduce Motion snaps. See [`docs/SEGMENTED.md`](docs/SEGMENTED.md).
- `LingyunPageControl` — indicator by default (no hit target). Current dot is Liquid Glass Primary or `tint`; the rest are tertiary, or the tint at low contrast. Optional platter is Liquid Glass Regular Small for busy backgrounds. The dots are content, not glass. The highlight uses the same spring as the segmented lens and snaps under Reduce Motion.
- Example gallery **分段** (`?page=segmented`, `segments`, `pages`, `page-controls`, `pagecontrol`). On-screen copy is Simplified Chinese. Light and dark captures: `docs/screenshots/segmented_controls_*.png`, `page_controls_*.png`.
- `LingyunToggle`, `LingyunSlider`, and `LingyunStepper` — form controls on the accepted Controls layer styles. Toggle track 64×28 with a 24pt knob. Slider track is 6pt tall with the same knob. Stepper is 92×32 and reuses the unfilled track only (no knob, no new colors). Dark idle knob and filled-disabled tracks stay null. Not Materials and not Liquid Glass. Gallery **开关** (`?page=toggles`, `sliders`, `steppers`) is Simplified Chinese. See [`docs/CONTROLS.md`](docs/CONTROLS.md).
- `ControlLayerCatalog`, `ControlLayerView`, and `ControlKnobStack` — Sketch iOS 27 Controls layer styles for form tracks and knobs (`Controls/Light` and `Controls/Dark`: Knobs - Toggle, Tracks). Filled tracks use System Blue. Light idle knob is white with the kit shadow (blur 36, offset `(0, 3)`, black 5%). Clicked glow and clicked shadow (gaussian radius 3) are included. Dark idle knob and filled-disabled tracks are absent from the kit and stay null. Not Materials, not Liquid Glass Clear / Regular / Dock. No backdrop sigma and no corner radius on the style. See [`docs/CONTROLS.md`](docs/CONTROLS.md).
- Example **旋钮** page (`?page=knob`, also `track` / `controls`) with 浅色 / 深色. Gallery copy is Simplified Chinese.
- `GlassList` — inset grouped platter (`LiquidGlassStyle.regularMedium` on one `GlassSurface` per section) and plain rows. Leading / title / subtitle / trailing, section header and footer, tertiary separators. Subtitle and trailing value use opaque Labels-LG secondary (`#727272` / `#8A8A8A`) at Subheadline / Body. Separators and the footer stay tertiary. The inset footer sits outside the platter clip. Not Materials Thick.
- `GlassTextField` — `CupertinoTextField` inside Liquid Glass Regular Small. Default, focused, error, and disabled states; clear button; obscure toggle. Label and value stay Primary (including when disabled); placeholder and helper are Tertiary; error is system red. Disabled does not paint the Cupertino opaque fill. Focus and error use the shared 0.5px hairline.
- `GlassProgressIndicator` — determinate and indeterminate, linear and circular, System Blue tint with override. Linear determinate is `CupertinoLinearActivityIndicator`. Indeterminate linear uses a Tertiary track. Determinate circular is a ring; indeterminate circular is `CupertinoActivityIndicator`. Not a Liquid Glass fill.
- Form controls read Labels — Liquid Glass and the Large text scale from `LingyunTheme` / `LingyunTextStyles`. They do not hardcode `#1A1A1A`, `#EDEDED`, `#BFBFBF`, `#404040`, or point sizes.
- Example gallery pages **列表** / **文本框** / **进度** (`?page=lists|fields|progress`). On-screen copy is Simplified Chinese. Light and dark captures: `docs/screenshots/lists_*.png`, `text_fields_*.png`, `progress_*.png`.
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
- Wave 2 Sheets. `showLingyunSheet` / `LingyunSheet` paint **Materials Thick** (`GlassSurface(material: MaterialTier.thick)`, no style override). Detents, grabber, size-class inset, safe area, and keyboard lift. Not a glass button and not Dock. Gallery copy is Simplified Chinese (`?page=sheets`, 浅色 / 深色 on the page). The Materials tier recipe is unchanged; shots are the Thick from `d451503`. See `docs/SHEETS.md`.
- Example gallery chrome for sidebar, Glass, Tabs, Layout, Native, and Access (titles, buttons, labels, help) is Simplified Chinese. Committed page screenshots still show the previous English copy until a Mac re-shoot.

### Notes

- Wide breakpoint **1200** matches `LingyunBreakpoints.large` and is not a kit token. Flutter rail width **96** is **待核验 vs design**.
- The Flutter skeleton does not paint iOS 27.1 vertical system chrome, `ArrangementView`, or real reserved regions. Those link in `ios/` when `LY_IOS_27_1_SDK=1`.

### Changed

- Alerts are the formal system dialog (probe [#16](https://github.com/qiudeteng/lingyun-ui-flutter/pull/16) stays the base; no second widget). Non-destructive actions use the kit system blue (`#0088FF` / `#0091FF`) through `CupertinoThemeData.primaryColor`. `CupertinoDialogAction` still paints them. Destructive stays Cupertino `systemRed` (`#FF3B30` / `#FF453A`), not the kit red. On Apple the face stays `CupertinoSystemText` (SF Pro is not bundled). On other platforms, when the ambient `DefaultTextStyle` already names a real family, title, message, and actions adopt it and append a CJK UI fallback list. Motion stays on `CupertinoDialogRoute`: critically damped spring (mass 1, stiffness 522.35, damping 45.7099552, velocity tolerance 0.03). Nominal duration 250ms is ignored by the simulation; rest is about 404ms. Enter is fade plus scale 1.3→1. Exit is the same spring on fade only. Press swaps the action plate on pointer-down (`0xFFE1E1E1` / `0xFF404040`). Reduce motion (`MediaQuery.disableAnimations` or `LingyunAdaptivity.reduceMotion`) keeps the route and sets its duration to zero; the press fill still changes. Gallery **提示** copy stays Simplified Chinese, with 浅色 / 深色 on the page. See [`docs/ALERTS.md`](docs/ALERTS.md).
- Example **旋钮** page composes a circular knob on the track (toggle 64×28, slider bar 6pt tall, knob diameter 24). Idle and pressed shadows are no longer clipped to the knob bounds, and the gray specimen plate that hid the 5% shadow is gone. Tokens are unchanged: dark idle knob and filled-disabled tracks stay null. Gallery copy stays Simplified Chinese.
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
