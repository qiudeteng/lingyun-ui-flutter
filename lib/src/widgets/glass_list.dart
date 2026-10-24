import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/lingyun_theme.dart';
import '../tokens/lingyun_text_styles.dart';
import '../tokens/liquid_glass_style.dart';
import 'glass_cupertino_host.dart';
import 'glass_surface.dart';

/// How a [GlassList] groups its rows.
///
/// Sketch / iOS list page: inset grouped platter, or plain edge-to-edge rows.
/// Neither style uses Materials Thick.
enum GlassListStyle {
  /// Rounded section platter. Chrome is [LiquidGlassStyle.regularMedium]
  /// via [GlassSurface] (grouped controls). Row fill stays clear so the
  /// glass shows through.
  inset,

  /// Edge-to-edge rows. No glass platter. Separators only.
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

/// iOS 27 **Liquid Glass** list.
///
/// Rows are [CupertinoListTile]s inside [CupertinoListSection] (inset
/// grouped or plain). Separators use that section's divider metrics and
/// [LingyunTheme] liquid-glass tertiary (`#BFBFBF` / `#404040`).
///
/// Inset chrome is one [GlassSurface] per section at
/// [LiquidGlassStyle.regularMedium]. The section decoration is cleared so
/// the platter is Liquid Glass, not the Cupertino grouped fill and not
/// Materials Thick. Plain lists do not build a [GlassSurface].
///
/// `blurSigma` / `saturation` stay the existing GlassSurface approximations.
/// They are not printed as kit tokens.
class GlassList extends StatelessWidget {
  const GlassList({
    super.key,
    required this.sections,
    this.style = GlassListStyle.inset,
    this.glassStyle = LiquidGlassStyle.regularMedium,
    this.showSeparators = true,
    this.forceOpaque = false,
  });

  final List<GlassListSection> sections;

  /// [GlassListStyle.inset] or [GlassListStyle.plain].
  final GlassListStyle style;

  /// Liquid Glass style for the inset platter.
  ///
  /// Ignored when [style] is [GlassListStyle.plain]. Default is Regular
  /// Medium (grouped controls). Never a Materials tier.
  final LiquidGlassStyle glassStyle;

  /// When false, dividers are transparent. The section still lays out rows.
  final bool showSeparators;

  /// Passed to the inset [GlassSurface]. Plain lists have no surface.
  final bool forceOpaque;

  @override
  Widget build(BuildContext context) {
    final labels = LingyunTheme.colorsOf(context).liquidGlassLabels;
    final primary = labels.primary;
    final tertiary = labels.tertiary;
    final disabled = tertiary;
    final separator = showSeparators ? tertiary : const Color(0x00000000);

    return GlassCupertinoHost(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 22),
            _GlassListSectionView(
              section: sections[i],
              style: style,
              glassStyle: glassStyle,
              forceOpaque: forceOpaque,
              primary: primary,
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
    required this.glassStyle,
    required this.forceOpaque,
    required this.primary,
    required this.tertiary,
    required this.disabled,
    required this.separator,
  });

  final GlassListSection section;
  final GlassListStyle style;
  final LiquidGlassStyle glassStyle;
  final bool forceOpaque;
  final Color primary;
  final Color tertiary;
  final Color disabled;
  final Color separator;

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
          tertiary: tertiary,
          disabled: disabled,
        ),
    ];

    final header = section.header == null
        ? null
        : Text(
            section.header!,
            style: LingyunTextStyles.footnote(emphasized: true, color: primary),
          );
    final footer = section.footer == null
        ? null
        : Text(
            section.footer!,
            style: LingyunTextStyles.footnote(color: tertiary),
          );

    final transparent = CupertinoColors.transparent;
    final sectionWidget = _inset
        ? CupertinoListSection.insetGrouped(
            margin: EdgeInsets.zero,
            backgroundColor: transparent,
            decoration: const BoxDecoration(color: Color(0x00000000)),
            clipBehavior: Clip.none,
            separatorColor: separator,
            hasLeading: hasLeading,
            children: rows,
          )
        : CupertinoListSection(
            margin: EdgeInsets.zero,
            topMargin: 0,
            backgroundColor: transparent,
            decoration: const BoxDecoration(color: Color(0x00000000)),
            separatorColor: separator,
            hasLeading: hasLeading,
            header: header,
            footer: footer,
            children: rows,
          );

    if (!_inset) return sectionWidget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 6),
            child: header,
          ),
        GlassSurface(
          style: glassStyle,
          padding: EdgeInsets.zero,
          forceOpaque: forceOpaque,
          child: sectionWidget,
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 6, 20, 0),
            child: footer,
          ),
      ],
    );
  }

  static Widget _row(
    GlassListTile tile, {
    required bool notched,
    required Color primary,
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
            style: LingyunTextStyles.subheadline(color: tertiary),
          );
    final info = tile.trailingText == null
        ? null
        : Text(
            tile.trailingText!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LingyunTextStyles.body(color: tertiary),
          );
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
