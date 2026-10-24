import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Host theme for Wave 1a controls.
///
/// The controls themselves are built with cupertino_ui. This harness is
/// [LiquidGlassTheme] on `material_ui`, which owns [ThemeExtension].
Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  bool reduceMotion = false,
}) {
  final glass = brightness == Brightness.dark
      ? LiquidGlassTheme.dark
      : LiquidGlassTheme.light;
  final theme = brightness == Brightness.dark
      ? ThemeData.dark()
      : ThemeData.light();
  return MaterialApp(
    theme: theme.copyWith(extensions: [glass]),
    home: LingyunTheme(
      brightness: brightness,
      child: LingyunAdaptivity(
        reduceMotion: reduceMotion,
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

List<Size> _customPaintSizes(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((paint) => tester.getSize(find.byWidget(paint)))
      .toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LingyunTheme liquid glass labels', () {
    test('kit primary and tertiary come from the color theme', () {
      expect(
        LingyunColors.light.liquidGlassLabels.primary,
        const Color(0xFF1A1A1A),
      );
      expect(
        LingyunColors.dark.liquidGlassLabels.primary,
        const Color(0xFFEDEDED),
      );
      expect(
        LingyunColors.light.liquidGlassLabels.tertiary,
        const Color(0xFFBFBFBF),
      );
      expect(
        LingyunColors.dark.liquidGlassLabels.tertiary,
        const Color(0xFF404040),
      );
      expect(
        LingyunColors.light.liquidGlassLabels.secondary,
        const Color(0xFF727272),
      );
      expect(
        LingyunColors.dark.liquidGlassLabels.secondary,
        const Color(0xFF8A8A8A),
      );
    });
  });

  group('GlassList', () {
    test('defaults are inset Regular Medium, not a Materials tier', () {
      const list = GlassList(
        sections: [
          GlassListSection(tiles: [GlassListTile(title: 'One')]),
        ],
      );
      expect(list.style, GlassListStyle.inset);
      expect(list.glassStyle, LiquidGlassStyle.regularMedium);
      expect(list.showSeparators, isTrue);
    });

    testWidgets('inset platter is Liquid Glass and separators are tertiary', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          GlassList(
            sections: [
              GlassListSection(
                header: 'Connectivity',
                footer: 'Known networks',
                tiles: const [
                  GlassListTile(
                    title: 'Wi-Fi',
                    subtitle: 'Home',
                    trailingText: 'On',
                    showChevron: true,
                    leading: Icon(CupertinoIcons.wifi),
                  ),
                  GlassListTile(title: 'Bluetooth', subtitle: 'Off'),
                ],
              ),
            ],
          ),
        ),
      );

      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.style, LiquidGlassStyle.regularMedium);
      expect(surface.material, isNull);
      expect(surface.tokens, isNull);

      final section = tester.widget<CupertinoListSection>(
        find.byType(CupertinoListSection),
      );
      expect(section.type, CupertinoListSectionType.insetGrouped);
      expect(
        section.separatorColor,
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
      expect(section.backgroundColor, CupertinoColors.transparent);

      expect(find.text('Connectivity'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('On'), findsOneWidget);
      expect(find.text('Known networks'), findsOneWidget);
      expect(find.byType(CupertinoListTileChevron), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.wifi), findsOneWidget);

      final subtitle = tester.widget<Text>(find.text('Home'));
      expect(subtitle.style?.inherit, isFalse);
      expect(
        subtitle.style?.color,
        LingyunColors.light.liquidGlassLabels.secondary,
      );
      expect(
        subtitle.style?.fontSize,
        LingyunTextStyles.subheadline().fontSize,
      );
      final trailing = tester.widget<Text>(find.text('On'));
      expect(trailing.style?.inherit, isFalse);
      expect(
        trailing.style?.color,
        LingyunColors.light.liquidGlassLabels.secondary,
      );
      expect(trailing.style?.fontSize, LingyunTextStyles.body().fontSize);
      final footerText = tester.widget<Text>(find.text('Known networks'));
      expect(footerText.maxLines, isNull);
      expect(footerText.style?.inherit, isFalse);
      expect(
        footerText.style?.color,
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
      expect(footerText.style?.fontSize, LingyunTextStyles.footnote().fontSize);
      final surfaceRect = tester.getRect(find.byType(GlassSurface));
      final footerRect = tester.getRect(find.text('Known networks'));
      expect(footerRect.top, greaterThanOrEqualTo(surfaceRect.bottom));
      expect(footerRect.height, greaterThanOrEqualTo(16));
      expect(
        find.descendant(
          of: find.byType(GlassSurface),
          matching: find.text('Known networks'),
        ),
        findsNothing,
      );
      final title = tester.widget<Text>(find.text('Wi-Fi'));
      expect(
        title.style,
        LingyunTextStyles.body(
          color: LingyunColors.light.liquidGlassLabels.primary,
        ),
      );
    });

    testWidgets('dark subtitles use dark secondary', (tester) async {
      await tester.pumpWidget(
        host(
          const GlassList(
            sections: [
              GlassListSection(
                tiles: [GlassListTile(title: 'Wi-Fi', subtitle: 'Home')],
              ),
            ],
          ),
          brightness: Brightness.dark,
        ),
      );
      final subtitle = tester.widget<Text>(find.text('Home'));
      expect(
        subtitle.style?.color,
        LingyunColors.dark.liquidGlassLabels.secondary,
      );
      final title = tester.widget<Text>(find.text('Wi-Fi'));
      expect(title.style?.color, LingyunColors.dark.liquidGlassLabels.primary);
    });

    testWidgets('plain list has separators and no glass platter', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const GlassList(
            style: GlassListStyle.plain,
            sections: [
              GlassListSection(
                header: 'Recent',
                tiles: [
                  GlassListTile(title: 'Design review'),
                  GlassListTile(title: 'Notes'),
                ],
              ),
            ],
          ),
        ),
      );
      expect(find.byType(GlassSurface), findsNothing);
      final section = tester.widget<CupertinoListSection>(
        find.byType(CupertinoListSection),
      );
      expect(section.type, CupertinoListSectionType.base);
      expect(
        section.separatorColor,
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
      expect(find.text('Recent'), findsOneWidget);
    });

    testWidgets('tap fires and a disabled row does not', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          GlassList(
            sections: [
              GlassListSection(
                tiles: [
                  GlassListTile(title: 'Wi-Fi', onTap: () => taps += 1),
                  GlassListTile(
                    title: 'Locked',
                    enabled: false,
                    onTap: () => taps += 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Wi-Fi'));
      await tester.pump();
      expect(taps, 1);
      await tester.tap(find.text('Locked'));
      await tester.pump();
      expect(taps, 1);
      final locked = tester.widget<Text>(find.text('Locked'));
      expect(
        locked.style?.color,
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
    });
  });

  group('GlassTextField', () {
    test('accent is error, then focus, otherwise none', () {
      const tint = Color(0xFF0088FF);
      const error = Color(0xFFFF383C);
      expect(
        GlassTextField.resolveAccent(
          enabled: true,
          focused: true,
          hasError: true,
          tint: tint,
          error: error,
        ),
        error,
      );
      expect(
        GlassTextField.resolveAccent(
          enabled: true,
          focused: true,
          hasError: false,
          tint: tint,
          error: error,
        ),
        tint,
      );
      expect(
        GlassTextField.resolveAccent(
          enabled: false,
          focused: true,
          hasError: false,
          tint: tint,
          error: error,
        ),
        isNull,
      );
    });

    testWidgets('chrome is Regular Small and the Cupertino fill is removed', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const GlassTextField(
            label: 'Name',
            placeholder: 'Required',
            helperText: 'Shown on your profile',
          ),
        ),
      );
      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.style, LiquidGlassStyle.regularSmall);
      expect(surface.material, isNull);
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.decoration?.color, const Color(0x00000000));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Shown on your profile'), findsOneWidget);
      final helper = tester.widget<Text>(find.text('Shown on your profile'));
      expect(
        helper.style,
        LingyunTextStyles.caption1(
          color: LingyunColors.light.liquidGlassLabels.tertiary,
        ),
      );
    });

    testWidgets('clear button empties the field', (tester) async {
      await tester.pumpWidget(host(const GlassTextField(label: 'Name')));
      await tester.enterText(find.byType(CupertinoTextField), 'Hello');
      await tester.pump();
      expect(find.text('Hello'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.clear_thick_circled), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.clear_thick_circled));
      await tester.pump();
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('error replaces the helper and uses system red', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const GlassTextField(
            label: 'Email',
            helperText: 'Work address',
            errorText: 'Enter a valid email',
          ),
        ),
      );
      expect(find.text('Work address'), findsNothing);
      final error = tester.widget<Text>(find.text('Enter a valid email'));
      expect(error.style?.color, LingyunColors.light.system.red);
    });

    testWidgets('disabled field keeps primary text and hides clear', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'lingyun');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          GlassTextField(
            controller: controller,
            label: 'Username',
            enabled: false,
          ),
        ),
      );
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.enabled, isFalse);
      expect(field.clearButtonMode, OverlayVisibilityMode.never);
      final label = tester.widget<Text>(find.text('Username'));
      expect(label.style?.color, LingyunColors.light.liquidGlassLabels.primary);
      expect(field.style?.color, LingyunColors.light.liquidGlassLabels.primary);
      expect(field.decoration?.color, const Color(0x00000000));
    });

    testWidgets('obscure toggle reveals the value', (tester) async {
      await tester.pumpWidget(
        host(
          const GlassTextField(
            label: 'Password',
            obscureText: true,
            obscureToggle: true,
          ),
        ),
      );
      CupertinoTextField field() =>
          tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(field().obscureText, isTrue);
      expect(find.byIcon(CupertinoIcons.eye), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.eye));
      await tester.pump();
      expect(field().obscureText, isFalse);
      expect(find.byIcon(CupertinoIcons.eye_slash), findsOneWidget);
    });
  });

  group('GlassProgressIndicator', () {
    test('clamp keeps Cupertino progress inside 0 to 1', () {
      expect(GlassProgressIndicator.clampProgress(-0.2), 0);
      expect(GlassProgressIndicator.clampProgress(0.4), 0.4);
      expect(GlassProgressIndicator.clampProgress(2), 1);
      expect(
        GlassProgressIndicator.resolveTint(
          systemBlue: const Color(0xFF0088FF),
          tint: const Color(0xFFFF383C),
        ),
        const Color(0xFFFF383C),
      );
    });

    testWidgets('linear determinate uses the Cupertino bar and System Blue', (
      tester,
    ) async {
      await tester.pumpWidget(host(const GlassProgressIndicator(value: 0.35)));
      final bar = tester.widget<CupertinoLinearActivityIndicator>(
        find.byType(CupertinoLinearActivityIndicator),
      );
      expect(bar.progress, 0.35);
      expect(bar.color, LingyunColors.light.system.blue);
      expect(find.byType(GlassSurface), findsNothing);
    });

    testWidgets('tint overrides System Blue', (tester) async {
      const red = Color(0xFFFF383C);
      await tester.pumpWidget(
        host(const GlassProgressIndicator(value: 1.4, tint: red)),
      );
      final bar = tester.widget<CupertinoLinearActivityIndicator>(
        find.byType(CupertinoLinearActivityIndicator),
      );
      expect(bar.progress, 1);
      expect(bar.color, red);
    });

    testWidgets('circular determinate is a ring, not activity ticks', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const GlassProgressIndicator(
            kind: GlassProgressKind.circular,
            value: 0.25,
          ),
        ),
      );
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(find.byType(CupertinoLinearActivityIndicator), findsNothing);
      final indicator = tester.widget<GlassProgressIndicator>(
        find.byType(GlassProgressIndicator),
      );
      expect(indicator.value, 0.25);
      expect(indicator.tint, isNull);
      expect(_customPaintSizes(tester), contains(const Size(20, 20)));
    });

    testWidgets('circular tint paints the ring, not a linear bar', (
      tester,
    ) async {
      const red = Color(0xFFFF383C);
      await tester.pumpWidget(
        host(
          const GlassProgressIndicator(
            kind: GlassProgressKind.circular,
            value: 0.6,
            radius: 16,
            tint: red,
          ),
        ),
      );
      expect(find.byType(CupertinoLinearActivityIndicator), findsNothing);
      final indicator = tester.widget<GlassProgressIndicator>(
        find.byType(GlassProgressIndicator),
      );
      expect(indicator.kind, GlassProgressKind.circular);
      expect(indicator.tint, red);
      expect(indicator.value, 0.6);
      expect(_customPaintSizes(tester), contains(const Size(32, 32)));
    });

    testWidgets('circular indeterminate spins until reduce motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const GlassProgressIndicator(kind: GlassProgressKind.circular)),
      );
      await tester.pump();
      final spinning = tester.widget<CupertinoActivityIndicator>(
        find.byType(CupertinoActivityIndicator),
      );
      expect(spinning.animating, isTrue);
      expect(spinning.progress, 1);

      await tester.pumpWidget(
        host(
          const GlassProgressIndicator(kind: GlassProgressKind.circular),
          reduceMotion: true,
        ),
      );
      await tester.pump();
      final still = tester.widget<CupertinoActivityIndicator>(
        find.byType(CupertinoActivityIndicator),
      );
      expect(still.animating, isFalse);
    });

    testWidgets('linear indeterminate settles when motion is reduced', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const GlassProgressIndicator(), reduceMotion: true),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoLinearActivityIndicator), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
