import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/lingyun_theme.dart';
import '../tokens/glass_material.dart';
import '../tokens/lingyun_text_styles.dart';
import 'glass_cupertino_host.dart';
import 'glass_surface.dart';

/// Corner of an inset grouped section.
///
/// Same 10pt as [CupertinoListSection.insetGrouped]. Not [LiquidGlassRadii],
/// and not the Materials Regular token radius (that one is the large panel).
const BorderRadius _kInsetGroupedRadius = BorderRadius.all(Radius.circular(10));

/// How a [GlassList] groups its rows.
///
/// Inset is a Settings-style grouped content list. Plain is edge-to-edge
/// rows with no platter.
enum GlassListStyle {
  /// [CupertinoListSection.insetGrouped] on Materials Regular.
  ///
  /// Chrome is [GlassSurface] with `material: MaterialTier.regular` and
  /// no Liquid Glass style. Not Thick, and not a new background API.
  inset,

  /// Edge-to-edge rows. No platter. Separators only.
  plain,
}

/// One row in a [GlassListSection].
///
/// Leading / title / subtitle / trailing match [CupertinoListTile]:
/// [trailingText] is the value before the chevron (Cupertino additionalInfo),
/// [trailing] is the far control, and [showChevron] appends
/// [CupertinoListTileChevron].
@immutable
class GlassListTile {
  const GlassListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.trailingText,
    this.showChevron = false,
    this.onTap,
    this.enabled = true,
    this.key,
  });

  final Key? key;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  /// Value drawn before [trailing], such as "On" or "5G".
  final String? trailingText;

  /// Draws [CupertinoListTileChevron] after [trailing].
  final bool showChevron;

  final VoidCallback? onTap;

  /// Disabled rows keep their layout, mute the title, and ignore taps.
  final bool enabled;
}

/// A headed group of [GlassListTile]s.
@immutable
class GlassListSection {
  const GlassListSection({required this.tiles, this.header, this.footer});

  final String? header;
  final String? footer;
  final List<GlassListTile> tiles;
}

/// Settings-style grouped list, or a plain edge-to-edge list.
///
/// Rows are [CupertinoListTile]s inside [CupertinoListSection].
///
/// Inset is the content layer: [MaterialTier.regular] painted by
/// [GlassSurface] (`material:`, no `style:`, no token override) around
/// [CupertinoListSection.insetGrouped]. That is not Liquid Glass, not
/// Materials Thick, and not a list-specific background primitive. A later
/// Materials Regular change shows up here without a recipe in this file.
/// The Cupertino grouped fill is cleared so the material is the section
/// color. Header and footer sit outside the platter so the rounded clip
/// does not crop them.
///
/// Inset dividers are [CupertinoColors.separator]. Plain lists do not
/// build a [GlassSurface]. They keep a clear fill and the tertiary label
/// color for separators, so a plain list can sit on other chrome.
///
/// Subtitle and trailing value use liquid-glass **secondary** from
/// [LingyunTheme] (light `#727272`, dark `#8A8A8A`). The section footer
/// stays liquid-glass tertiary. Leading symbols take the title color at
/// 22pt inside the tile's leading slot: no plate, stroke, or halo.
class GlassList extends StatelessWidget {
  const GlassList({
    super.key,
    required this.sections,
    this.style = GlassListStyle.inset,
    this.showSeparators = true,
  });

  final List<GlassListSection> sections;

  /// [GlassListStyle.inset] or [GlassListStyle.plain].
  final GlassListStyle style;

  /// When false, dividers are transparent. The section still lays out rows.
  final bool showSeparators;

  @override
  Widget build(BuildContext context) {
    final labels = LingyunTheme.colorsOf(context).liquidGlassLabels;
    final primary = labels.primary;
    final secondary = labels.secondary;
    final tertiary = labels.tertiary;
    final disabled = tertiary;
    // Inset uses the system separator (null). Plain keeps tertiary so a
    // plain list on glass chrome does not grow a grouped card or a new ink.
    final Color? separator = !showSeparators
        ? const Color(0x00000000)
        : style == GlassListStyle.inset
        ? null
        : tertiary;

    return GlassCupertinoHost(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 22),
            _GlassListSectionView(
              section: sections[i],
              style: style,
              primary: primary,
              secondary: secondary,
              tertiary: tertiary,
              disabled: disabled,
              separator: separator,
            ),
          ],
        ],
      ),
    );
  }
}

class _GlassListSectionView extends StatelessWidget {
  const _GlassListSectionView({
    required this.section,
    required this.style,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.disabled,
    required this.separator,
  });

  final GlassListSection section;
  final GlassListStyle style;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color disabled;
  final Color? separator;

  bool get _inset => style == GlassListStyle.inset;

  @override
  Widget build(BuildContext context) {
    assert(
      section.tiles.isNotEmpty,
      'GlassListSection.tiles must not be empty.',
    );
    final hasLeading = section.tiles.any((tile) => tile.leading != null);
    final rows = [
      for (final tile in section.tiles)
        _row(
          tile,
          notched: _inset,
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          disabled: disabled,
        ),
    ];

    // inherit: false so the section's DefaultTextStyle (inset headers are
    // 20pt bold) cannot restyle the title-style header or the footnote.
    final header = section.header == null
        ? null
        : Text(
            section.header!,
            style: _opaque(
              LingyunTextStyles.footnote(emphasized: true, color: primary),
            ),
          );
    final footer = section.footer == null
        ? null
        : Text(
            section.footer!,
            softWrap: true,
            style: _opaque(LingyunTextStyles.footnote(color: tertiary)),
          );

    if (!_inset) {
      return CupertinoListSection(
        margin: EdgeInsets.zero,
        topMargin: 0,
        backgroundColor: CupertinoColors.transparent,
        decoration: const BoxDecoration(color: Color(0x00000000)),
        separatorColor: separator,
        hasLeading: hasLeading,
        header: header,
        footer: footer,
        children: rows,
      );
    }

    final transparent = CupertinoColors.transparent;
    final rowsOnly = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.zero,
      backgroundColor: transparent,
      decoration: const BoxDecoration(color: Color(0x00000000)),
      clipBehavior: Clip.none,
      separatorColor: separator,
      hasLeading: hasLeading,
      children: rows,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 6),
            child: header,
          ),
        GlassSurface(
          material: MaterialTier.regular,
          padding: EdgeInsets.zero,
          borderRadius: _kInsetGroupedRadius,
          enableHoverHighlight: false,
          child: rowsOnly,
        ),
        if (footer != null)
          // Outside the platter. GlassSurface clips its child to the
          // rounded rect; the footnote is a sibling so that clip cannot
          // crop it. The top gap clears the material shadow.
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 10),
            child: footer,
          ),
      ],
    );
  }

  static Widget _row(
    GlassListTile tile, {
    required bool notched,
    required Color primary,
    required Color secondary,
    required Color tertiary,
    required Color disabled,
  }) {
    final titleColor = tile.enabled ? primary : disabled;
    final trailing = _trailing(tile);
    final title = Text(
      tile.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: LingyunTextStyles.body(color: titleColor),
    );
    final subtitle = tile.subtitle == null
        ? null
        : Text(
            tile.subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _opaque(LingyunTextStyles.subheadline(color: secondary)),
          );
    final info = tile.trailingText == null
        ? null
        : Text(
            tile.trailingText!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _opaque(LingyunTextStyles.body(color: secondary)),
          );
    // Plain symbol in the tile's leading slot (30pt notched / 28pt plain).
    // No plate, stroke, or halo — that chrome belongs to controls, not rows.
    final leading = tile.leading == null
        ? null
        : IconTheme.merge(
            data: IconThemeData(color: titleColor, size: 22),
            child: tile.leading!,
          );
    final onTap = tile.enabled ? tile.onTap : null;
    if (notched) {
      return CupertinoListTile.notched(
        key: tile.key,
        leading: leading,
        title: title,
        subtitle: subtitle,
        additionalInfo: info,
        trailing: trailing,
        onTap: onTap,
        backgroundColor: CupertinoColors.transparent,
        backgroundColorActivated: primary.withValues(alpha: 0.10),
      );
    }
    return CupertinoListTile(
      key: tile.key,
      leading: leading,
      title: title,
      subtitle: subtitle,
      additionalInfo: info,
      trailing: trailing,
      onTap: onTap,
      backgroundColor: CupertinoColors.transparent,
      backgroundColorActivated: primary.withValues(alpha: 0.10),
    );
  }

  /// Opaque Large-role style.
  ///
  /// [CupertinoListTile] wraps subtitle / additional info in a
  /// [DefaultTextStyle] of [CupertinoColors.secondaryLabel] (60% label)
  /// at 12–14px. `inherit: false` keeps Subheadline 15 / Body 17 and the
  /// theme color — secondary for subtitle and trailing value, tertiary
  /// for the section footer — from being faded again. The same lock keeps
  /// an inset header from picking up the section's 20pt bold default.
  static TextStyle _opaque(TextStyle style) {
    return TextStyle(
      inherit: false,
      color: style.color,
      fontSize: style.fontSize,
      height: style.height,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      letterSpacing: style.letterSpacing,
      decoration: TextDecoration.none,
    );
  }

  static Widget? _trailing(GlassListTile tile) {
    final chevron = tile.showChevron ? const CupertinoListTileChevron() : null;
    if (tile.trailing == null) return chevron;
    if (chevron == null) return tile.trailing;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [tile.trailing!, const SizedBox(width: 4), chevron],
    );
  }
}
