# lingyun-ui-flutter

Materials + Liquid Glass primitives for Flutter — two **separate** systems, a `ThemeExtension`, frosted `GlassSurface`, `GlassButton`, `GlassTabBar`, motion/accessibility helpers, and adaptive layout utilities.

规格说明：[`docs/SPEC.md`](docs/SPEC.md)（官方名 vs 实现备注）。

**Dart package:** `lingyun_ui_flutter`  
**License:** MIT  
**Dependencies:** Flutter SDK only (no third-party runtime packages)

## Platforms

Phase 0 targets **all** of these surfaces. Tokens, theme, and `GlassSurface` are the same APIs everywhere — there are no iOS-only types in the public API.

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
| `LiquidGlassLabels` | Labels — Liquid Glass Primary: Light `#1A1A1A`, Dark `#EDEDED` |
| `GlassButtonRole` / `GlassButtonProminence` | Kit **Destructive** and **Glass Prominent** (tinted / filled System Blue, white label) on `GlassButton` |
| `GlassButtonPalette` | Light / Dark System Blue, system red, filled label, disabled label. On `LiquidGlassTheme.buttons` |
| `GlassRadiusScale` / `LiquidGlassRadii` | `small` / `medium` / `large` corners (**18 / 26 / 34 待核验 vs Sketch**) |
| `LiquidGlassTokens` | Shared visual recipe (blur/sat = implementation approximation) |
| `LiquidGlassTheme` | `ThemeExtension` with both catalogs and `buttons`; `materialOf` / `styleOf` / `buttonPaletteOf` |
| `GlassSurface` / `GlassCard` | `material:` **or** `style:` + hover specular on pointer devices |
| `GlassButton` | Liquid Glass Button — Glass (Regular Small) / Clear / Destructive / Glass Prominent |
| `GlassTabBar` | iOS 27 tab bar. Liquid Glass **Dock** (not Materials Thick): standard full-width bar, floating capsule, tinted whole bar. `GlassTabBarStyle.sidebar` is reserved |
| `LiquidGlassMotion` | Standard / emphasized / quick curves; **reduce-motion** → `Duration.zero` |
| `LingyunAdaptivity` | Reduce Transparency, Reduce Motion, high-contrast overrides |
| `LingyunLayout` | Width classes, safe-area + layout margins, hinge/division band, wide-short heuristic, side-edge chrome |

### Specular / refraction conventions

Documented on `LiquidGlassTokens` and painted by `GlassSurface`:

- **Specular** — a *tight* top-leading catch (`edgeHighlightColor`) plus dark **inner-lip** bands (`innerShadowColor`) that approximate the kit's ±40 Y / −40 spread inner shadows. Not a full-face 2018 sheen or a focus ring.
- **Refraction** — directional **inner rim** (bright top-leading → quiet bottom-trailing). Distinct from the outer **grey ring** (`rimColor`, zero-blur +0.5 spread) and side hairlines (Sketch "Plus Darker", ~1.25 / −0.75).
- **Shadows** — soft deep drop (`shadowColor`, large blur, modest Y, negative spread) stacked with the crisp rim.
- **Rim** — ~0.5px hairline + multi-layer specular like Clear. **Not** linearly thickened by Materials tier (no 0.55→0.85).
- **Radius** — `GlassRadiusScale` 18 / 26 / 34 is **待核验 (unverified vs Sketch)** until measured in the kit. Override with `GlassSurface.radiusScale` or `borderRadius`. Regular Small buttons use a 48pt capsule, not 18.
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
  lingyun_ui_flutter: ^0.4.0
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

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

Breakpoints (logical px): compact &lt; 600, regular 600–839, expanded 840–1199, large ≥ 1200.

## Example gallery

```bash
cd example
flutter run -d chrome
flutter run -d macos
flutter run -d ios
```

Pages: **Materials** (Ultrathin / Thin / Regular / Thick + 待核验 radii), **Glass** (Clear / Regular S·M·L / Dock / Widget Glass + `GlassButton` states Default / Pressed / Disabled and variants Regular Small, Clear, Destructive, Glass Prominent), **Tabs** (`GlassTabBar`: standard edge-to-bottom, floating pill at 3, 4, and 5 items, System Blue selection, tinted whole bar; light/dark wallpaper), **Themes** (light / dark), **Layout** (phone / Duo cover / Duo inner / iPad / macOS presets + live window), **Access** (reduce transparency / motion / high contrast). The default backdrop is a flat design canvas (light `#D1D1D6`, dark `#000000`) so glass can sit next to the Sketch kit. A **Canvas** chip on every page switches that canvas, the previous muted wash, a nature scene, abstract color, and a busy UI pattern.

Open a page directly: `?page=tabs` (add `&theme=dark` and `&chrome=0` for a bare light/dark capture). Backdrop: `&bg=canvas` (default), `wash`, `meadow`, `abstract`, or `busy`.

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
