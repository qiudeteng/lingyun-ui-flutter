import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Locks LingyunColors to the Sketch Color Variables in colors.json.
///
/// Not a second palette. Expected ARGB is the sRGB hex plus the
/// documented alpha, rounded half away from zero onto 8 bits.
/// `x- Kit` stays out: it is authoring chrome.
void main() {
  test('system, label, background, fill, gray, and separator tokens match colors.json', () {
    expect(
      LingyunColors.light.system.red,
      const Color(0xFFFF383C),
      reason: 'System Colors/Light/1 Red',
    );
    expect(
      LingyunColors.dark.system.red,
      const Color(0xFFFF4245),
      reason: 'System Colors/Dark/1 Red',
    );
    expect(
      LingyunColors.light.system.orange,
      const Color(0xFFFF8D28),
      reason: 'System Colors/Light/2 Orange',
    );
    expect(
      LingyunColors.dark.system.orange,
      const Color(0xFFFF9230),
      reason: 'System Colors/Dark/2 Orange',
    );
    expect(
      LingyunColors.light.system.yellow,
      const Color(0xFFFFCC00),
      reason: 'System Colors/Light/3 Yellow',
    );
    expect(
      LingyunColors.dark.system.yellow,
      const Color(0xFFFFD600),
      reason: 'System Colors/Dark/3 Yellow',
    );
    expect(
      LingyunColors.light.system.green,
      const Color(0xFF34C759),
      reason: 'System Colors/Light/4 Green',
    );
    expect(
      LingyunColors.dark.system.green,
      const Color(0xFF30D158),
      reason: 'System Colors/Dark/4 Green',
    );
    expect(
      LingyunColors.light.system.mint,
      const Color(0xFF00C8B3),
      reason: 'System Colors/Light/5 Mint',
    );
    expect(
      LingyunColors.dark.system.mint,
      const Color(0xFF00DAC3),
      reason: 'System Colors/Dark/5 Mint',
    );
    expect(
      LingyunColors.light.system.teal,
      const Color(0xFF00C3D0),
      reason: 'System Colors/Light/6 Teal',
    );
    expect(
      LingyunColors.dark.system.teal,
      const Color(0xFF00D2E0),
      reason: 'System Colors/Dark/6 Teal',
    );
    expect(
      LingyunColors.light.system.cyan,
      const Color(0xFF00C0E8),
      reason: 'System Colors/Light/7 Cyan',
    );
    expect(
      LingyunColors.dark.system.cyan,
      const Color(0xFF3CD3FE),
      reason: 'System Colors/Dark/7 Cyan',
    );
    expect(
      LingyunColors.light.system.blue,
      const Color(0xFF0088FF),
      reason: 'System Colors/Light/8 Blue',
    );
    expect(
      LingyunColors.dark.system.blue,
      const Color(0xFF0091FF),
      reason: 'System Colors/Dark/8 Blue',
    );
    expect(
      LingyunColors.light.system.indigo,
      const Color(0xFF6155F5),
      reason: 'System Colors/Light/9 Indigo',
    );
    expect(
      LingyunColors.dark.system.indigo,
      const Color(0xFF6D7CFF),
      reason: 'System Colors/Dark/9 Indigo',
    );
    expect(
      LingyunColors.light.system.purple,
      const Color(0xFFCB30E0),
      reason: 'System Colors/Light/10 Purple',
    );
    expect(
      LingyunColors.dark.system.purple,
      const Color(0xFFDB34F2),
      reason: 'System Colors/Dark/10 Purple',
    );
    expect(
      LingyunColors.light.system.pink,
      const Color(0xFFFF2D55),
      reason: 'System Colors/Light/11 Pink',
    );
    expect(
      LingyunColors.dark.system.pink,
      const Color(0xFFFF375F),
      reason: 'System Colors/Dark/11 Pink',
    );
    expect(
      LingyunColors.light.system.brown,
      const Color(0xFFAC7F5E),
      reason: 'System Colors/Light/12 Brown',
    );
    expect(
      LingyunColors.dark.system.brown,
      const Color(0xFFB78A66),
      reason: 'System Colors/Dark/12 Brown',
    );
    expect(
      LingyunColors.light.labels.primary,
      const Color(0xFF000000),
      reason: 'Labels/Light/1 Primary',
    );
    expect(
      LingyunColors.dark.labels.primary,
      const Color(0xFFFFFFFF),
      reason: 'Labels/Dark/1 Primary',
    );
    expect(
      LingyunColors.light.labels.secondary,
      const Color(0x993C3C43),
      reason: 'Labels/Light/2 Secondary',
    );
    expect(
      LingyunColors.dark.labels.secondary,
      const Color(0x99EBEBF5),
      reason: 'Labels/Dark/2 Secondary',
    );
    expect(
      LingyunColors.light.labels.tertiary,
      const Color(0x4D3C3C43),
      reason: 'Labels/Light/3 Tertiary',
    );
    expect(
      LingyunColors.dark.labels.tertiary,
      const Color(0x4DEBEBF5),
      reason: 'Labels/Dark/3 Tertiary',
    );
    expect(
      LingyunColors.light.labels.quaternary,
      const Color(0x2E3C3C43),
      reason: 'Labels/Light/4 Quaternary',
    );
    expect(
      LingyunColors.dark.labels.quaternary,
      const Color(0x29EBEBF5),
      reason: 'Labels/Dark/4 Quaternary',
    );
    expect(
      LingyunColors.light.labels.quinary,
      const Color(0x173C3C43),
      reason: 'Labels/Light/5 Quinary',
    );
    expect(
      LingyunColors.dark.labels.quinary,
      const Color(0x17EBEBF5),
      reason: 'Labels/Dark/5 Quinary',
    );
    expect(
      LingyunColors.light.vibrantLabels.primary,
      const Color(0xFF000000),
      reason: 'Labels/Light - Vibrant/1 Primary',
    );
    expect(
      LingyunColors.dark.vibrantLabels.primary,
      const Color(0xFFFFFFFF),
      reason: 'Labels/Dark - Vibrant/1 Primary',
    );
    expect(
      LingyunColors.light.vibrantLabels.secondary,
      const Color(0xFF999999),
      reason: 'Labels/Light - Vibrant/2 Secondary',
    );
    expect(
      LingyunColors.dark.vibrantLabels.secondary,
      const Color(0xFF999999),
      reason: 'Labels/Dark - Vibrant/2 Secondary',
    );
    expect(
      LingyunColors.light.vibrantLabels.tertiary,
      const Color(0xFFBFBFBF),
      reason: 'Labels/Light - Vibrant/3 Tertiary',
    );
    expect(
      LingyunColors.dark.vibrantLabels.tertiary,
      const Color(0xFF404040),
      reason: 'Labels/Dark - Vibrant/3 Tertiary',
    );
    expect(
      LingyunColors.light.vibrantLabels.quaternary,
      const Color(0xFFD9D9D9),
      reason: 'Labels/Light - Vibrant/4 Quaternary',
    );
    expect(
      LingyunColors.dark.vibrantLabels.quaternary,
      const Color(0xFF262626),
      reason: 'Labels/Dark - Vibrant/4 Quaternary',
    );
    expect(
      LingyunColors.light.liquidGlassLabels.primary,
      const Color(0xFF1A1A1A),
      reason: 'Labels - Liquid Glass/Light/1 Primary',
    );
    expect(
      LingyunColors.dark.liquidGlassLabels.primary,
      const Color(0xFFEDEDED),
      reason: 'Labels - Liquid Glass/Dark/1 Primary',
    );
    expect(
      LingyunColors.light.liquidGlassLabels.secondary,
      const Color(0xFF727272),
      reason: 'Labels - Liquid Glass/Light/2 Secondary',
    );
    expect(
      LingyunColors.dark.liquidGlassLabels.secondary,
      const Color(0xFF8A8A8A),
      reason: 'Labels - Liquid Glass/Dark/2 Secondary',
    );
    expect(
      LingyunColors.light.liquidGlassLabels.tertiary,
      const Color(0xFFBFBFBF),
      reason: 'Labels - Liquid Glass/Light/3 Tertiary',
    );
    expect(
      LingyunColors.dark.liquidGlassLabels.tertiary,
      const Color(0xFF404040),
      reason: 'Labels - Liquid Glass/Dark/3 Tertiary',
    );
    expect(
      LingyunColors.light.liquidGlassLabels.quaternary,
      const Color(0xFFD9D9D9),
      reason: 'Labels - Liquid Glass/Light/4 Quaternary',
    );
    expect(
      LingyunColors.dark.liquidGlassLabels.quaternary,
      const Color(0xFF262626),
      reason: 'Labels - Liquid Glass/Dark/4 Quaternary',
    );
    expect(
      LingyunColors.light.backgrounds.primary,
      const Color(0xFFFFFFFF),
      reason: 'Backgrounds/Light/Primary',
    );
    expect(
      LingyunColors.dark.backgrounds.primary,
      const Color(0xFF000000),
      reason: 'Backgrounds/Dark - Base/Primary',
    );
    expect(
      LingyunColors.light.elevatedBackgrounds.primary,
      const Color(0xFFFFFFFF),
      reason: 'Backgrounds/Light/Primary',
    );
    expect(
      LingyunColors.dark.elevatedBackgrounds.primary,
      const Color(0xFF1C1C1E),
      reason: 'Backgrounds/Dark - Elevated/Primary',
    );
    expect(
      LingyunColors.light.groupedBackgrounds.primary,
      const Color(0xFFF2F2F7),
      reason: 'Backgrounds Grouped/Light/Primary',
    );
    expect(
      LingyunColors.dark.groupedBackgrounds.primary,
      const Color(0xFF000000),
      reason: 'Backgrounds Grouped/Dark - Base/Primary',
    );
    expect(
      LingyunColors.light.elevatedGroupedBackgrounds.primary,
      const Color(0xFFF2F2F7),
      reason: 'Backgrounds Grouped/Light/Primary',
    );
    expect(
      LingyunColors.dark.elevatedGroupedBackgrounds.primary,
      const Color(0xFF1C1C1E),
      reason: 'Backgrounds Grouped/Dark - Elevated/Primary',
    );
    expect(
      LingyunColors.light.backgrounds.secondary,
      const Color(0xFFF2F2F7),
      reason: 'Backgrounds/Light/Secondary',
    );
    expect(
      LingyunColors.dark.backgrounds.secondary,
      const Color(0xFF1C1C1E),
      reason: 'Backgrounds/Dark - Base/Secondary',
    );
    expect(
      LingyunColors.light.elevatedBackgrounds.secondary,
      const Color(0xFFF2F2F7),
      reason: 'Backgrounds/Light/Secondary',
    );
    expect(
      LingyunColors.dark.elevatedBackgrounds.secondary,
      const Color(0xFF2C2C2E),
      reason: 'Backgrounds/Dark - Elevated/Secondary',
    );
    expect(
      LingyunColors.light.groupedBackgrounds.secondary,
      const Color(0xFFFFFFFF),
      reason: 'Backgrounds Grouped/Light/Secondary',
    );
    expect(
      LingyunColors.dark.groupedBackgrounds.secondary,
      const Color(0xFF1C1C1E),
      reason: 'Backgrounds Grouped/Dark - Base/Secondary',
    );
    expect(
      LingyunColors.light.elevatedGroupedBackgrounds.secondary,
      const Color(0xFFFFFFFF),
      reason: 'Backgrounds Grouped/Light/Secondary',
    );
    expect(
      LingyunColors.dark.elevatedGroupedBackgrounds.secondary,
      const Color(0xFF2C2C2E),
      reason: 'Backgrounds Grouped/Dark - Elevated/Secondary',
    );
    expect(
      LingyunColors.light.backgrounds.tertiary,
      const Color(0xFFFFFFFF),
      reason: 'Backgrounds/Light/Tertiary',
    );
    expect(
      LingyunColors.dark.backgrounds.tertiary,
      const Color(0xFF2C2C2E),
      reason: 'Backgrounds/Dark - Base/Tertiary',
    );
    expect(
      LingyunColors.light.elevatedBackgrounds.tertiary,
      const Color(0xFFFFFFFF),
      reason: 'Backgrounds/Light/Tertiary',
    );
    expect(
      LingyunColors.dark.elevatedBackgrounds.tertiary,
      const Color(0xFF3A3A3C),
      reason: 'Backgrounds/Dark - Elevated/Tertiary',
    );
    expect(
      LingyunColors.light.groupedBackgrounds.tertiary,
      const Color(0xFFF2F2F7),
      reason: 'Backgrounds Grouped/Light/Tertiary',
    );
    expect(
      LingyunColors.dark.groupedBackgrounds.tertiary,
      const Color(0xFF2C2C2E),
      reason: 'Backgrounds Grouped/Dark - Base/Tertiary',
    );
    expect(
      LingyunColors.light.elevatedGroupedBackgrounds.tertiary,
      const Color(0xFFF2F2F7),
      reason: 'Backgrounds Grouped/Light/Tertiary',
    );
    expect(
      LingyunColors.dark.elevatedGroupedBackgrounds.tertiary,
      const Color(0xFF3A3A3C),
      reason: 'Backgrounds Grouped/Dark - Elevated/Tertiary',
    );
    expect(
      LingyunColors.light.fills.primary,
      const Color(0x33787878),
      reason: 'Fills/Light/1 Primary',
    );
    expect(
      LingyunColors.dark.fills.primary,
      const Color(0x5C787880),
      reason: 'Fills/Dark/1 Primary',
    );
    expect(
      LingyunColors.light.fills.secondary,
      const Color(0x29787880),
      reason: 'Fills/Light/2 Secondary',
    );
    expect(
      LingyunColors.dark.fills.secondary,
      const Color(0x52787880),
      reason: 'Fills/Dark/2 Secondary',
    );
    expect(
      LingyunColors.light.fills.tertiary,
      const Color(0x1F767680),
      reason: 'Fills/Light/3 Tertiary',
    );
    expect(
      LingyunColors.dark.fills.tertiary,
      const Color(0x3D767680),
      reason: 'Fills/Dark/3 Tertiary',
    );
    expect(
      LingyunColors.light.fills.quaternary,
      const Color(0x14747480),
      reason: 'Fills/Light/4 Quaternary',
    );
    expect(
      LingyunColors.dark.fills.quaternary,
      const Color(0x2E767680),
      reason: 'Fills/Dark/4 Quaternary',
    );
    expect(
      LingyunColors.light.fills.quinary,
      const Color(0x05000000),
      reason: 'Fills/Light/5 Quinary',
    );
    expect(
      LingyunColors.dark.fills.quinary,
      const Color(0x05767680),
      reason: 'Fills/Dark/5 Quinary',
    );
    expect(
      LingyunColors.light.vibrantFills.primary,
      const Color(0xFFCCCCCC),
      reason: 'Fills/Light - Vibrant/1 Primary',
    );
    expect(
      LingyunColors.dark.vibrantFills.primary,
      const Color(0xFF333333),
      reason: 'Fills/Dark - Vibrant/1 Primary',
    );
    expect(
      LingyunColors.light.vibrantFills.secondary,
      const Color(0xFFE0E0E0),
      reason: 'Fills/Light - Vibrant/2 Secondary',
    );
    expect(
      LingyunColors.dark.vibrantFills.secondary,
      const Color(0xFF1F1F1F),
      reason: 'Fills/Dark - Vibrant/2 Secondary',
    );
    expect(
      LingyunColors.light.vibrantFills.tertiary,
      const Color(0xFFEDEDED),
      reason: 'Fills/Light - Vibrant/3 Tertiary',
    );
    expect(
      LingyunColors.dark.vibrantFills.tertiary,
      const Color(0xFF121212),
      reason: 'Fills/Dark - Vibrant/3 Tertiary',
    );
    expect(
      LingyunColors.light.grays.gray,
      const Color(0xFF8E8E93),
      reason: 'Grays/Light/Gray',
    );
    expect(
      LingyunColors.dark.grays.gray,
      const Color(0xFF8E8E93),
      reason: 'Grays/Dark/Gray',
    );
    expect(
      LingyunColors.light.grays.gray2,
      const Color(0xFFAEAEB2),
      reason: 'Grays/Light/Gray 2',
    );
    expect(
      LingyunColors.dark.grays.gray2,
      const Color(0xFF636366),
      reason: 'Grays/Dark/Gray 2',
    );
    expect(
      LingyunColors.light.grays.gray3,
      const Color(0xFFC7C7CC),
      reason: 'Grays/Light/Gray 3',
    );
    expect(
      LingyunColors.dark.grays.gray3,
      const Color(0xFF48484A),
      reason: 'Grays/Dark/Gray 3',
    );
    expect(
      LingyunColors.light.grays.gray4,
      const Color(0xFFD1D1D6),
      reason: 'Grays/Light/Gray 4',
    );
    expect(
      LingyunColors.dark.grays.gray4,
      const Color(0xFF3A3A3C),
      reason: 'Grays/Dark/Gray 4',
    );
    expect(
      LingyunColors.light.grays.gray5,
      const Color(0xFFE5E5EA),
      reason: 'Grays/Light/Gray 5',
    );
    expect(
      LingyunColors.dark.grays.gray5,
      const Color(0xFF2C2C2E),
      reason: 'Grays/Dark/Gray 5',
    );
    expect(
      LingyunColors.light.grays.gray6,
      const Color(0xFFF2F2F7),
      reason: 'Grays/Light/Gray 6',
    );
    expect(
      LingyunColors.dark.grays.gray6,
      const Color(0xFF1C1C1E),
      reason: 'Grays/Dark/Gray 6',
    );
    expect(
      LingyunColors.light.separators.opaque,
      const Color(0xFFC6C6C8),
      reason: 'Separators/Light/Opaque',
    );
    expect(
      LingyunColors.dark.separators.opaque,
      const Color(0xFF38383A),
      reason: 'Separators/Dark/Opaque',
    );
    expect(
      LingyunColors.light.separators.nonOpaque,
      const Color(0x1F000000),
      reason: 'Separators/Light/Non-Opaque',
    );
    expect(
      LingyunColors.dark.separators.nonOpaque,
      const Color(0x1FFFFFFF),
      reason: 'Separators/Dark/Non-Opaque',
    );
    expect(
      LingyunColors.light.separators.vibrant,
      const Color(0xFFE6E6E6),
      reason: 'Separators/Light/Vibrant',
    );
    expect(
      LingyunColors.dark.separators.vibrant,
      const Color(0xFF1A1A1A),
      reason: 'Separators/Dark/Vibrant',
    );
  });

  test('swatches cover the product groups and skip x- Kit', () {
    expect(LingyunColors.light.swatches, hasLength(54));
    expect(LingyunColors.dark.swatches, hasLength(54));
    final groups = LingyunColors.light.swatches.map((s) => s.group).toSet();
    expect(groups, {
      'System Colors',
      'Labels',
      'Labels - Vibrant',
      'Labels - Liquid Glass',
      'Backgrounds',
      'Backgrounds - Elevated',
      'Backgrounds Grouped',
      'Backgrounds Grouped - Elevated',
      'Fills',
      'Fills - Vibrant',
      'Grays',
      'Separators',
    });
    for (final swatch in [
      ...LingyunColors.light.swatches,
      ...LingyunColors.dark.swatches,
    ]) {
      expect(swatch.group, isNot(contains('x- Kit')));
      expect(swatch.group, isNot(contains('Canvas')));
    }
  });

  test('ColorScheme roles stay on LingyunColors', () {
    const banned = <Color>[
      Color(0xFF6200EE),
      Color(0xFF6750A4),
      Color(0xFF03DAC6),
      Color(0xFFB00020),
      Color(0xFFCF6679),
      Color(0xFF121212),
      Color(0xFFBB86FC),
      Color(0xFFFFFBFE),
    ];
    final allowed = <Color>{
      const Color(0x00000000),
      for (final swatch in [
        ...LingyunColors.light.swatches,
        ...LingyunColors.dark.swatches,
      ])
        swatch.color,
    };
    for (final brightness in [Brightness.light, Brightness.dark]) {
      final colors = LingyunColors.forBrightness(brightness);
      final scheme = LingyunMaterialTheme.colorScheme(brightness);
      final roles = <String, Color>{
        'primary': scheme.primary,
        'onPrimary': scheme.onPrimary,
        'primaryContainer': scheme.primaryContainer,
        'onPrimaryContainer': scheme.onPrimaryContainer,
        'primaryFixed': scheme.primaryFixed,
        'primaryFixedDim': scheme.primaryFixedDim,
        'onPrimaryFixed': scheme.onPrimaryFixed,
        'onPrimaryFixedVariant': scheme.onPrimaryFixedVariant,
        'secondary': scheme.secondary,
        'onSecondary': scheme.onSecondary,
        'secondaryContainer': scheme.secondaryContainer,
        'onSecondaryContainer': scheme.onSecondaryContainer,
        'secondaryFixed': scheme.secondaryFixed,
        'secondaryFixedDim': scheme.secondaryFixedDim,
        'onSecondaryFixed': scheme.onSecondaryFixed,
        'onSecondaryFixedVariant': scheme.onSecondaryFixedVariant,
        'tertiary': scheme.tertiary,
        'onTertiary': scheme.onTertiary,
        'tertiaryContainer': scheme.tertiaryContainer,
        'onTertiaryContainer': scheme.onTertiaryContainer,
        'tertiaryFixed': scheme.tertiaryFixed,
        'tertiaryFixedDim': scheme.tertiaryFixedDim,
        'onTertiaryFixed': scheme.onTertiaryFixed,
        'onTertiaryFixedVariant': scheme.onTertiaryFixedVariant,
        'error': scheme.error,
        'onError': scheme.onError,
        'errorContainer': scheme.errorContainer,
        'onErrorContainer': scheme.onErrorContainer,
        'surface': scheme.surface,
        'onSurface': scheme.onSurface,
        'surfaceDim': scheme.surfaceDim,
        'surfaceBright': scheme.surfaceBright,
        'surfaceContainerLowest': scheme.surfaceContainerLowest,
        'surfaceContainerLow': scheme.surfaceContainerLow,
        'surfaceContainer': scheme.surfaceContainer,
        'surfaceContainerHigh': scheme.surfaceContainerHigh,
        'surfaceContainerHighest': scheme.surfaceContainerHighest,
        'onSurfaceVariant': scheme.onSurfaceVariant,
        'outline': scheme.outline,
        'outlineVariant': scheme.outlineVariant,
        'shadow': scheme.shadow,
        'scrim': scheme.scrim,
        'inverseSurface': scheme.inverseSurface,
        'onInverseSurface': scheme.onInverseSurface,
        'inversePrimary': scheme.inversePrimary,
        'surfaceTint': scheme.surfaceTint,
      };
      for (final entry in roles.entries) {
        expect(banned, isNot(contains(entry.value)), reason: entry.key);
        expect(
          allowed,
          contains(entry.value),
          reason: '${entry.key} ${entry.value}',
        );
      }
      expect(scheme.primary, colors.system.blue);
      expect(scheme.secondary, colors.system.blue);
      expect(scheme.tertiary, colors.system.blue);
      expect(scheme.primaryFixed, colors.system.blue);
      expect(scheme.error, colors.system.red);
      expect(scheme.errorContainer, colors.system.red);
      expect(scheme.surface, colors.backgrounds.primary);
      expect(scheme.surfaceDim, colors.backgrounds.primary);
      expect(scheme.surfaceBright, colors.backgrounds.primary);
      expect(scheme.onSurface, colors.labels.primary);
      expect(scheme.onPrimary, LingyunColors.dark.labels.primary);
      expect(scheme.outline, colors.separators.opaque);
      expect(scheme.outlineVariant, colors.separators.nonOpaque);
      expect(scheme.shadow, LingyunColors.light.labels.primary);
      expect(scheme.surfaceTint, const Color(0x00000000));
      final theme = LingyunMaterialTheme.themeData(brightness);
      final themeColors = <String, Color>{
        'primaryColor': theme.primaryColor,
        'primaryColorLight': theme.primaryColorLight,
        'primaryColorDark': theme.primaryColorDark,
        'scaffoldBackgroundColor': theme.scaffoldBackgroundColor,
        'canvasColor': theme.canvasColor,
        'cardColor': theme.cardColor,
        'dividerColor': theme.dividerColor,
        'focusColor': theme.focusColor,
        'hoverColor': theme.hoverColor,
        'shadowColor': theme.shadowColor,
        'splashColor': theme.splashColor,
        'highlightColor': theme.highlightColor,
        'hintColor': theme.hintColor,
        'disabledColor': theme.disabledColor,
        'unselectedWidgetColor': theme.unselectedWidgetColor,
        'secondaryHeaderColor': theme.secondaryHeaderColor,
        'iconTheme': theme.iconTheme.color!,
        'primaryIconTheme': theme.primaryIconTheme.color!,
        'buttonColor': theme.buttonTheme.colorScheme!.primary,
      };
      for (final entry in themeColors.entries) {
        expect(banned, isNot(contains(entry.value)), reason: entry.key);
        expect(
          allowed,
          contains(entry.value),
          reason: '${entry.key} ${entry.value}',
        );
      }
      expect(theme.hoverColor, colors.fills.quinary);
      expect(theme.hintColor, colors.labels.secondary);
      expect(theme.disabledColor, colors.labels.tertiary);
      expect(theme.splashColor, colors.fills.secondary);
      expect(
        LingyunMaterialTheme.filledLabel,
        LingyunColors.dark.labels.primary,
      );
      expect(theme.primaryColorLight, colors.system.blue);
      expect(theme.primaryColorDark, colors.system.blue);
      expect(theme.scaffoldBackgroundColor, colors.backgrounds.primary);
    }
  });

  test('Cupertino contrasting color is Labels/Dark/1 Primary', () {
    final light = LingyunTheme.cupertinoThemeFor(Brightness.light);
    final dark = LingyunTheme.cupertinoThemeFor(Brightness.dark);
    expect(light.primaryColor, LingyunColors.light.system.blue);
    expect(dark.primaryColor, LingyunColors.dark.system.blue);
    expect(light.primaryContrastingColor, LingyunColors.dark.labels.primary);
    expect(dark.primaryContrastingColor, LingyunColors.dark.labels.primary);
    expect(
      light.scaffoldBackgroundColor,
      LingyunColors.light.backgrounds.primary,
    );
    expect(
      dark.scaffoldBackgroundColor,
      LingyunColors.dark.backgrounds.primary,
    );
  });
}
