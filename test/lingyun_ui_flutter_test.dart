import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  group('LiquidGlassTokens', () {
    test('light and dark presets differ', () {
      expect(LiquidGlassTokens.light.blurSigma, isNonZero);
      expect(LiquidGlassTokens.dark.blurSigma, isNonZero);
      expect(
        LiquidGlassTokens.light.tintColor,
        isNot(LiquidGlassTokens.dark.tintColor),
      );
    });

    test('saturationMatrix is 20 entries', () {
      expect(LiquidGlassTokens.light.saturationMatrix, hasLength(20));
    });

    test('copyWith and lerp preserve structure', () {
      final a = LiquidGlassTokens.light;
      final b = a.copyWith(blurSigma: 40);
      expect(b.blurSigma, 40);
      expect(b.saturation, a.saturation);

      final mid = a.lerp(LiquidGlassTokens.dark, 0.5);
      expect(
        mid.blurSigma,
        closeTo((a.blurSigma + LiquidGlassTokens.dark.blurSigma) / 2, 0.01),
      );
    });

    test('equality', () {
      expect(LiquidGlassTokens.light, LiquidGlassTokens.light);
      expect(
        LiquidGlassTokens.light.copyWith(),
        equals(LiquidGlassTokens.light),
      );
    });
  });

  group('LiquidGlassTheme', () {
    testWidgets('of / tokensOf resolve from ThemeData', (tester) async {
      late LiquidGlassTokens resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.light]),
          home: Builder(
            builder: (context) {
              resolved = LiquidGlassTheme.tokensOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(resolved, LiquidGlassTokens.light);
    });

    test('lerp between light and dark', () {
      final mid = LiquidGlassTheme.light.lerp(LiquidGlassTheme.dark, 0.5);
      expect(mid.tokens.blurSigma, isNonZero);
    });
  });

  group('GlassSurface', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassSurface(child: Text('glass-child'))),
        ),
      );
      expect(find.text('glass-child'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('opaque fallback when forceOpaque', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSurface(forceOpaque: true, child: Text('opaque')),
          ),
        ),
      );
      expect(find.text('opaque'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('opaque fallback when highContrast', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: const MaterialApp(
            home: Scaffold(body: GlassSurface(child: Text('hc'))),
          ),
        ),
      );
      expect(find.text('hc'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('GlassCard applies padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassCard(child: Text('card'))),
        ),
      );
      expect(find.text('card'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });
  });
}
