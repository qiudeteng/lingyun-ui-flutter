# lingyun-ui-flutter

Liquid Glass primitives for Flutter — design tokens, a `ThemeExtension`, a frosted `GlassSurface`, motion/accessibility helpers, and adaptive layout utilities.

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

## Features

| API | Role |
| --- | --- |
| `GlassMaterialTier` | `thin` / `regular` / `thick` material recipes (Sketch-adjacent: Clear / Regular Large / Widget Glass) |
| `GlassRadiusScale` / `LiquidGlassRadii` | `small` / `medium` / `large` corners (18 / 26 / 34) — not a flat 24 |
| `LiquidGlassTokens` / `LiquidGlassMaterials` | Blur, saturation, tint, luminosity/lighten overlay, **specular** catch, **inner-lip** shadows, directional **refraction** rim, grey rim ring, multi-shadow, opaque fallback |
| `LiquidGlassTheme` | `ThemeExtension` with light/dark material sets and `tokensOf(context, tier:)` |
| `GlassSurface` / `GlassCard` | Layered BackdropFilter glass + hover specular on pointer devices |
| `LiquidGlassMotion` | Standard / emphasized / quick curves; **reduce-motion** → `Duration.zero` |
| `LingyunAdaptivity` | Reduce Transparency, Reduce Motion, high-contrast overrides |
| `LingyunLayout` | Width classes, safe-area + layout margins, hinge/division band, wide-short heuristic, side-edge chrome |

### Specular / refraction conventions

Documented on `LiquidGlassTokens` and painted by `GlassSurface`:

- **Specular** — a *tight* top-leading catch (`edgeHighlightColor`) plus dark **inner-lip** bands (`innerShadowColor`) that approximate the kit's ±40 Y / −40 spread inner shadows. Not a full-face 2018 sheen or a focus ring.
- **Refraction** — directional **inner rim** (bright top-leading → quiet bottom-trailing). Distinct from the outer **grey ring** (`rimColor`, zero-blur +0.5 spread) and side hairlines (Sketch "Plus Darker", ~1.25 / −0.75).
- **Shadows** — soft deep drop (`shadowColor`, large blur, modest Y, negative spread) stacked with the crisp rim.
- **Radius** — `GlassRadiusScale.large` (34, Regular Large), `medium` (26), `small` (18). Override with `GlassSurface.radiusScale` or `borderRadius`.
- **Hover** (macOS / desktop web) may boost specular opacity. Touch devices never enter `MouseRegion`.

Sketch style names (Clear, Lock Screen Time, Widget Glass, Regular Large / Medium / Small) are **comments only** — this package does not claim Apple's API.

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
  lingyun_ui_flutter: ^0.1.0
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
            return GlassSurface(
              material: GlassMaterialTier.regular,
              radiusScale: GlassRadiusScale.large,
              padding: const EdgeInsets.all(24),
              child: Text('Width class: ${layout.widthClass.name}'),
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

Pages: **Materials** (thin / regular / thick + Large / Medium / Small radius), **Themes** (light / dark), **Layout** (phone / Duo cover / Duo inner / iPad / macOS presets + live window), **Access** (reduce transparency / motion / high contrast). The gallery wallpaper is a muted light/dark system wash so materials read like kit previews.

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
