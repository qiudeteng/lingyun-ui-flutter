import 'package:cupertino_ui/cupertino_ui.dart';

import '../tokens/lingyun_colors.dart';
import '../tokens/lingyun_text_styles.dart';

/// Cupertino theme for the measured iOS 27 color and text catalogs.
///
/// This is the primary Lingyun theme. It does not replace [LiquidGlassTheme]:
/// Materials and Liquid Glass recipes stay on that extension. Colors here are
/// system variables, not glass materials.
///
/// [ColorScheme] and [TextTheme] live in `package:material_ui` and are built
/// by `LingyunMaterialTheme` only for that bridge.
class LingyunTheme extends InheritedWidget {
  const LingyunTheme({
    required this.brightness,
    required super.child,
    super.key,
  });

  final Brightness brightness;

  LingyunColors get colors => LingyunColors.forBrightness(brightness);

  /// Cupertino theme for [brightness].
  ///
  /// Bar background is left unset. Sheet / nav chrome is a Materials or
  /// Liquid Glass question, not a system-background token.
  static CupertinoThemeData cupertinoThemeFor(Brightness brightness) {
    final colors = LingyunColors.forBrightness(brightness);
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: colors.system.blue,
      // Labels/Dark/1 Primary is #FFFFFF. Same white in light and dark.
      primaryContrastingColor: LingyunColors.dark.labels.primary,
      scaffoldBackgroundColor: colors.backgrounds.primary,
      textTheme: LingyunTextStyles.cupertinoTextTheme(colors),
    );
  }

  CupertinoThemeData get cupertinoTheme => cupertinoThemeFor(brightness);

  static LingyunTheme of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<LingyunTheme>();
    assert(theme != null, 'LingyunTheme not found above this context.');
    return theme!;
  }

  static LingyunColors colorsOf(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<LingyunTheme>();
    if (theme != null) return theme.colors;
    final brightness =
        CupertinoTheme.maybeBrightnessOf(context) ?? Brightness.light;
    return LingyunColors.forBrightness(brightness);
  }

  @override
  bool updateShouldNotify(LingyunTheme oldWidget) {
    return brightness != oldWidget.brightness;
  }
}
