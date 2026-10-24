# lingyun-ui-flutter

Materials + Liquid Glass primitives for Flutter — two **separate** systems, a `ThemeExtension`, frosted `GlassSurface`, `GlassButton`, `GlassTabBar`, motion/accessibility helpers, and adaptive layout utilities.

规格说明：[`docs/SPEC.md`](docs/SPEC.md)（官方名 vs 实现备注）。

**Dart package:** `lingyun_ui_flutter`  
**License:** MIT  
**Dependencies:** Flutter SDK, [`cupertino_ui`](https://pub.dev/packages/cupertino_ui) (preferred), and [`material_ui`](https://pub.dev/packages/material_ui) for Material APIs (`ThemeExtension`, `Icons`, `Material`). Not `package:flutter/material.dart` or `package:flutter/cupertino.dart`.

## Platforms

Phase 0 targets **all** of these surfaces. Tokens, theme, and `GlassSurface` are the same APIs everywhere. The iOS page host (`LingyunNativePage` / `LYPage`) is the one platform view; other platforms keep the Flutter layout helpers. See [`docs/IOS-LYPAGE.md`](docs/IOS-LYPAGE.md).

| Surface | Typical width class | Layout notes |
| --- | --- | --- |
| **iPhone** (classic) | `compact` (&lt; 600) | Single column; no hinge band |
| **iPhone Duo** | Outer: `compact` or wide-short; inner: `regular` | Avoid interactive chrome in the center division; side-edge controls when closed / wide-short; Split View uses the same regular-width helpers |
| **iPad** | `expanded` (840–1199), Split View may drop to `regular` / `compact` | Sidebar / split-capable; still hinge-safe when not compact |
| **macOS** | `large` (≥ 1200), or smaller when the window is resized | Pointer hover boosts specular; keep the Liquid Glass look |

Detection uses **Flutter size classes** (`MediaQuery.sizeOf` / `LayoutBuilder` + [LingyunBreakpoints]), not device-model APIs.

Example platforms in this repo: **iOS, macOS, web** (Android is included as a bonus).

## Two systems (do not mix names)

Sketch / iOS 27 kit authority: [UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02).

| System | Official names | API | Typical use |
| --- | --- | --- | --- |
| **A. Materials** | Ultrathin / Thin / Regular / Thick × Light / Dark | `MaterialTier` + `MaterialCatalog` | Content-layer fills. **Thick = Sheet / Sidebar only** |
| **B. Liquid Glass** | Clear / Regular Small · Medium · Large / Dock / Widget Glass | `LiquidGlassStyle` + `LiquidGlassCatalog` | Floating controls. **Button default = Regular Small** (or Clear) |

`GlassMaterialTier` / `LiquidGlassMaterials` remain as **deprecated aliases** of Materials. They no longer map Thin→Clear or Thick→Widget Glass.

`blurSigma` / `saturation` are **implementation approximations — not official Design Tokens**. The gallery does not print them as kit values.

## Features

| API | Role |
| --- | --- |
| `MaterialTier` / `MaterialCatalog` | Materials Ultrathin / Thin / Regular / Thick × Light / Dark |
| `LiquidGlassStyle` / `LiquidGlassCatalog` | Liquid Glass Clear / Regular S·M·L / Dock / Widget Glass |
| `LingyunColors` / `LingyunTheme` | Sketch iOS 27 system colors, labels, backgrounds, fills, grays, separators. Cupertino theme. Liquid Glass labels: Primary `#1A1A1A` / `#EDEDED`, Tertiary `#BFBFBF` / `#404040` |
| `LingyunTextStyles` | Large Title…Caption 2 at the Large size, plus loose / tight leading. `LingyunMaterialTheme` maps them onto `TextTheme` |
| `LiquidGlassLabels` | Labels — Liquid Glass Primary: Light `#1A1A1A`, Dark `#EDEDED` |
| `GlassList` | Inset grouped Liquid Glass Regular Medium platter, or plain rows. Label color and type come from `LingyunTheme` / `LingyunTextStyles` |
| `GlassTextField` | Liquid Glass Regular Small field. Clear button, obscure toggle, error hairline. Same theme labels and Large text styles |
| `GlassProgressIndicator` | Determinate / indeterminate, linear / circular. Tint defaults to theme System Blue |
| `GlassButtonRole` / `GlassButtonProminence` | Kit **Destructive** and **Glass Prominent** (tinted / filled System Blue, white label) on `GlassButton` |
| `GlassButtonPalette` | Light / Dark System Blue, system red, filled label, disabled label. On `LiquidGlassTheme.buttons` |
| `GlassRadiusScale` / `LiquidGlassRadii` | `small` / `medium` / `large` corners (**18 / 26 / 34 待核验 vs Sketch**) |
| `LiquidGlassTokens` | Shared visual recipe (blur/sat = implementation approximation) |
| `LiquidGlassTheme` | `ThemeExtension` with both catalogs and `buttons`; `materialOf` / `styleOf` / `buttonPaletteOf` |
| `GlassSurface` / `GlassCard` | `material:` **or** `style:` + hover specular on pointer devices |
| `GlassButton` | Liquid Glass Button — Style Glass (material Regular Small, control size Small) / Clear / Destructive / Glass Prominent / Symbol. Sizes Small 28, Medium 34, Large 50, capsule |
| `GlassTabBar` | iOS 27 tab bar. Liquid Glass **Dock** (not Materials Thick): standard full-width bar, floating capsule, tinted whole bar. `GlassTabBarStyle.sidebar` is the Flutter glass rail on `LingyunPage`, not iOS 27.1 vertical system chrome |
| `LingyunPage` | Flutter page shell on `LingyunPageSpec`. Compact → bottom Dock tab. Regular / wide → glass sidebar rail. On iOS, the same spec goes to `LingyunNativePage` |
| `showLingyunAlert` / `LingyunAlertDialog` | Sketch **Alerts** via `cupertino_ui` (`showCupertinoDialog` + `CupertinoAlertDialog`). One button, two buttons (Cancel leading), destructive system red, title + message, message only. Not Liquid Glass. Gallery copy is Simplified Chinese. See [`docs/ALERTS.md`](docs/ALERTS.md) |
| `ControlLayerCatalog` / `ControlLayerView` / `ControlKnobStack` | Sketch **Controls** knob and track layer styles for later Toggle / Slider / Stepper tracks. Fills, borders, shadows. Not Materials and not Liquid Glass Clear / Regular / Dock. No backdrop sigma and no corner radius on the style. See [`docs/CONTROLS.md`](docs/CONTROLS.md) |
| `LiquidGlassMotion` | Standard / emphasized / quick curves; **reduce-motion** → `Duration.zero` |
| `LingyunAdaptivity` | Reduce Transparency, Reduce Motion, high-contrast overrides |
| `LingyunLayout` | Width classes, safe-area + layout margins, hinge/division band, wide-short heuristic, side-edge chrome |
| `LingyunNativePage` / `LYPage` | iOS host for `LingyunPage`: horizontal size class + view bounds. System `TabView`, `NavigationSplitView`, and (`LY_IOS_27_1_SDK=1`) `ArrangementView` |

### Specular / refraction conventions

Documented on `LiquidGlassTokens` and painted by `GlassSurface`:

- **Specular** — a *tight* top-leading catch (`edgeHighlightColor`) plus dark **inner-lip** bands (`innerShadowColor`) that approximate the kit's ±40 Y / −40 spread inner shadows. Not a full-face 2018 sheen or a focus ring.
- **Refraction** — directional **inner rim** (bright top-leading → quiet bottom-trailing). Distinct from the outer **grey ring** (`rimColor`, zero-blur +0.5 spread) and side hairlines (Sketch "Plus Darker", ~1.25 / −0.75).
- **Shadows** — soft deep drop (`shadowColor`, large blur, modest Y, negative spread) stacked with the crisp rim.
- **Rim** — ~0.5px hairline + multi-layer specular like Clear. **Not** linearly thickened by Materials tier (no 0.55→0.85).
- **Radius** — `GlassRadiusScale` 18 / 26 / 34 is **待核验 (unverified vs Sketch)** and applies to panels, not buttons. `GlassButton` is a capsule (`BorderRadius.circular(1000)`). Control sizes are Small / Medium / Large (about 28 / 34 / 50). Regular Small is the button **material**, not a 48pt height.
- **Hover** (macOS / desktop web) may boost specular opacity. Touch devices never enter `MouseRegion`.

Official kit names are first-class enums. This package does not claim Apple's API.

### Accessibility

- **Reduce Transparency** (`LingyunAdaptivity.reduceTransparency` or `GlassSurface.forceOpaque`) → solid `opaqueFallbackColor`
- **High contrast** (`MediaQuery.highContrast` or the adaptivity flag) → same opaque fallback
- **Reduce Motion** (`MediaQuery.disableAnimations` or `LingyunAdaptivity.reduceMotion`) → `LiquidGlassMotion.durationOf` returns `Duration.zero`

## Install

```yaml
dependencies:
  lingyun_ui_flutter:
    git:
      url: https://github.com/qiudeteng/lingyun-ui-flutter.git
```

Or path / pub once published:

```yaml
dependencies:
  cupertino_icons: ^2.0.0
  lingyun_ui_flutter: ^0.4.0
  material_ui: ^1.8.0
```

`ThemeData` / `MaterialApp` come from `material_ui`. `cupertino_icons` supplies the font for the few Cupertino glyphs Material still draws. Set `uses-material-design: true` if you use `Icons`.

## Quick start

```dart
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: const [LiquidGlassTheme.light],
      ),
      darkTheme: ThemeData.dark().copyWith(
        extensions: const [LiquidGlassTheme.dark],
      ),
      home: Scaffold(
        body: LingyunLayoutBuilder(
          builder: (context, layout) {
            return Column(
              children: [
                GlassButton.label(
                  label: 'Regular Small',
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                GlassSurface(
                  material: MaterialTier.regular,
                  radiusScale: GlassRadiusScale.large,
                  padding: const EdgeInsets.all(24),
                  child: Text('Width class: ${layout.widthClass.name}'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

## Duo / iPad / desktop layout

```dart
final layout = LingyunLayout.dataOf(context);
if (layout.avoidHinge) {
  // Do not place buttons, tabs, or sliders in layout.hingeBand.
}
// Closed cover (wide + short): put chrome on the leading/trailing edges.
LingyunSideChrome(
  leading: const BackButton(),
  trailing: const Icon(Icons.more_horiz),
  child: content,
);
```

`LingyunLayout.avoidHinge` is the older geometry helper (any non-compact width, or a wide-short size). `LingyunPage` does not apply that band on its own. Pass an active `LingyunPageRegion` (`kind: 'division'`) when a Flutter simulation should keep a seam between content columns. The iOS host reports real regions on `LingyunPageSnapshot`.

Breakpoints (logical px): compact &lt; 600, regular 600–839, expanded 840–1199, large ≥ 1200.

## LingyunPage

`LingyunPage` takes a `LingyunPageSpec` (the same object as `LingyunNativePage`). On iOS the native host is what you see. Off iOS, and in the gallery, the Flutter skeleton follows `resolveLingyunPageContainer`.

| Bucket | Recommended spec | Flutter skeleton |
| --- | --- | --- |
| `compact` | `tab` + `stack` | One column, bottom Dock `GlassTabBar` |
| `regular` | `sidebar` + `split` | Glass rail + primary. Compact width collapses the rail |
| `wide` | `sidebar` + `split`, width ≥ 1200 | Rail + secondary + primary |

`lingyunPageSpecForBucket` builds that spec. A caller can pass any chrome instead. There is no Duo pose enum.

With no size class, the skeleton uses the width proxy (`< 600` compact). Pass `horizontalSizeClass: 'compact'` to simulate a compact class wider than 600. `unspecified` matches iOS and is not compact. iOS itself does not use the 600 cut; see [`docs/IOS-LYPAGE.md`](docs/IOS-LYPAGE.md).

Vertical system chrome, `ArrangementView`, and reserved regions are native, and they link only when `LY_IOS_27_1_SDK=1`. The Flutter arrangement role is a note, not a hinge. The 96px rail is **待核验 vs design**.

```dart
LingyunPage(
  spec: lingyunPageSpecForBucket(LingyunPageWidthBucket.regular),
  primary: const DetailPane(),
  secondary: const ListPane(),
)
```

Details: [`docs/PAGE.md`](docs/PAGE.md) and [`docs/PAGE-ADAPTIVE-PLAN.md`](docs/PAGE-ADAPTIVE-PLAN.md).

### iOS native page

`LingyunLayout` measures window width because Flutter has no horizontal size class. On iOS, `LYPage` does **not** reuse the 600 pt cut. Compact is a compact horizontal size class (folded Duo outer display included). Regular is a regular horizontal size class (half-open and fully open). Wide is regular and at least `LingyunBreakpoints.large` (1200). That number is the existing Dart breakpoint, not an iOS kit token.

The example **Native** page embeds the platform view on iOS and prints the compact / regular notes on every platform. Build steps and the 27.1 SDK flag: [`docs/IOS-LYPAGE.md`](docs/IOS-LYPAGE.md).

```bash
cd example
flutter run -d ios
```

On Windows, `flutter test` and `flutter analyze` are the same commands. `pod install` and `flutter build ios` need a Mac with Xcode. This tree was not compiled against the iOS 27.1 SDK.

## Example gallery

```bash
cd example
flutter run -d chrome
flutter run -d macos
flutter run -d ios
```

Pages: **Materials** (Ultrathin / Thin / Regular / Thick + 待核验 radii), **Glass** (Clear / Regular S·M·L / Dock / Widget Glass + `GlassButton` sizes Small / Medium / Large, states Default / Pressed / Disabled, variants Glass, Clear, Destructive, Glass Prominent, Symbol), **Tabs** (`GlassTabBar`: standard edge-to-bottom, floating pill at 3, 4, and 5 items, System Blue selection, tinted whole bar; light/dark wallpaper), **Themes** (light / dark), **Layout** (`LingyunPage` compact / compact-bounds / regular / division / wide presets + live window), **Access** (reduce transparency / motion / high contrast), **Native** (`?page=native`, iOS `LYPage` host), **Alerts** (system `cupertino_ui` dialog: one button, two buttons, destructive, title + message, message only; demo copy is Simplified Chinese). The default backdrop is a flat design canvas (light `#D1D1D6`, dark `#000000`) so glass can sit next to the Sketch kit. A **Canvas** chip on every page switches that canvas, the previous muted wash, a nature scene, abstract color, and a busy UI pattern.

Colors and text styles are on the main gallery **主题** destination (Simplified Chinese). Open it from the nav, or with `?page=themes` (color swatches), `?page=colors`, or `?page=text` (Large text specimens). Add `&theme=dark` and `&chrome=0`. The same pages also have a Cupertino entry:

```bash
cd example
flutter run -d chrome -t lib/foundation_app.dart
```

`?page=colors` or `?page=text`, plus `&theme=dark` and `&chrome=0`. Screenshots: `docs/screenshots/colors_*.png`, `docs/screenshots/text_*.png`.

Open a page directly: `?page=tabs` or `?page=alerts` (add `&theme=dark` and `&chrome=0` for a bare light/dark capture). Layout presets: `?page=layout&preset=compact`. Native host notes: `?page=native`. Backdrop: `&bg=canvas` (default), `wash`, `meadow`, `abstract`, or `busy`.

Screenshots: [`docs/screenshots/`](docs/screenshots/).

## Development

```bash
dart format .
flutter analyze
flutter test
cd example && flutter build web --base-href /lingyun-ui-flutter/
```

On Windows, use the same commands from `cmd` or PowerShell (`flutter` on `PATH`). Paths use `/` in pubspec; Git Bash or PowerShell both work.

## License

MIT © 2026 凌云大帝 / qiudeteng
