import 'package:cupertino_ui/cupertino_ui.dart';

import 'lingyun_colors.dart';

/// Sketch text-style roles. Names match the UI Kit, not Material.
enum LingyunTextRole {
  largeTitle,
  title1,
  title2,
  title3,
  headline,
  body,
  callout,
  subheadline,
  footnote,
  caption1,
  caption2,
}

/// Leading exported as its own Sketch group (standard is the default style).
enum LingyunLeading { standard, loose, tight }

/// Point size, line height, and weights measured from one Sketch text style.
@immutable
class LingyunTextMetrics {
  const LingyunTextMetrics({
    required this.fontSize,
    required this.lineHeight,
    required this.looseLineHeight,
    required this.tightLineHeight,
    required this.weight,
    required this.emphasizedWeight,
    required this.hasItalic,
  });

  final double fontSize;

  /// Standard leading, in logical pixels (not a unitless multiplier).
  final double lineHeight;
  final double looseLineHeight;
  final double tightLineHeight;
  final FontWeight weight;
  final FontWeight emphasizedWeight;

  /// Sketch exports an italic face for this role.
  ///
  /// Large Title, Title 1, Title 2, and Title 3 do not. Headline's only
  /// italic face is Bold Italic, at the same Semibold weight as Default.
  final bool hasItalic;

  double heightFor(LingyunLeading leading) {
    return switch (leading) {
      LingyunLeading.standard => lineHeight,
      LingyunLeading.loose => looseLineHeight,
      LingyunLeading.tight => tightLineHeight,
    };
  }
}

/// iOS 27 text styles at the Large content size.
///
/// Source of truth: Sketch UI Kit text styles (same document as
/// [LingyunColors]). The DTCG export reports size, a unitless line-height
/// multiple, and a weight. Line heights below are that multiple times the
/// size, and they land on whole points.
///
/// The kit face is SF Pro. This package does not bundle SF Pro, so styles
/// leave [TextStyle.fontFamily] unset and use the ambient font.
///
/// Letter-spacing in the Sketch export is 0 for every style. Figma Text
/// Styles `0:2194` was not re-read, so tracking stays **待核验** against that
/// page. Dynamic Type sizes other than Large are not in the text-style
/// export and are not invented here.
///
/// Caption 1 emphasized is weight 500. The style is named Bold in the kit,
/// and the axis value is 500. Title 3 emphasized is Semibold (600), not Bold.
/// Headline's default face is already Semibold.
class LingyunTextStyles {
  const LingyunTextStyles._();

  static const Map<LingyunTextRole, LingyunTextMetrics> metrics =
      <LingyunTextRole, LingyunTextMetrics>{
        LingyunTextRole.largeTitle: LingyunTextMetrics(
          fontSize: 34,
          lineHeight: 41,
          looseLineHeight: 43,
          tightLineHeight: 39,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w700,
          hasItalic: false,
        ),
        LingyunTextRole.title1: LingyunTextMetrics(
          fontSize: 28,
          lineHeight: 34,
          looseLineHeight: 36,
          tightLineHeight: 32,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w700,
          hasItalic: false,
        ),
        LingyunTextRole.title2: LingyunTextMetrics(
          fontSize: 22,
          lineHeight: 28,
          looseLineHeight: 30,
          tightLineHeight: 26,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w700,
          hasItalic: false,
        ),
        LingyunTextRole.title3: LingyunTextMetrics(
          fontSize: 20,
          lineHeight: 25,
          looseLineHeight: 27,
          tightLineHeight: 23,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w600,
          hasItalic: false,
        ),
        LingyunTextRole.headline: LingyunTextMetrics(
          fontSize: 17,
          lineHeight: 22,
          looseLineHeight: 24,
          tightLineHeight: 20,
          weight: FontWeight.w600,
          emphasizedWeight: FontWeight.w600,
          hasItalic: true,
        ),
        LingyunTextRole.body: LingyunTextMetrics(
          fontSize: 17,
          lineHeight: 22,
          looseLineHeight: 24,
          tightLineHeight: 20,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w600,
          hasItalic: true,
        ),
        LingyunTextRole.callout: LingyunTextMetrics(
          fontSize: 16,
          lineHeight: 21,
          looseLineHeight: 23,
          tightLineHeight: 19,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w600,
          hasItalic: true,
        ),
        LingyunTextRole.subheadline: LingyunTextMetrics(
          fontSize: 15,
          lineHeight: 20,
          looseLineHeight: 22,
          tightLineHeight: 18,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w600,
          hasItalic: true,
        ),
        LingyunTextRole.footnote: LingyunTextMetrics(
          fontSize: 13,
          lineHeight: 18,
          looseLineHeight: 20,
          tightLineHeight: 16,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w600,
          hasItalic: true,
        ),
        LingyunTextRole.caption1: LingyunTextMetrics(
          fontSize: 12,
          lineHeight: 16,
          looseLineHeight: 18,
          tightLineHeight: 14,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w500,
          hasItalic: true,
        ),
        LingyunTextRole.caption2: LingyunTextMetrics(
          fontSize: 11,
          lineHeight: 13,
          looseLineHeight: 15,
          tightLineHeight: 11,
          weight: FontWeight.w400,
          emphasizedWeight: FontWeight.w600,
          hasItalic: true,
        ),
      };

  static TextStyle style(
    LingyunTextRole role, {
    bool emphasized = false,
    bool italic = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    final metrics = LingyunTextStyles.metrics[role]!;
    final useItalic = italic && metrics.hasItalic;
    return TextStyle(
      fontSize: metrics.fontSize,
      height: metrics.heightFor(leading) / metrics.fontSize,
      fontWeight: emphasized ? metrics.emphasizedWeight : metrics.weight,
      fontStyle: useItalic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: 0,
      color: color,
      decoration: TextDecoration.none,
    );
  }

  static TextStyle largeTitle({
    bool emphasized = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.largeTitle,
      emphasized: emphasized,
      leading: leading,
      color: color,
    );
  }

  static TextStyle title1({
    bool emphasized = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.title1,
      emphasized: emphasized,
      leading: leading,
      color: color,
    );
  }

  static TextStyle title2({
    bool emphasized = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.title2,
      emphasized: emphasized,
      leading: leading,
      color: color,
    );
  }

  static TextStyle title3({
    bool emphasized = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.title3,
      emphasized: emphasized,
      leading: leading,
      color: color,
    );
  }

  static TextStyle headline({
    bool emphasized = false,
    bool italic = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.headline,
      emphasized: emphasized,
      italic: italic,
      leading: leading,
      color: color,
    );
  }

  static TextStyle body({
    bool emphasized = false,
    bool italic = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.body,
      emphasized: emphasized,
      italic: italic,
      leading: leading,
      color: color,
    );
  }

  static TextStyle callout({
    bool emphasized = false,
    bool italic = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.callout,
      emphasized: emphasized,
      italic: italic,
      leading: leading,
      color: color,
    );
  }

  static TextStyle subheadline({
    bool emphasized = false,
    bool italic = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.subheadline,
      emphasized: emphasized,
      italic: italic,
      leading: leading,
      color: color,
    );
  }

  static TextStyle footnote({
    bool emphasized = false,
    bool italic = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.footnote,
      emphasized: emphasized,
      italic: italic,
      leading: leading,
      color: color,
    );
  }

  static TextStyle caption1({
    bool emphasized = false,
    bool italic = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.caption1,
      emphasized: emphasized,
      italic: italic,
      leading: leading,
      color: color,
    );
  }

  static TextStyle caption2({
    bool emphasized = false,
    bool italic = false,
    LingyunLeading leading = LingyunLeading.standard,
    Color? color,
  }) {
    return style(
      LingyunTextRole.caption2,
      emphasized: emphasized,
      italic: italic,
      leading: leading,
      color: color,
    );
  }

  /// Cupertino slots that have a measured Sketch style.
  ///
  /// Tab label, picker, and date-time picker are left at the Cupertino
  /// default. The Sketch text styles have no 10pt tab caption, and this
  /// batch does not invent one. `GlassTabBar` caption stays on its own spec.
  static CupertinoTextThemeData cupertinoTextTheme(LingyunColors colors) {
    final label = colors.labels.primary;
    final blue = colors.system.blue;
    return CupertinoTextThemeData(
      primaryColor: blue,
      textStyle: body(color: label),
      actionTextStyle: body(color: blue),
      actionSmallTextStyle: subheadline(color: blue),
      navTitleTextStyle: headline(color: label),
      navLargeTitleTextStyle: largeTitle(emphasized: true, color: label),
      navActionTextStyle: body(color: blue),
    );
  }
}
