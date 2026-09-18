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
| `GlassMaterialTier` | `thin` / `regular` / `thick` material recipes |
| `LiquidGlassTokens` / `LiquidGlassMaterials` | Blur, saturation, tint, **specular** highlight, **refraction** rim, border, shadow, opaque fallback |
| `LiquidGlassTheme` | `ThemeExtension` with light/dark material sets and `tokensOf(context, tier:)` |
| `GlassSurface` / `GlassCard` | BackdropFilter glass + hover specular on pointer devices |
| `LiquidGlassMotion` | Standard / emphasized / quick curves; **reduce-motion** → `Duration.zero` |
| `LingyunAdaptivity` | Reduce Transparency, Reduce Motion, high-contrast overrides |
| `LingyunLayout` | Width classes, safe-area + layout margins, hinge/division band, wide-short heuristic, side-edge chrome |

### Specular / refraction conventions

Documented on `LiquidGlassTokens` and painted by `GlassSurface`:

- **Specular** — directional wash on the glass *face*. Light is treated as coming from the **top-leading** corner and fading toward the bottom-trailing edge (`edgeHighlightColor`). Not a focus ring.
- **Refraction** — thinner, brighter **inner rim** (`refractionColor`, `refractionWidth`) just inside the outer hairline border, suggesting light bending at the edge.
- **Hover** (macOS / desktop web) may boost specular opacity. Touch devices never enter `MouseRegion`.

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

Pages: **Materials** (thin / regular / thick), **Themes** (light / dark), **Layout** (phone / Duo cover / Duo inner / iPad / macOS presets + live window), **Access** (reduce transparency / motion / high contrast).

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
