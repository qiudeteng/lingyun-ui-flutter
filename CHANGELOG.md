# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Example gallery Duo shell follows the device-page frames. Outer portrait (466×678) is sharp on the hinge (left) and 59pt on the right, with a 37pt camera at the top-right and side buttons on the right edge. Outer landscape is that cover after Landscape Right (counter-clockwise): both top corners are 59pt, both bottom corners are the hinge, the 37pt camera sits top-left, and the side buttons move to the top edge. Inner landscape and portrait use 59pt on every corner and do not paint a center camera dot. The stroke stays about 3px and adds a light metal lip. Half-fold and tent stay out of the menu. Phone Dynamic Island, iPad, macOS, and Windows frames are unchanged.
- Example gallery preview, still on the device stage only. Phone boards (Pro, Pro Max, Air) paint a Dynamic Island pill; iPad boards paint a centered top-edge lens; macOS paints a menu-bar notch. Windows and 「自适应窗口」 are unchanged, and the bezel stays `IgnorePointer`. A 横屏 / 竖屏 control next to 画板 swaps width and height for phones, iPads, and Duo screens (macOS, Windows, and the adaptive window hide it). Chip and menu labels follow the oriented point size. `orientation=` (`portrait` / `landscape` / `竖` / `横` / …) and `swap=` / `rotate=` extend the existing `device=` / `frame=` launch query; an explicit orientation wins, and desktop boards ignore both. Duo 外屏 466×678, 内屏横 951×669, and 内屏竖 669×951 stay the logical sizes. Their shell is the device-page flat stroke: a hairline rounded rect (large corner radius, light or dark with the theme), a small camera dot (outer in the top corner, inner top-center), and no hinge slot. Half-fold and tent are not on that page and are not in the menu.
- Example gallery boards for iPad mini 744×1133, iPad Air 11" 820×1180, iPad Pro 11" 834×1210, iPad Air 13" 1024×1366, iPad Pro 13" 1032×1376, macOS 1440×900, and Windows 1280×800. Phone and Duo frames are iOS. Each fixed frame injects that logical size, a simplified safe area, and `Theme.platform`. Debug builds also set `debugDefaultTargetPlatformOverride` (release and web release skip it; the setter throws). A vector bezel sits outside the clipped demo and does not take hits. 「自适应窗口」 stays unframed. Large boards still scale down uniformly. `LingyunPageHost.isIOSHost` follows the real iOS process, so a preview override does not swap the shell for a `UiKitView`.
- Example gallery preview chrome, in the same top-right cluster as the 画布 chip. **浅色 / 暗黑** sets the gallery `ThemeMode` (`theme=light|dark|system`). **降低透明度** is a switch wired to `LingyunAdaptivity.reduceTransparency` (`reduceTransparency=1|0|on|off`, or `a11y=1` / `a11y=reduceTransparency`; the explicit flag wins). **画板尺寸** clips and centers the demo, Dock included (`device=` or `frame=`): 自适应窗口, Pro 402×874, Pro Max 440×956, iPhone Air 420×912, Duo 外屏 466×678, Duo 内屏横 951×669, Duo 内屏竖 669×951. The cluster and the backdrop outside a fixed board follow those settings. The board also paints that backdrop inside the clip, so the Dock frosts the wallpaper instead of a flat gray slot. `bg=` is unchanged. `chrome=0` hides the cluster and still applies the query.
- Example gallery root is a `LingyunPage` Dock tab bar (not Material navigation and not the sidebar rail) for **基础** / **控件** / **浮层** / **导航壳**. A tab opens that group's workbench page (**基础工作台** and the same pattern for the other three): several sections, each an inset grouped list on Materials Regular labeled with the workbench name. The page fill is the system grouped background. A row pushes the demo; 返回 pops back to the workbench. No `?page=` stays on 基础工作台. `?home=` / `?tab=` (`foundation`, `controls`, `overlays`, `chrome`) open that workbench; a known `page` still wins. `?page=` and `GALLERY_PAGE` still open the demo. `theme`, `chrome=0`, and `bg` are unchanged. These tabs are not the **标签栏** specimen.
- Glass buttons are their own leaf (`?page=buttons`, alias `button`) on **基础工作台**. The glass page keeps style swatches only. Toggles, sliders, and steppers are three leaves; `toggle` / `slider` / `stepper` still resolve. Segmented controls and page controls stay one page (**分段与页控**).
- `showLingyunActionSheet` / `LingyunActionSheet` — Sketch **Action Sheets** hosted by `package:cupertino_ui` (`CupertinoModalPopupRoute` + `CupertinoActionSheet`). Regular, confirm (bold), destructive (system red), and a separated cancel. Enter / exit use the package spring; press is the package's immediate fill. Reduce Motion skips the spring (`Duration.zero`). No spring token, no Liquid Glass morph, not Materials Thick, not `LingyunSheet`. Gallery **操作表** (`?page=actions`) is Simplified Chinese. See [`docs/ACTION-SHEETS.md`](docs/ACTION-SHEETS.md).
- `LingyunSegmentedControl` — 2…N segments. The selection is one Liquid Glass lens (`LiquidGlassStyle.regularSmall` on `GlassSurface`, capsule, not Materials Thick) on a tertiary system fill. Selected labels use Liquid Glass Primary, the same rule as a Glass button; `tint` recolors only the label. Sizes small 32 and large 50 (specimen width 370). Press flex matches `GlassButton` (scale 0.97, quick duration, pressed veil). The lens travels with SwiftUI's `spring(duration:bounce:)` formula (`SpringDescription.withDurationAndBounce`, bounce left at the API default, duration `LiquidGlassMotion.quick`). No new spring token. Reduce Motion snaps. See [`docs/SEGMENTED.md`](docs/SEGMENTED.md).
- `LingyunPageControl` — indicator by default (no hit target). Current dot is Liquid Glass Primary or `tint`; the rest are tertiary, or the tint at low contrast. Optional platter is Liquid Glass Regular Small for busy backgrounds. The dots are content, not glass. The highlight uses the same spring as the segmented lens and snaps under Reduce Motion.
- Example gallery **分段** (`?page=segmented`, `segments`, `pages`, `page-controls`, `pagecontrol`). On-screen copy is Simplified Chinese. Light and dark captures: `docs/screenshots/segmented_controls_*.png`, `page_controls_*.png`.
- Anchored popovers. `showLingyunPopover` / `LingyunPopover` paint Liquid Glass Regular Medium (`GlassSurface(style: LiquidGlassStyle.regularMedium)`, no token override). Not Materials Thick, not a menu, and not an action sheet — `cupertino_ui` has no popover route to wrap. Enter / exit scale from the arrow tip with `LiquidGlassMotion.standard` (no new spring, no fade). Row press reuses the glass-button flex (scale 0.97, quick 180ms, pressed veil). Reduce Motion zeroes those durations. Gallery **弹出框** (`?page=popovers`) is Simplified Chinese. See [`docs/POPOVERS.md`](docs/POPOVERS.md).
- `LingyunToggle`, `LingyunSlider`, and `LingyunStepper` — form controls on the accepted Controls layer styles. Toggle track 64×28 with a 24pt knob. Slider track is 6pt tall with the same knob. Stepper is 92×32 and reuses the unfilled track only (no knob, no new colors). Dark idle knob and filled-disabled tracks stay null. Not Materials and not Liquid Glass. Gallery **开关** (`?page=toggles`, `sliders`, `steppers`) is Simplified Chinese. See [`docs/CONTROLS.md`](docs/CONTROLS.md).
- `ControlLayerCatalog`, `ControlLayerView`, and `ControlKnobStack` — Sketch iOS 27 Controls layer styles for form tracks and knobs (`Controls/Light` and `Controls/Dark`: Knobs - Toggle, Tracks). Filled tracks use System Blue. Light idle knob is white with the kit shadow (blur 36, offset `(0, 3)`, black 5%). Clicked glow and clicked shadow (gaussian radius 3) are included. Dark idle knob and filled-disabled tracks are absent from the kit and stay null. Not Materials, not Liquid Glass Clear / Regular / Dock. No backdrop sigma and no corner radius on the style. See [`docs/CONTROLS.md`](docs/CONTROLS.md).
- Example **旋钮** page (`?page=knob`, also `track` / `controls`) with 浅色 / 深色. Gallery copy is Simplified Chinese.
- `GlassList` — inset grouped content layer (Materials Regular via `GlassSurface(material: MaterialTier.regular)`, no Liquid Glass style, around `CupertinoListSection.insetGrouped`) and plain rows with no platter. Leading / title / subtitle / trailing, section header and footer. Inset dividers are the system separator. Subtitle and trailing value use opaque Labels-LG secondary (`#727272` / `#8A8A8A`) at Subheadline / Body. The footer stays tertiary and sits outside the platter clip. Not Materials Thick and not Liquid Glass.
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
- Formal sidebars. `LingyunSidebar` / `LingyunSidebarLayout` use the same Materials Thick platter as sheets (stripes underneath, no style or token override). Title, sections, selection. Not the Dock rail (`GlassTabBarStyle.sidebar`, 96px, 待核验) and not the native vertical toolbar. Expand/collapse follows the system page curve; selection and row press use `LiquidGlassMotion.quick` and `CupertinoListTile`. No new spring token. Gallery **侧栏** (`?page=sidebars`) is Simplified Chinese. See `docs/SIDEBARS.md`.
- Flutter toolbars. `LingyunToolbar` floats Liquid Glass groups at Regular Medium (leading / title / trailing). Not Dock, not Materials Thick, not the iOS 27.1 vertical system toolbar. Press uses the existing 0.97 scale. Show/hide uses `LiquidGlassMotion.standard`. Gallery **工具栏** (`?page=toolbars`) is Simplified Chinese. See `docs/TOOLBARS.md`.
- Wave 2 Menus. `showLingyunMenu` / `LingyunMenu` are a Liquid Glass bubble (Regular Large hypothesis). The button morphs into the menu and back; rows flex on press; Reduce Motion snaps and skips the flex. Not Materials Thick, not an action sheet, not a popover. No new spring token. Gallery copy is Simplified Chinese (`?page=menus`). See `docs/MENUS.md`.

### Notes

- Wide breakpoint **1200** matches `LingyunBreakpoints.large` and is not a kit token. Flutter rail width **96** is **待核验 vs design**.
- The Flutter skeleton does not paint iOS 27.1 vertical system chrome, `ArrangementView`, or real reserved regions. Those link in `ios/` when `LY_IOS_27_1_SDK=1`.

### Fixed

- Example gallery shell stays the Flutter Dock on an iOS process (simulator and TestFlight). `LingyunPage.embedNativeHost` defaults to true, so the layout demo and `LingyunNativePage` still mount `LYPage`. The gallery passes false. Previously that shell became `LYPageScaffold`: two system tabs, both labeled with the current group (「基础」), plus the metrics pane, and the workbench list never appeared.

### Changed

- Example workbench pages (**基础** / **控件** / **浮层** / **导航壳**) no longer wrap each section list in a Liquid Glass Regular Medium card. The embedded list is `GlassListStyle.inset`: Materials Regular (`GlassSurface(material: MaterialTier.regular)`, no `style`, no tokens) around `CupertinoListSection.insetGrouped`. Plain lists still have no platter. The workbench page background is `CupertinoColors.systemGroupedBackground`. On-screen copy stays Simplified Chinese. `GlassButton`, `GlassTabBar`, and `GlassTextField` are unchanged. The device preview stage is unchanged.
- Example gallery **材质封装** (`?page=materials-pack`) replaces the separate 材质, 液态玻璃, and 旋钮与轨道 rows. One page, Sketch order: Controls (knob / track parts, light and dark), Liquid Glass (Clear / Regular S·M·L / Dock / Widget, light and dark), Materials (Thick → Regular → Thin → Ultrathin, light and dark). Thick copy says it is Sheet / Sidebar only. Legacy `?page=materials|glass|knob|controls|track` open that page on the matching section. Glass buttons stay `?page=buttons`. Catalogs are unchanged. On-screen copy is Simplified Chinese and does not print blur or saturation numbers.
- Liquid Glass **Dock** (light and dark) is a see-through frost plus an edge refraction lip (`LiquidGlassOptics.lens`). Light tint alpha stays under 0.25 and dark under 0.35; blur stays low enough that wallpaper shows through the face; the overlay does not add a second white fill. Materials tiers and other glass styles stay on the flat frost. No second backdrop filter, no live backdrop displacement, no content-sampled shadow. `blurSigma`, saturation, tint alpha, and the lip width remain approximations — **待核验 vs 真机/Sketch**. `GlassTabBar` still consumes Dock tokens only. The selection lens is unchanged. The foreground rim stays the continuous rounded stroke from main; this pass does not add side lines.
- `GlassList` inset sections no longer use `LiquidGlassStyle.regularMedium`. Each section is Materials Regular (`GlassSurface(material: MaterialTier.regular)`, `style` and `tokens` unset) around `CupertinoListSection.insetGrouped`. The Cupertino grouped fill is cleared so the material is the section color. `glassStyle` and `forceOpaque` are removed; there is no new list background API. Plain lists still have no platter. Not Thick and not Liquid Glass.
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

### Fixed

- 示例 iOS 工程接入 UIScene 生命周期，对齐 Flutter 3.47.8 模板：`AppDelegate` 实现 `FlutterImplicitEngineDelegate`，插件改在 `didInitializeImplicitFlutterEngine` 注册；新增 `SceneDelegate`（`FlutterSceneDelegate`）；`Info.plist` 写入 `UIApplicationSceneManifest`。iOS 27.1 模拟器不再因未接入场景生命周期在启动时 SIGTRAP。Bundle ID 仍是 `com.qiudeteng.lingyunui`。
- 玻璃边缘是一条连续圆角描边。`_CrispRimPainter` 不再另画左右两条竖线，浅色材质样例卡左侧和底栏 Dock 两端不再出现独立竖向白线。`rimSideOffset` / `rimSideSpread` 仍留在 `LiquidGlassTokens.shadows` 的旧侧板上，列表长度不变；前景描边不再读取它们。

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
