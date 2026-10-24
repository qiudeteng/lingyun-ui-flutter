import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  group('LingyunColors', () {
    test('system blue and red match the accepted button colors', () {
      expect(LingyunColors.light.system.blue, const Color(0xFF0088FF));
      expect(LingyunColors.dark.system.blue, const Color(0xFF0091FF));
      expect(LingyunColors.light.system.red, const Color(0xFFFF383C));
      expect(LingyunColors.dark.system.red, const Color(0xFFFF4245));
      expect(
        LingyunColors.light.system.blue,
        GlassButtonPalette.systemBlueLight,
      );
      expect(LingyunColors.dark.system.red, GlassButtonPalette.systemRedDark);
    });

    test('glass labels stay distinct from system labels', () {
      expect(
        LingyunColors.light.liquidGlassLabels.primary,
        LiquidGlassLabels.lightPrimary,
      );
      expect(
        LingyunColors.dark.liquidGlassLabels.primary,
        LiquidGlassLabels.darkPrimary,
      );
      expect(
        LingyunColors.light.liquidGlassLabels.primary,
        isNot(LingyunColors.light.labels.primary),
      );
      expect(
        LingyunColors.dark.liquidGlassLabels.primary,
        isNot(LingyunColors.dark.labels.primary),
      );
      expect(
        LingyunColors.light.vibrantLabels.primary,
        isNot(LingyunColors.light.liquidGlassLabels.primary),
      );
      expect(
        LingyunColors.dark.vibrantLabels.primary,
        isNot(LingyunColors.dark.liquidGlassLabels.primary),
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
        LingyunColors.light.liquidGlassLabels.tertiary,
        GlassButtonPalette.disabledLabelLight,
      );
      expect(
        LingyunColors.dark.liquidGlassLabels.tertiary,
        GlassButtonPalette.disabledLabelDark,
      );
    });

    test('light primary fill is #787878 at 0x33, not #787880', () {
      expect(LingyunColors.light.fills.primary, const Color(0x33787878));
      expect(LingyunColors.dark.separators.nonOpaque, const Color(0x1FFFFFFF));
      expect(LingyunColors.light.labels.secondary, const Color(0x993C3C43));
    });

    test('light elevated backgrounds repeat the light variables', () {
      expect(
        LingyunColors.light.elevatedBackgrounds.primary,
        LingyunColors.light.backgrounds.primary,
      );
      expect(
        LingyunColors.dark.elevatedBackgrounds.primary,
        isNot(LingyunColors.dark.backgrounds.primary),
      );
      expect(
        LingyunColors.dark.elevatedBackgrounds.primary,
        const Color(0xFF1C1C1E),
      );
    });
  });

  group('LingyunTextStyles', () {
    test('Large styles match the Sketch export', () {
      expect(LingyunTextStyles.largeTitle().fontSize, 34);
      expect(LingyunTextStyles.largeTitle().height, 41 / 34);
      expect(LingyunTextStyles.largeTitle().fontWeight, FontWeight.w400);
      expect(
        LingyunTextStyles.largeTitle(emphasized: true).fontWeight,
        FontWeight.w700,
      );
      expect(LingyunTextStyles.largeTitle().letterSpacing, 0);
      expect(LingyunTextStyles.largeTitle().fontFamily, isNull);

      expect(
        LingyunTextStyles.title3(emphasized: true).fontWeight,
        FontWeight.w600,
      );
      expect(LingyunTextStyles.headline().fontWeight, FontWeight.w600);
      expect(
        LingyunTextStyles.headline(emphasized: true).fontWeight,
        FontWeight.w600,
      );
      expect(
        LingyunTextStyles.caption1(emphasized: true).fontWeight,
        FontWeight.w500,
      );
      expect(LingyunTextStyles.caption2().fontSize, 11);
      expect(LingyunTextStyles.caption2().height, 13 / 11);

      expect(
        LingyunTextStyles.body(leading: LingyunLeading.loose).height,
        24 / 17,
      );
      expect(
        LingyunTextStyles.body(leading: LingyunLeading.tight).height,
        20 / 17,
      );
      expect(
        LingyunTextStyles.style(
          LingyunTextRole.largeTitle,
          italic: true,
        ).fontStyle,
        FontStyle.normal,
      );
      expect(LingyunTextStyles.body(italic: true).fontStyle, FontStyle.italic);
    });

    test('TextTheme roles use the measured sizes', () {
      final theme = LingyunMaterialTheme.textTheme(Brightness.light);
      expect(theme.headlineLarge?.fontSize, 34);
      expect(theme.headlineLarge?.fontWeight, FontWeight.w400);
      expect(theme.bodyLarge?.fontSize, 17);
      expect(theme.bodyLarge?.fontWeight, FontWeight.w400);
      expect(theme.titleMedium?.fontWeight, FontWeight.w600);
      expect(theme.labelMedium?.fontSize, 12);
      expect(theme.labelSmall?.fontSize, 11);
      expect(theme.bodyLarge?.color, LingyunColors.light.labels.primary);
      expect(
        LingyunMaterialTheme.textThemeRoles[LingyunTextRole.caption2],
        'labelSmall',
      );
    });

    test('ColorScheme uses system blue, red, and label primary', () {
      final light = LingyunMaterialTheme.colorScheme(Brightness.light);
      final dark = LingyunMaterialTheme.colorScheme(Brightness.dark);
      expect(light.primary, const Color(0xFF0088FF));
      expect(dark.primary, const Color(0xFF0091FF));
      expect(light.error, const Color(0xFFFF383C));
      expect(light.onPrimary, LingyunMaterialTheme.filledLabel);
      expect(light.surface, const Color(0xFFFFFFFF));
      expect(light.onSurface, const Color(0xFF000000));
      expect(dark.onSurface, const Color(0xFFFFFFFF));
      expect(
        light.onSurface,
        isNot(LingyunColors.light.liquidGlassLabels.primary),
      );
      expect(light.secondary, light.primary);
      expect(light.outline, LingyunColors.light.separators.opaque);
      expect(light.surfaceTint, const Color(0x00000000));
    });
  });

  testWidgets('Cupertino theme primary is system blue', (tester) async {
    late Color primary;
    late TextStyle body;
    await tester.pumpWidget(
      CupertinoApp(
        theme: LingyunTheme.cupertinoThemeFor(Brightness.light),
        home: Builder(
          builder: (context) {
            final theme = CupertinoTheme.of(context);
            primary = theme.primaryColor;
            body = theme.textTheme.textStyle;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(primary, const Color(0xFF0088FF));
    expect(body.fontSize, 17);
    expect(body.fontWeight, FontWeight.w400);
  });
}
