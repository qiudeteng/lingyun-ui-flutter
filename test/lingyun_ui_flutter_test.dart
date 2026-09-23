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

    test('Materials Ultrathin / Thin / Regular / Thick differ', () {
      final materials = MaterialCatalog.light;
      expect(materials.ultrathin.blurSigma, lessThan(materials.thin.blurSigma));
      expect(materials.thin.blurSigma, lessThan(materials.regular.blurSigma));
      expect(materials.regular.blurSigma, lessThan(materials.thick.blurSigma));
      expect(materials.resolve(MaterialTier.ultrathin), materials.ultrathin);
      expect(materials.resolve(MaterialTier.thin), materials.thin);
      expect(materials.resolve(MaterialTier.thick), materials.thick);
    });

    test('Materials tiers are not Liquid Glass styles', () {
      expect(
        MaterialTier.values.map((e) => e.name),
        containsAll(['ultrathin', 'thin', 'regular', 'thick']),
      );
      expect(
        LiquidGlassStyle.values.map((e) => e.name),
        containsAll([
          'clear',
          'regularSmall',
          'regularMedium',
          'regularLarge',
          'dock',
          'widgetGlass',
        ]),
      );
      expect(
        MaterialCatalog.light.regular,
        isNot(LiquidGlassCatalog.light.regularLarge),
      );
      expect(
        MaterialCatalog.light.thick,
        isNot(LiquidGlassCatalog.light.widgetGlass),
      );
      expect(MaterialCatalog.light.thin, isNot(LiquidGlassCatalog.light.clear));
    });

    test('rim is a 0.5 hairline — not linearly thickened by tier', () {
      const hairline = LiquidGlassTokens.hairlineWidth;
      expect(hairline, 0.5);
      for (final tokens in [
        MaterialCatalog.light.ultrathin,
        MaterialCatalog.light.thin,
        MaterialCatalog.light.regular,
        MaterialCatalog.light.thick,
        LiquidGlassCatalog.light.clear,
        LiquidGlassCatalog.light.regularSmall,
        LiquidGlassCatalog.light.regularLarge,
        LiquidGlassCatalog.light.dock,
        LiquidGlassCatalog.light.widgetGlass,
      ]) {
        expect(tokens.borderWidth, hairline);
        expect(tokens.refractionWidth, hairline);
        expect(tokens.rimSpread, hairline);
      }
    });

    test('Liquid Glass labels are kit Primary colors', () {
      expect(LiquidGlassLabels.lightPrimary, const Color(0xFF1A1A1A));
      expect(LiquidGlassLabels.darkPrimary, const Color(0xFFEDEDED));
      expect(
        LiquidGlassLabels.contrastingOn(const Color(0xFFFFFFFF)),
        LiquidGlassLabels.lightPrimary,
      );
      expect(
        LiquidGlassLabels.contrastingOn(const Color(0xFF111111)),
        LiquidGlassLabels.darkPrimary,
      );
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

    test('forTier maps Materials; forStyle maps Liquid Glass', () {
      expect(
        LiquidGlassTokens.light.forTier(MaterialTier.thin),
        LiquidGlassTokens.lightThin,
      );
      expect(
        LiquidGlassTokens.light.forTier(MaterialTier.ultrathin),
        LiquidGlassTokens.lightUltrathin,
      );
      expect(
        LiquidGlassTokens.dark.forTier(MaterialTier.thick),
        LiquidGlassTokens.darkThick,
      );
      expect(
        LiquidGlassTokens.light.forTier(MaterialTier.regular),
        LiquidGlassTokens.light,
      );
      expect(
        LiquidGlassTokens.light.forStyle(LiquidGlassStyle.regularSmall),
        LiquidGlassTokens.lightRegularSmall,
      );
      expect(
        LiquidGlassTokens.dark.forStyle(LiquidGlassStyle.clear),
        LiquidGlassTokens.darkClear,
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
    testWidgets('of / materialOf / styleOf resolve from ThemeData', (
      tester,
    ) async {
      late LiquidGlassTokens materialRegular;
      late LiquidGlassTokens glassDefault;
      late LiquidGlassTokens thin;
      late LiquidGlassTokens button;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.light]),
          home: Builder(
            builder: (context) {
              materialRegular = LiquidGlassTheme.tokensOf(context);
              glassDefault = LiquidGlassTheme.of(context).tokens;
              thin = LiquidGlassTheme.materialOf(context, MaterialTier.thin);
              button = LiquidGlassTheme.styleOf(
                context,
                LiquidGlassStyle.regularSmall,
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(materialRegular, LiquidGlassTokens.materialLightRegular);
      expect(glassDefault, LiquidGlassTokens.light);
      expect(materialRegular, isNot(glassDefault));
      expect(thin, LiquidGlassTokens.lightThin);
      expect(button, LiquidGlassTokens.lightRegularSmall);
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
              material: MaterialTier.thin,
              child: Text('thin'),
            ),
          ),
        ),
      );
      expect(find.text('thin'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('Liquid Glass style is applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.light]),
          home: const Scaffold(
            body: GlassSurface(
              style: LiquidGlassStyle.clear,
              child: Text('clear'),
            ),
          ),
        ),
      );
      expect(find.text('clear'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('GlassCard applies padding and material', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(material: MaterialTier.thick, child: Text('card')),
          ),
        ),
      );
      expect(find.text('card'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });

    testWidgets('GlassButton defaults to Regular Small', (tester) async {
      late LiquidGlassTokens resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.light]),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                resolved = LiquidGlassTheme.styleOf(
                  context,
                  LiquidGlassStyle.regularSmall,
                );
                return GlassButton.label(label: 'Do it', onPressed: () {});
              },
            ),
          ),
        ),
      );
      expect(find.text('Do it'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
      expect(resolved, LiquidGlassTokens.lightRegularSmall);
      final context = tester.element(find.text('Do it'));
      expect(
        DefaultTextStyle.of(context).style.color,
        LiquidGlassLabels.lightPrimary,
      );
    });

    testWidgets('Clear stays on the Clear style path', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.light]),
          home: Scaffold(
            body: GlassButton.label(
              label: 'Clear',
              style: LiquidGlassStyle.clear,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Clear'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('Destructive, Prominent, Pressed, and Disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.light]),
          home: Scaffold(
            body: Column(
              children: [
                GlassButton.label(
                  key: const Key('std'),
                  label: 'Save',
                  onPressed: () {},
                ),
                GlassButton.label(
                  key: const Key('dest'),
                  label: 'Delete',
                  role: GlassButtonRole.destructive,
                  onPressed: () {},
                ),
                GlassButton.label(
                  key: const Key('prom'),
                  label: 'Continue',
                  prominence: GlassButtonProminence.prominent,
                  onPressed: () {},
                ),
                GlassButton.label(
                  key: const Key('prom-dest'),
                  label: 'Remove',
                  role: GlassButtonRole.destructive,
                  prominence: GlassButtonProminence.prominent,
                  onPressed: () {},
                ),
                GlassButton.label(
                  key: const Key('off'),
                  label: 'Off',
                  prominence: GlassButtonProminence.prominent,
                  onPressed: null,
                ),
                GlassButton.label(
                  key: const Key('held'),
                  label: 'Held',
                  forcePressed: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      Color labelOf(String text) {
        return DefaultTextStyle.of(
          tester.element(find.text(text)),
        ).style.color!;
      }

      expect(labelOf('Delete'), GlassButtonPalette.light.systemRed);
      expect(labelOf('Continue'), GlassButtonPalette.light.filledLabel);
      expect(labelOf('Remove'), GlassButtonPalette.light.filledLabel);
      expect(labelOf('Off'), GlassButtonPalette.light.disabledLabel);
      expect(labelOf('Held'), LiquidGlassLabels.lightPrimary);

      final held = tester.widget<AnimatedScale>(
        find.descendant(
          of: find.byKey(const Key('held')),
          matching: find.byType(AnimatedScale),
        ),
      );
      expect(held.scale, 0.97);

      await tester.press(find.byKey(const Key('std')));
      await tester.pump();
      final pressed = tester.widget<AnimatedScale>(
        find.descendant(
          of: find.byKey(const Key('std')),
          matching: find.byType(AnimatedScale),
        ),
      );
      expect(pressed.scale, 0.97);

      final disabled = tester.widget<AnimatedScale>(
        find.descendant(
          of: find.byKey(const Key('off')),
          matching: find.byType(AnimatedScale),
        ),
      );
      expect(disabled.scale, 1);

      for (final material in tester.widgetList<Material>(
        find.byType(Material),
      )) {
        expect(material.elevation, 0);
      }
      expect(find.byType(BackdropFilter), findsWidgets);
    });
  });

  group('GlassButton treatments', () {
    test('palette matches the Buttons page samples', () {
      expect(GlassButtonPalette.light.systemBlue, const Color(0xFF0088FF));
      expect(GlassButtonPalette.dark.systemBlue, const Color(0xFF0091FF));
      expect(GlassButtonPalette.light.systemRed, const Color(0xFFFF383C));
      expect(GlassButtonPalette.dark.systemRed, const Color(0xFFFF4245));
      expect(GlassButtonPalette.light.filledLabel, const Color(0xFFFFFFFF));
      expect(GlassButtonPalette.light.disabledLabel, const Color(0xFF6D6D6F));
      expect(GlassButtonPalette.dark.disabledLabel, const Color(0xFF59595C));
    });

    test('Prominent tints Regular Small and never uses Materials Thick', () {
      final base = LiquidGlassTokens.lightRegularSmall;
      final prominent = GlassButton.resolveTokens(
        base: base,
        palette: GlassButtonPalette.light,
        prominence: GlassButtonProminence.prominent,
        role: GlassButtonRole.normal,
        enabled: true,
      );
      expect(prominent.borderWidth, LiquidGlassTokens.hairlineWidth);
      expect(prominent.refractionWidth, LiquidGlassTokens.hairlineWidth);
      expect(prominent.borderRadius, base.borderRadius);
      expect(
        prominent.opaqueFallbackColor,
        GlassButtonPalette.light.systemBlue,
      );
      expect(prominent, isNot(LiquidGlassTokens.lightThick));
      expect(
        prominent.tintColor,
        isNot(LiquidGlassTokens.lightThick.tintColor),
      );
      expect(prominent.blurSigma, base.blurSigma);

      final destructive = GlassButton.resolveTokens(
        base: base,
        palette: GlassButtonPalette.light,
        prominence: GlassButtonProminence.prominent,
        role: GlassButtonRole.destructive,
        enabled: true,
      );
      expect(
        destructive.opaqueFallbackColor,
        GlassButtonPalette.light.systemRed,
      );

      final disabledProminent = GlassButton.resolveTokens(
        base: base,
        palette: GlassButtonPalette.light,
        prominence: GlassButtonProminence.prominent,
        role: GlassButtonRole.normal,
        enabled: false,
      );
      expect(disabledProminent, base);

      final glassDestructive = GlassButton.resolveTokens(
        base: base,
        palette: GlassButtonPalette.light,
        prominence: GlassButtonProminence.glass,
        role: GlassButtonRole.destructive,
        enabled: true,
      );
      expect(glassDestructive, base);
    });

    test('dark destructive label uses the dark system red', () {
      expect(
        GlassButton.resolveLabelColor(
          palette: GlassButtonPalette.dark,
          brightness: Brightness.dark,
          role: GlassButtonRole.destructive,
          prominence: GlassButtonProminence.glass,
          enabled: true,
        ),
        GlassButtonPalette.dark.systemRed,
      );
      expect(
        GlassButton.resolveLabelColor(
          palette: GlassButtonPalette.dark,
          brightness: Brightness.dark,
          role: GlassButtonRole.normal,
          prominence: GlassButtonProminence.glass,
          enabled: false,
        ),
        GlassButtonPalette.dark.disabledLabel,
      );
    });

    testWidgets('buttonPaletteOf follows the theme extension', (tester) async {
      late GlassButtonPalette palette;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [LiquidGlassTheme.dark]),
          home: Builder(
            builder: (context) {
              palette = LiquidGlassTheme.buttonPaletteOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(palette, GlassButtonPalette.dark);
    });
  });
}
