import 'package:material_ui/material_ui.dart';

import '../tokens/lingyun_colors.dart';
import '../tokens/lingyun_text_styles.dart';

/// Material [ColorScheme] / [TextTheme] bridge.
///
/// Lingyun's own catalog is Cupertino-first ([LingyunColors],
/// [LingyunTextStyles]). These types exist only on `package:material_ui`,
/// so this file is the one place that imports it.
///
/// Roles with no Sketch variable are not given a new hex. Secondary,
/// tertiary, and the fixed accents repeat System Blue. Containers repeat
/// Backgrounds. Nothing here is a Material default purple, teal, or
/// `#121212` surface.
class LingyunMaterialTheme {
  const LingyunMaterialTheme._();

  /// White used on filled System Blue / System Red.
  ///
  /// Same value as `Labels/Dark/1 Primary` and `Backgrounds/Light/Primary`
  /// (`#FFFFFF`). Not a separate color variable.
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
    final opposite = LingyunColors.forBrightness(
      brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    );
    final blue = colors.system.blue;
    final label = colors.labels.primary;
    // Built directly. `ColorScheme.light()` / `dark().copyWith` writes the
    // unset roles from the Material defaults (purple `#6200EE`, teal
    // `#03DAC6`, error `#B00020` / `#CF6679`, dark surface `#121212`)
    // before the override is applied. Sketch has no second accent, so the
    // fixed roles repeat System Blue, and the dim / bright surfaces repeat
    // Backgrounds/Primary.
    return ColorScheme(
      brightness: brightness,
      primary: blue,
      onPrimary: filledLabel,
      primaryContainer: colors.backgrounds.secondary,
      onPrimaryContainer: label,
      primaryFixed: blue,
      primaryFixedDim: blue,
      onPrimaryFixed: filledLabel,
      onPrimaryFixedVariant: label,
      secondary: blue,
      onSecondary: filledLabel,
      secondaryContainer: colors.backgrounds.secondary,
      onSecondaryContainer: label,
      secondaryFixed: blue,
      secondaryFixedDim: blue,
      onSecondaryFixed: filledLabel,
      onSecondaryFixedVariant: label,
      tertiary: blue,
      onTertiary: filledLabel,
      tertiaryContainer: colors.backgrounds.tertiary,
      onTertiaryContainer: label,
      tertiaryFixed: blue,
      tertiaryFixedDim: blue,
      onTertiaryFixed: filledLabel,
      onTertiaryFixedVariant: label,
      error: colors.system.red,
      onError: filledLabel,
      errorContainer: colors.system.red,
      onErrorContainer: filledLabel,
      surface: colors.backgrounds.primary,
      onSurface: label,
      surfaceDim: colors.backgrounds.primary,
      surfaceBright: colors.backgrounds.primary,
      surfaceContainerLowest: colors.backgrounds.primary,
      surfaceContainerLow: colors.backgrounds.secondary,
      surfaceContainer: colors.backgrounds.secondary,
      surfaceContainerHigh: colors.backgrounds.tertiary,
      surfaceContainerHighest: colors.backgrounds.tertiary,
      onSurfaceVariant: colors.labels.secondary,
      outline: colors.separators.opaque,
      outlineVariant: colors.separators.nonOpaque,
      shadow: LingyunColors.light.labels.primary,
      scrim: LingyunColors.light.labels.primary,
      inverseSurface: opposite.backgrounds.primary,
      onInverseSurface: opposite.labels.primary,
      inversePrimary: opposite.system.blue,
      // No elevation tint. A tint would paint System Blue over Backgrounds.
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
    final label = colors.labels.primary;
    final quiet = colors.labels.tertiary;
    final wash = colors.fills.secondary;
    final hairline = colors.separators.nonOpaque;
    // Light keeps System Blue as the primary color. Dark follows the
    // Material 3 surface rule so a bar is not a solid blue plate: the
    // surface is still Backgrounds/Primary.
    final primaryColor = brightness == Brightness.dark
        ? colors.backgrounds.primary
        : colors.system.blue;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: primaryColor,
      // Sketch has no lighter or darker System Blue. Repeat the one blue
      // instead of the Material swatch (`#BBDEFB` / `#1976D2` / grey 500).
      primaryColorLight: colors.system.blue,
      primaryColorDark: colors.system.blue,
      scaffoldBackgroundColor: colors.backgrounds.primary,
      canvasColor: colors.backgrounds.primary,
      cardColor: colors.backgrounds.primary,
      dividerColor: colors.separators.opaque,
      focusColor: hairline,
      hoverColor: colors.fills.quinary,
      shadowColor: LingyunColors.light.labels.primary,
      splashColor: wash,
      highlightColor: wash,
      hintColor: colors.labels.secondary,
      disabledColor: quiet,
      unselectedWidgetColor: colors.labels.secondary,
      secondaryHeaderColor: colors.backgrounds.secondary,
      iconTheme: IconThemeData(color: label),
      primaryIconTheme: const IconThemeData(color: filledLabel),
      textTheme: textTheme(brightness),
      buttonTheme: ButtonThemeData(
        colorScheme: scheme,
        buttonColor: colors.system.blue,
        disabledColor: quiet,
        focusColor: hairline,
        hoverColor: colors.fills.quinary,
        highlightColor: wash,
        splashColor: wash,
      ),
    );
  }
}
