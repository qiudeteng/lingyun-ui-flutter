import 'package:material_ui/material_ui.dart';

import '../tokens/lingyun_colors.dart';
import '../tokens/lingyun_text_styles.dart';

/// Material [ColorScheme] / [TextTheme] bridge.
///
/// Lingyun's own catalog is Cupertino-first ([LingyunColors],
/// [LingyunTextStyles]). These types exist only on `package:material_ui`,
/// so this file is the one place that imports it.
///
/// Roles with no Sketch variable are not given a new hex. Secondary and
/// tertiary accents repeat System Blue so a Material default purple is not
/// presented as an iOS system color. That repetition is a bridge, **待核验**
/// if a later kit names a Material secondary.
class LingyunMaterialTheme {
  const LingyunMaterialTheme._();

  /// White used on filled System Blue / System Red.
  ///
  /// Already accepted as the Glass Prominent label. Not a separate Sketch
  /// color variable.
  static const Color filledLabel = Color(0xFFFFFFFF);

  static const Map<LingyunTextRole, String> textThemeRoles =
      <LingyunTextRole, String>{
        LingyunTextRole.largeTitle: 'headlineLarge',
        LingyunTextRole.title1: 'headlineMedium',
        LingyunTextRole.title2: 'headlineSmall',
        LingyunTextRole.title3: 'titleLarge',
        LingyunTextRole.headline: 'titleMedium',
        LingyunTextRole.body: 'bodyLarge',
        LingyunTextRole.callout: 'bodyMedium',
        LingyunTextRole.subheadline: 'titleSmall',
        LingyunTextRole.footnote: 'bodySmall',
        LingyunTextRole.caption1: 'labelMedium',
        LingyunTextRole.caption2: 'labelSmall',
      };

  static ColorScheme colorScheme(Brightness brightness) {
    final colors = LingyunColors.forBrightness(brightness);
    final blue = colors.system.blue;
    final label = colors.labels.primary;
    final base = brightness == Brightness.dark
        ? const ColorScheme.dark()
        : const ColorScheme.light();
    return base.copyWith(
      primary: blue,
      onPrimary: filledLabel,
      primaryContainer: colors.backgrounds.secondary,
      onPrimaryContainer: label,
      secondary: blue,
      onSecondary: filledLabel,
      secondaryContainer: colors.backgrounds.secondary,
      onSecondaryContainer: label,
      tertiary: blue,
      onTertiary: filledLabel,
      tertiaryContainer: colors.backgrounds.tertiary,
      onTertiaryContainer: label,
      error: colors.system.red,
      onError: filledLabel,
      surface: colors.backgrounds.primary,
      onSurface: label,
      onSurfaceVariant: colors.labels.secondary,
      surfaceContainerLowest: colors.backgrounds.primary,
      surfaceContainerLow: colors.backgrounds.secondary,
      surfaceContainer: colors.backgrounds.secondary,
      surfaceContainerHigh: colors.backgrounds.tertiary,
      surfaceContainerHighest: colors.backgrounds.tertiary,
      outline: colors.separators.opaque,
      outlineVariant: colors.separators.nonOpaque,
      inverseSurface: LingyunColors.forBrightness(
        brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ).backgrounds.primary,
      onInverseSurface: LingyunColors.forBrightness(
        brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ).labels.primary,
      inversePrimary: LingyunColors.forBrightness(
        brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ).system.blue,
      surfaceTint: const Color(0x00000000),
    );
  }

  static TextTheme textTheme(Brightness brightness) {
    final color = LingyunColors.forBrightness(brightness).labels.primary;
    TextStyle paint(TextStyle style) => style.copyWith(color: color);
    return TextTheme(
      headlineLarge: paint(LingyunTextStyles.largeTitle()),
      headlineMedium: paint(LingyunTextStyles.title1()),
      headlineSmall: paint(LingyunTextStyles.title2()),
      titleLarge: paint(LingyunTextStyles.title3()),
      titleMedium: paint(LingyunTextStyles.headline()),
      titleSmall: paint(LingyunTextStyles.subheadline()),
      bodyLarge: paint(LingyunTextStyles.body()),
      bodyMedium: paint(LingyunTextStyles.callout()),
      bodySmall: paint(LingyunTextStyles.footnote()),
      labelLarge: paint(LingyunTextStyles.subheadline(emphasized: true)),
      labelMedium: paint(LingyunTextStyles.caption1()),
      labelSmall: paint(LingyunTextStyles.caption2()),
    );
  }

  static ThemeData themeData(Brightness brightness) {
    final colors = LingyunColors.forBrightness(brightness);
    final scheme = colorScheme(brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.backgrounds.primary,
      textTheme: textTheme(brightness),
    );
  }
}
