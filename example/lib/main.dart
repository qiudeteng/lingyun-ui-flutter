import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  runApp(const LingyunGlassDemoApp());
}

class LingyunGlassDemoApp extends StatefulWidget {
  const LingyunGlassDemoApp({super.key});

  @override
  State<LingyunGlassDemoApp> createState() => _LingyunGlassDemoAppState();
}

class _LingyunGlassDemoAppState extends State<LingyunGlassDemoApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _reduceTransparency = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lingyun-ui-flutter',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF5B8DEF),
        extensions: const [LiquidGlassTheme.light],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF5B8DEF),
        extensions: const [LiquidGlassTheme.dark],
      ),
      home: DemoHome(
        themeMode: _themeMode,
        reduceTransparency: _reduceTransparency,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        onReduceTransparencyChanged: (v) =>
            setState(() => _reduceTransparency = v),
      ),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({
    super.key,
    required this.themeMode,
    required this.reduceTransparency,
    required this.onThemeModeChanged,
    required this.onReduceTransparencyChanged,
  });

  final ThemeMode themeMode;
  final bool reduceTransparency;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onReduceTransparencyChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _ColorfulWallpaper(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassSurface(
                    forceOpaque: reduceTransparency,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'lingyun-ui-flutter',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Toggle light / dark',
                          onPressed: () {
                            onThemeModeChanged(
                              isDark ? ThemeMode.light : ThemeMode.dark,
                            );
                          },
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    forceOpaque: reduceTransparency,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Liquid Glass',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Backdrop blur, boosted saturation, soft tint, and an '
                          'edge highlight — with an opaque fallback for '
                          'reduce-transparency / high-contrast.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reduce transparency'),
                          subtitle: const Text(
                            'Opaque glass fallback (accessibility)',
                          ),
                          value: reduceTransparency,
                          onChanged: onReduceTransparencyChanged,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Dark mode'),
                          value: isDark,
                          onChanged: (v) => onThemeModeChanged(
                            v ? ThemeMode.dark : ThemeMode.light,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: GlassSurface(
                            forceOpaque: reduceTransparency,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panel A',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Text(
                                  reduceTransparency
                                      ? 'Opaque mode'
                                      : 'Frosted blur',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassSurface(
                            forceOpaque: reduceTransparency,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panel B',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                const Icon(Icons.layers_rounded, size: 36),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vibrant multi-stop gradient wallpaper so glass blur / tint is visible.
class _ColorfulWallpaper extends StatelessWidget {
  const _ColorfulWallpaper();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B9D),
            Color(0xFFC44DFF),
            Color(0xFF5B8DEF),
            Color(0xFF2EE6A6),
            Color(0xFFFFD56B),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _BlobPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0x66FF8A65);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      size.shortestSide * 0.35,
      paint,
    );

    paint.color = const Color(0x667C4DFF);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.25),
      size.shortestSide * 0.4,
      paint,
    );

    paint.color = const Color(0x6640C4FF);
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.75),
      size.shortestSide * 0.45,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
