import 'package:cupertino_ui/cupertino_ui.dart';

/// One measured Sketch color variable, already resolved for a brightness.
@immutable
class LingyunSwatch {
  const LingyunSwatch(this.group, this.name, this.color);

  /// Sketch variable group, such as `System Colors` or `Labels - Liquid Glass`.
  final String group;

  /// Name inside [group], such as `Blue` or `Primary`.
  final String name;

  final Color color;
}

/// System Colors. Sketch group `System Colors`, Light or Dark.
@immutable
class LingyunSystemColors {
  const LingyunSystemColors({
    required this.red,
    required this.orange,
    required this.yellow,
    required this.green,
    required this.mint,
    required this.teal,
    required this.cyan,
    required this.blue,
    required this.indigo,
    required this.purple,
    required this.pink,
    required this.brown,
  });

  final Color red;
  final Color orange;
  final Color yellow;
  final Color green;
  final Color mint;
  final Color teal;
  final Color cyan;
  final Color blue;
  final Color indigo;
  final Color purple;
  final Color pink;
  final Color brown;

  List<LingyunSwatch> swatches(String group) => [
    LingyunSwatch(group, 'Red', red),
    LingyunSwatch(group, 'Orange', orange),
    LingyunSwatch(group, 'Yellow', yellow),
    LingyunSwatch(group, 'Green', green),
    LingyunSwatch(group, 'Mint', mint),
    LingyunSwatch(group, 'Teal', teal),
    LingyunSwatch(group, 'Cyan', cyan),
    LingyunSwatch(group, 'Blue', blue),
    LingyunSwatch(group, 'Indigo', indigo),
    LingyunSwatch(group, 'Purple', purple),
    LingyunSwatch(group, 'Pink', pink),
    LingyunSwatch(group, 'Brown', brown),
  ];
}

/// Labels / Primary through Quinary.
///
/// This is the system label ramp. It is not `Labels - Liquid Glass`.
@immutable
class LingyunLabelColors {
  const LingyunLabelColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.quaternary,
    required this.quinary,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color quaternary;
  final Color quinary;

  List<LingyunSwatch> swatches(String group) => [
    LingyunSwatch(group, 'Primary', primary),
    LingyunSwatch(group, 'Secondary', secondary),
    LingyunSwatch(group, 'Tertiary', tertiary),
    LingyunSwatch(group, 'Quaternary', quaternary),
    LingyunSwatch(group, 'Quinary', quinary),
  ];
}

/// Vibrant labels stop at Quaternary. Sketch does not define Quinary here.
@immutable
class LingyunVibrantLabelColors {
  const LingyunVibrantLabelColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.quaternary,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color quaternary;

  List<LingyunSwatch> swatches(String group) => [
    LingyunSwatch(group, 'Primary', primary),
    LingyunSwatch(group, 'Secondary', secondary),
    LingyunSwatch(group, 'Tertiary', tertiary),
    LingyunSwatch(group, 'Quaternary', quaternary),
  ];
}

/// `Labels - Liquid Glass`. Glass controls use these, not [LingyunLabelColors].
///
/// Light Primary `#1A1A1A` and Dark Primary `#EDEDED` match
/// [LiquidGlassLabels]. Tertiary matches the accepted disabled glass label
/// (`#BFBFBF` / `#404040`).
@immutable
class LingyunLiquidGlassLabelColors {
  const LingyunLiquidGlassLabelColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.quaternary,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color quaternary;

  List<LingyunSwatch> swatches(String group) => [
    LingyunSwatch(group, 'Primary', primary),
    LingyunSwatch(group, 'Secondary', secondary),
    LingyunSwatch(group, 'Tertiary', tertiary),
    LingyunSwatch(group, 'Quaternary', quaternary),
  ];
}

/// Backgrounds / Primary, Secondary, Tertiary.
@immutable
class LingyunBackgroundColors {
  const LingyunBackgroundColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;

  List<LingyunSwatch> swatches(String group) => [
    LingyunSwatch(group, 'Primary', primary),
    LingyunSwatch(group, 'Secondary', secondary),
    LingyunSwatch(group, 'Tertiary', tertiary),
  ];
}

/// Fills / Primary through Quinary. Vibrant fills stop at Tertiary.
@immutable
class LingyunFillColors {
  const LingyunFillColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.quaternary,
    required this.quinary,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color quaternary;
  final Color quinary;

  List<LingyunSwatch> swatches(String group) => [
    LingyunSwatch(group, 'Primary', primary),
    LingyunSwatch(group, 'Secondary', secondary),
    LingyunSwatch(group, 'Tertiary', tertiary),
    LingyunSwatch(group, 'Quaternary', quaternary),
    LingyunSwatch(group, 'Quinary', quinary),
  ];
}

/// Grays / Gray through Gray 6. Black and white are not separate variables.
@immutable
class LingyunGrayColors {
  const LingyunGrayColors({
    required this.gray,
    required this.gray2,
    required this.gray3,
    required this.gray4,
    required this.gray5,
    required this.gray6,
  });

  final Color gray;
  final Color gray2;
  final Color gray3;
  final Color gray4;
  final Color gray5;
  final Color gray6;

  List<LingyunSwatch> swatches(String group) => [
    LingyunSwatch(group, 'Gray', gray),
    LingyunSwatch(group, 'Gray 2', gray2),
    LingyunSwatch(group, 'Gray 3', gray3),
    LingyunSwatch(group, 'Gray 4', gray4),
    LingyunSwatch(group, 'Gray 5', gray5),
    LingyunSwatch(group, 'Gray 6', gray6),
  ];
}

/// Separators. Opaque, non-opaque, and vibrant are three different variables.
@immutable
class LingyunSeparatorColors {
  const LingyunSeparatorColors({
    required this.opaque,
    required this.nonOpaque,
    required this.vibrant,
  });

  final Color opaque;
  final Color nonOpaque;
  final Color vibrant;

  List<LingyunSwatch> swatches(String group) => [
    LingyunSwatch(group, 'Opaque', opaque),
    LingyunSwatch(group, 'Non-Opaque', nonOpaque),
    LingyunSwatch(group, 'Vibrant', vibrant),
  ];
}

/// iOS 27 color variables for one brightness.
///
/// Source of truth: 齐成云全端色系 SoT — Sketch Apple iOS 27 UI Kit Color
/// Variables (107), as extracted in `colors.json` / `colors.md`. Light and
/// Dark are the same semantic names. This catalog is that mapping only.
/// Eight-digit Sketch hex is RRGGBBAA; these [Color]s are Flutter AARRGGBB.
/// Alpha is the documented fraction rounded half away from zero onto 8 bits
/// (`0.3` → `0x4D`, matching the pen token `#3C3C434D`).
///
/// Not included, on purpose:
/// * `x- Kit` (Canvas Color, Symbol BG) — authoring chrome, not a system color.
/// * Increased Contrast — this export has no IC mode.
/// * Materials fills and Liquid Glass blur recipes — different systems.
/// * A second brand or platform palette. There is nowhere to put one.
@immutable
class LingyunColors {
  const LingyunColors({
    required this.system,
    required this.labels,
    required this.vibrantLabels,
    required this.liquidGlassLabels,
    required this.backgrounds,
    required this.elevatedBackgrounds,
    required this.groupedBackgrounds,
    required this.elevatedGroupedBackgrounds,
    required this.fills,
    required this.vibrantFills,
    required this.grays,
    required this.separators,
  });

  /// Light variables. Elevated backgrounds repeat Light — Sketch has no
  /// separate Light Elevated group. Dark mode is the one with an elevated ramp.
  static const LingyunColors light = LingyunColors(
    system: LingyunSystemColors(
      red: Color(0xFFFF383C),
      orange: Color(0xFFFF8D28),
      yellow: Color(0xFFFFCC00),
      green: Color(0xFF34C759),
      mint: Color(0xFF00C8B3),
      teal: Color(0xFF00C3D0),
      cyan: Color(0xFF00C0E8),
      blue: Color(0xFF0088FF),
      indigo: Color(0xFF6155F5),
      purple: Color(0xFFCB30E0),
      pink: Color(0xFFFF2D55),
      brown: Color(0xFFAC7F5E),
    ),
    labels: LingyunLabelColors(
      primary: Color(0xFF000000),
      secondary: Color(0x993C3C43),
      tertiary: Color(0x4D3C3C43),
      quaternary: Color(0x2E3C3C43),
      quinary: Color(0x173C3C43),
    ),
    vibrantLabels: LingyunVibrantLabelColors(
      primary: Color(0xFF000000),
      secondary: Color(0xFF999999),
      tertiary: Color(0xFFBFBFBF),
      quaternary: Color(0xFFD9D9D9),
    ),
    liquidGlassLabels: LingyunLiquidGlassLabelColors(
      primary: Color(0xFF1A1A1A),
      secondary: Color(0xFF727272),
      tertiary: Color(0xFFBFBFBF),
      quaternary: Color(0xFFD9D9D9),
    ),
    backgrounds: LingyunBackgroundColors(
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFFF2F2F7),
      tertiary: Color(0xFFFFFFFF),
    ),
    elevatedBackgrounds: LingyunBackgroundColors(
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFFF2F2F7),
      tertiary: Color(0xFFFFFFFF),
    ),
    groupedBackgrounds: LingyunBackgroundColors(
      primary: Color(0xFFF2F2F7),
      secondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFF2F2F7),
    ),
    elevatedGroupedBackgrounds: LingyunBackgroundColors(
      primary: Color(0xFFF2F2F7),
      secondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFF2F2F7),
    ),
    fills: LingyunFillColors(
      primary: Color(0x33787878),
      secondary: Color(0x29787880),
      tertiary: Color(0x1F767680),
      quaternary: Color(0x14747480),
      quinary: Color(0x05000000),
    ),
    vibrantFills: LingyunBackgroundColors(
      primary: Color(0xFFCCCCCC),
      secondary: Color(0xFFE0E0E0),
      tertiary: Color(0xFFEDEDED),
    ),
    grays: LingyunGrayColors(
      gray: Color(0xFF8E8E93),
      gray2: Color(0xFFAEAEB2),
      gray3: Color(0xFFC7C7CC),
      gray4: Color(0xFFD1D1D6),
      gray5: Color(0xFFE5E5EA),
      gray6: Color(0xFFF2F2F7),
    ),
    separators: LingyunSeparatorColors(
      opaque: Color(0xFFC6C6C8),
      nonOpaque: Color(0x1F000000),
      vibrant: Color(0xFFE6E6E6),
    ),
  );

  /// Dark variables, including Dark - Elevated backgrounds.
  static const LingyunColors dark = LingyunColors(
    system: LingyunSystemColors(
      red: Color(0xFFFF4245),
      orange: Color(0xFFFF9230),
      yellow: Color(0xFFFFD600),
      green: Color(0xFF30D158),
      mint: Color(0xFF00DAC3),
      teal: Color(0xFF00D2E0),
      cyan: Color(0xFF3CD3FE),
      blue: Color(0xFF0091FF),
      indigo: Color(0xFF6D7CFF),
      purple: Color(0xFFDB34F2),
      pink: Color(0xFFFF375F),
      brown: Color(0xFFB78A66),
    ),
    labels: LingyunLabelColors(
      primary: Color(0xFFFFFFFF),
      secondary: Color(0x99EBEBF5),
      tertiary: Color(0x4DEBEBF5),
      quaternary: Color(0x29EBEBF5),
      quinary: Color(0x17EBEBF5),
    ),
    vibrantLabels: LingyunVibrantLabelColors(
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFF999999),
      tertiary: Color(0xFF404040),
      quaternary: Color(0xFF262626),
    ),
    liquidGlassLabels: LingyunLiquidGlassLabelColors(
      primary: Color(0xFFEDEDED),
      secondary: Color(0xFF8A8A8A),
      tertiary: Color(0xFF404040),
      quaternary: Color(0xFF262626),
    ),
    backgrounds: LingyunBackgroundColors(
      primary: Color(0xFF000000),
      secondary: Color(0xFF1C1C1E),
      tertiary: Color(0xFF2C2C2E),
    ),
    elevatedBackgrounds: LingyunBackgroundColors(
      primary: Color(0xFF1C1C1E),
      secondary: Color(0xFF2C2C2E),
      tertiary: Color(0xFF3A3A3C),
    ),
    groupedBackgrounds: LingyunBackgroundColors(
      primary: Color(0xFF000000),
      secondary: Color(0xFF1C1C1E),
      tertiary: Color(0xFF2C2C2E),
    ),
    elevatedGroupedBackgrounds: LingyunBackgroundColors(
      primary: Color(0xFF1C1C1E),
      secondary: Color(0xFF2C2C2E),
      tertiary: Color(0xFF3A3A3C),
    ),
    fills: LingyunFillColors(
      primary: Color(0x5C787880),
      secondary: Color(0x52787880),
      tertiary: Color(0x3D767680),
      quaternary: Color(0x2E767680),
      quinary: Color(0x05767680),
    ),
    vibrantFills: LingyunBackgroundColors(
      primary: Color(0xFF333333),
      secondary: Color(0xFF1F1F1F),
      tertiary: Color(0xFF121212),
    ),
    grays: LingyunGrayColors(
      gray: Color(0xFF8E8E93),
      gray2: Color(0xFF636366),
      gray3: Color(0xFF48484A),
      gray4: Color(0xFF3A3A3C),
      gray5: Color(0xFF2C2C2E),
      gray6: Color(0xFF1C1C1E),
    ),
    separators: LingyunSeparatorColors(
      opaque: Color(0xFF38383A),
      nonOpaque: Color(0x1FFFFFFF),
      vibrant: Color(0xFF1A1A1A),
    ),
  );

  static LingyunColors forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  final LingyunSystemColors system;
  final LingyunLabelColors labels;
  final LingyunVibrantLabelColors vibrantLabels;
  final LingyunLiquidGlassLabelColors liquidGlassLabels;
  final LingyunBackgroundColors backgrounds;

  /// `Backgrounds / Dark - Elevated` in dark.
  ///
  /// Light repeats `Backgrounds / Light` because the kit has no Light Elevated
  /// variables.
  final LingyunBackgroundColors elevatedBackgrounds;
  final LingyunBackgroundColors groupedBackgrounds;
  final LingyunBackgroundColors elevatedGroupedBackgrounds;
  final LingyunFillColors fills;

  /// Vibrant fills only have three levels, so this reuses the three-color type.
  final LingyunBackgroundColors vibrantFills;
  final LingyunGrayColors grays;
  final LingyunSeparatorColors separators;

  List<LingyunSwatch> get swatches => [
    ...system.swatches('System Colors'),
    ...labels.swatches('Labels'),
    ...vibrantLabels.swatches('Labels - Vibrant'),
    ...liquidGlassLabels.swatches('Labels - Liquid Glass'),
    ...backgrounds.swatches('Backgrounds'),
    ...elevatedBackgrounds.swatches('Backgrounds - Elevated'),
    ...groupedBackgrounds.swatches('Backgrounds Grouped'),
    ...elevatedGroupedBackgrounds.swatches('Backgrounds Grouped - Elevated'),
    ...fills.swatches('Fills'),
    ...vibrantFills.swatches('Fills - Vibrant'),
    ...grays.swatches('Grays'),
    ...separators.swatches('Separators'),
  ];
}
