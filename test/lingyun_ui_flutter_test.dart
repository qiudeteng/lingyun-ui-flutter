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

    test('thin / regular / thick tiers differ', () {
      final materials = LiquidGlassMaterials.light;
      expect(materials.thin.blurSigma, lessThan(materials.regular.blurSigma));
      expect(materials.regular.blurSigma, lessThan(materials.thick.blurSigma));
      expect(materials.resolve(GlassMaterialTier.thin), materials.thin);
      expect(materials.resolve(GlassMaterialTier.thick), materials.thick);
    });

    test('radius scale is Large / Medium / Small, not a flat 24', () {
      expect(LiquidGlassRadii.large, 34);
      expect(LiquidGlassRadii.medium, 26);
      expect(LiquidGlassRadii.small, 18);
      expect(LiquidGlassRadii.large, isNot(24));
      final large = LiquidGlassTokens.light.withRadiusScale(
        GlassRadiusScale.large,
      );
      final small = LiquidGlassTokens.light.withRadiusScale(
        GlassRadiusScale.small,
      );
      expect(
        large.borderRadius,
        LiquidGlassRadii.borderRadius(GlassRadiusScale.large),
      );
      expect(
        small.borderRadius,
        LiquidGlassRadii.borderRadius(GlassRadiusScale.small),
      );
      expect(large.borderRadius, isNot(small.borderRadius));
    });

    test('shadow stack has deep shadow plus crisp rim', () {
      final shadows = LiquidGlassTokens.light.shadows;
      expect(shadows, hasLength(4));
      expect(shadows.first.blurRadius, greaterThan(20));
      expect(shadows[1].blurRadius, 0);
      expect(shadows[1].spreadRadius, LiquidGlassTokens.light.rimSpread);
    });

    test('boundedBlurFilter is distinct from unbounded blur', () {
      final a = LiquidGlassTokens.light.blurFilter;
      final b = LiquidGlassTokens.light.boundedBlurFilter(const Size(100, 80));
      expect(a, isNot(equals(b)));
    });

    test('forTier maps onto the matching family', () {
      expect(
        LiquidGlassTokens.light.forTier(GlassMaterialTier.thin),
        LiquidGlassTokens.lightThin,
      );
      expect(
        LiquidGlassTokens.dark.forTier(GlassMaterialTier.thick),
        LiquidGlassTokens.darkThick,
      );
      expect(
        LiquidGlassTokens.light.forTier(GlassMaterialTier.regular),
        LiquidGlassTokens.light,
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
      expect(b.refractionWidth, a.refractionWidth);

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
      late LiquidGlassTokens thin;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.light]),
          home: Builder(
            builder: (context) {
              resolved = LiquidGlassTheme.tokensOf(context);
              thin = LiquidGlassTheme.tokensOf(
                context,
                tier: GlassMaterialTier.thin,
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(resolved, LiquidGlassTokens.light);
      expect(thin, LiquidGlassTokens.lightThin);
    });

    test('lerp between light and dark', () {
      final mid = LiquidGlassTheme.light.lerp(LiquidGlassTheme.dark, 0.5);
      expect(mid.tokens.blurSigma, isNonZero);
    });
  });

  group('LiquidGlassMotion', () {
    testWidgets('reduce-motion zeros duration', (tester) async {
      late Duration reduced;
      late Duration full;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              reduced = LiquidGlassMotion.durationOf(
                context,
                const Duration(milliseconds: 360),
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(reduced, Duration.zero);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: LingyunAdaptivity(
            reduceMotion: true,
            child: Builder(
              builder: (context) {
                full = LiquidGlassMotion.durationOf(
                  context,
                  const Duration(milliseconds: 360),
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(full, Duration.zero);
    });
  });

  group('LingyunLayout', () {
    test('width classes from breakpoints', () {
      expect(LingyunLayout.widthClassForWidth(390), LingyunWidthClass.compact);
      expect(LingyunLayout.widthClassForWidth(700), LingyunWidthClass.regular);
      expect(
        LingyunLayout.widthClassForWidth(1024),
        LingyunWidthClass.expanded,
      );
      expect(LingyunLayout.widthClassForWidth(1440), LingyunWidthClass.large);
    });

    test('hinge band is centered', () {
      const size = Size(840, 640);
      final band = LingyunLayout.hingeBandOf(size);
      expect(band.center.dx, closeTo(420, 0.5));
      expect(band.height, 640);
      expect(band.width, greaterThanOrEqualTo(LingyunLayout.hingeBandMinWidth));
    });

    test('wide-short cover heuristic', () {
      expect(LingyunLayout.isWideShort(const Size(780, 360)), isTrue);
      expect(LingyunLayout.isWideShort(const Size(390, 844)), isFalse);
      expect(LingyunLayout.shouldAvoidHinge(const Size(390, 844)), isFalse);
      expect(LingyunLayout.shouldAvoidHinge(const Size(780, 360)), isTrue);
      expect(LingyunLayout.shouldAvoidHinge(const Size(1024, 768)), isTrue);
    });

    testWidgets('LingyunLayoutBuilder reports compact phone', (tester) async {
      late LingyunLayoutData data;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 390,
              height: 844,
              child: LingyunLayoutBuilder(
                builder: (_, captured) {
                  data = captured;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(data.widthClass, LingyunWidthClass.compact);
      expect(data.avoidHinge, isFalse);
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

    testWidgets('opaque fallback when reduceTransparency', (tester) async {
      await tester.pumpWidget(
        const LingyunAdaptivity(
          reduceTransparency: true,
          child: MaterialApp(
            home: Scaffold(body: GlassSurface(child: Text('rt'))),
          ),
        ),
      );
      expect(find.text('rt'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('radiusScale overrides token radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSurface(
              radiusScale: GlassRadiusScale.small,
              child: Text('radius-small'),
            ),
          ),
        ),
      );
      expect(find.text('radius-small'), findsOneWidget);
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('material tier is applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.light]),
          home: const Scaffold(
            body: GlassSurface(
              material: GlassMaterialTier.thin,
              child: Text('thin'),
            ),
          ),
        ),
      );
      expect(find.text('thin'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('GlassCard applies padding and material', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              material: GlassMaterialTier.thick,
              child: Text('card'),
            ),
          ),
        ),
      );
      expect(find.text('card'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });
  });
}
