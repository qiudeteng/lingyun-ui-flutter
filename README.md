# lingyun-ui-flutter

Apple **Liquid Glass** inspired Flutter UI primitives — design tokens, a `ThemeExtension`, and a frosted `GlassSurface` widget.

**Dart package:** `lingyun_ui_flutter`  
**Display name:** lingyun-ui-flutter  
**License:** MIT  
**Dependencies:** Flutter SDK only (no third-party runtime packages)

## Features

| API | Role |
| --- | --- |
| `LiquidGlassTokens` | Blur sigma, saturation matrix, tint, edge highlight, border, shadow, opaque fallback |
| `LiquidGlassTheme` | `ThemeExtension` with light/dark presets and `tokensOf(context)` |
| `GlassSurface` | `BackdropFilter` + saturation + tint + edge highlight |
| `GlassCard` | Padded convenience wrapper |

Accessibility: when `MediaQuery.highContrast` is true, or when `forceOpaque: true` (reduce-transparency toggle), the surface uses a solid `opaqueFallbackColor` instead of blur.

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
        body: Stack(
          fit: StackFit.expand,
          children: [
            // colorful wallpaper behind glass
            const ColoredBox(color: Color(0xFF6C63FF)),
            Center(
              child: GlassSurface(
                padding: const EdgeInsets.all(24),
                child: const Text('Hello Liquid Glass'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Example

```bash
cd example
flutter run -d chrome   # or any device
```

The demo includes light/dark mode and a **Reduce transparency** switch that sets `forceOpaque` on glass panels.

## Development

```bash
dart format .
flutter analyze
flutter test
```

## License

MIT © 2026
