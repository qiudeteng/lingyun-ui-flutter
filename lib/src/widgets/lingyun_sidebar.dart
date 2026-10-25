import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/lingyun_theme.dart';
import '../tokens/glass_material.dart';
import '../tokens/lingyun_colors.dart';
import '../tokens/lingyun_text_styles.dart';
import '../tokens/liquid_glass_motion.dart';
import 'glass_cupertino_host.dart';
import 'glass_surface.dart';

/// One row in a [LingyunSidebar].
///
/// Flat index order is section order, then row order. Disabled rows keep
/// their index and do not call [LingyunSidebar.onSelected].
@immutable
class LingyunSidebarItem {
  const LingyunSidebarItem({
    required this.label,
    this.icon,
    this.enabled = true,
    this.key,
  });

  final Key? key;
  final String label;
  final IconData? icon;
  final bool enabled;
}

/// A headed group of [LingyunSidebarItem]s.
@immutable
class LingyunSidebarSection {
  const LingyunSidebarSection({required this.items, this.header});

  final String? header;
  final List<LingyunSidebarItem> items;
}

/// Working geometry for [LingyunSidebar]. Not a Design Token table.
///
/// Width, row metrics, and the plate corner are **待核验** against Sketch
/// Sidebars / Figma iPad sidebar parts. They are not
/// [LingyunPage.flutterRailWidth] (the Dock rail). Spring stiffness,
/// damping, and bounce are not stored here: iOS 27.1 has not published
/// them. Motion uses the system page curve and [LiquidGlassMotion].
abstract final class LingyunSidebarMetrics {
  /// Preferred column width. **待核验**. Not the 96px Dock rail.
  static const double preferredWidth = 320;

  /// [CupertinoListTile] base minimum: leading slot 28 plus 8 + 8.
  ///
  /// Cited from `cupertino_ui`, not a new token.
  static const double rowHeight = 44;

  /// Section header slot. **待核验**.
  static const double sectionHeaderHeight = 28;

  /// Gap between sections. **待核验**.
  static const double sectionGap = 12;

  /// Padding inside the platter, before the safe area. **待核验**.
  static const double contentPadding = 16;

  /// Horizontal inset of the selection capsule. **待核验**.
  static const double selectionHorizontalInset = 8;

  /// Vertical inset of the selection capsule inside the row. **待核验**.
  static const double selectionVerticalInset = 4;

  /// Trailing corners when the column is flush to the leading edge.
  ///
  /// Reuses [LiquidGlassRadii.large] (34), already **待核验**. Not measured
  /// on the Sidebars page.
  static BorderRadius borderRadius({required bool flushLeading}) {
    final radius = Radius.circular(LiquidGlassRadii.large);
    if (flushLeading) {
      return BorderRadius.only(topRight: radius, bottomRight: radius);
    }
    return BorderRadius.all(radius);
  }

  static int itemCount(List<LingyunSidebarSection> sections) {
    var count = 0;
    for (final section in sections) {
      count += section.items.length;
    }
    return count;
  }

  /// Top of [flatIndex] inside the section stack, under the title block.
  static double rowTop(List<LingyunSidebarSection> sections, int flatIndex) {
    var y = 0.0;
    var cursor = 0;
    for (var s = 0; s < sections.length; s++) {
      final section = sections[s];
      if (s > 0) y += sectionGap;
      if (section.header != null) y += sectionHeaderHeight;
      for (var i = 0; i < section.items.length; i++) {
        if (cursor == flatIndex) return y;
        y += rowHeight;
        cursor++;
      }
    }
    return y;
  }
}

/// Formal sidebar column. Chrome is **Materials Thick**.
///
/// Same assembly as [LingyunSheet]: the parent paints stripes or content,
/// then this [GlassSurface] covers them with `material: MaterialTier.thick`
/// and no `style` / `tokens`. One brightness for the whole column — the
/// ambient theme. A single surface is not split into light and dark.
///
/// This is not [GlassTabBarStyle.sidebar]. That value is the Liquid Glass
/// **Dock** rail on [LingyunPage] (width [LingyunPage.flutterRailWidth],
/// **待核验**). It is not the iOS 27.1 vertical system toolbar. UIKit's
/// Tab-to-Sidebar fluid transition stays on that Dock rail / in `ios/`.
/// This column does not morph into a tab bar and does not change tier
/// while it opens.
///
/// Expand / collapse is [LingyunSidebarLayout]. The clock is
/// [LiquidGlassMotion.emphasized]. The curve is the one
/// [CupertinoPageTransition] already uses
/// (`Curves.fastEaseInToSlowEaseOut`), referenced by name. Control points
/// are not copied into a token. Apple's sidebar spring is unpublished
/// (**对照官方观感 / 待核验**).
///
/// Rows are [CupertinoListTile] so the press flash is the system tile.
/// The selection capsule moves with [LiquidGlassMotion.quick].
/// Reduce motion and `MediaQuery.disableAnimations` collapse durations
/// to [Duration.zero].
///
/// Needs a bounded height.
class LingyunSidebar extends StatelessWidget {
  const LingyunSidebar({
    super.key,
    required this.sections,
    this.title,
    this.subtitle,
    this.selectedIndex,
    this.onSelected,
    this.footer,
    this.flushLeading = true,
    this.selectionKey,
  });

  final List<LingyunSidebarSection> sections;
  final String? title;
  final String? subtitle;

  /// Flat index across [sections]. Null clears the capsule.
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final Widget? footer;

  /// Square leading corners when the column sits on the screen edge.
  final bool flushLeading;

  /// Key for the moving selection capsule. Null in galleries that show
  /// more than one column.
  final Key? selectionKey;

  @override
  Widget build(BuildContext context) {
    final count = LingyunSidebarMetrics.itemCount(sections);
    assert(
      selectedIndex == null || (selectedIndex! >= 0 && selectedIndex! < count),
      'LingyunSidebar.selectedIndex ($selectedIndex) is outside $count rows.',
    );
    final radius = LingyunSidebarMetrics.borderRadius(
      flushLeading: flushLeading,
    );
    return GlassSurface(
      material: MaterialTier.thick,
      borderRadius: radius,
      enableHoverHighlight: false,
      padding: EdgeInsets.zero,
      child: GlassCupertinoHost(
        child: _SidebarBody(
          sections: sections,
          title: title,
          subtitle: subtitle,
          selectedIndex: selectedIndex,
          onSelected: onSelected,
          footer: footer,
          selectionKey: selectionKey,
        ),
      ),
    );
  }
}

class _SidebarBody extends StatelessWidget {
  const _SidebarBody({
    required this.sections,
    required this.title,
    required this.subtitle,
    required this.selectedIndex,
    required this.onSelected,
    required this.footer,
    required this.selectionKey,
  });

  final List<LingyunSidebarSection> sections;
  final String? title;
  final String? subtitle;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final Widget? footer;
  final Key? selectionKey;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    final safe = MediaQuery.paddingOf(context);
    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
    final curve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
    final selected = selectedIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null || subtitle != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              LingyunSidebarMetrics.contentPadding + safe.left,
              LingyunSidebarMetrics.contentPadding + safe.top,
              LingyunSidebarMetrics.contentPadding,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LingyunTextStyles.title2(
                      emphasized: true,
                      color: colors.labels.primary,
                    ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LingyunTextStyles.footnote(
                      color: colors.labels.secondary,
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          SizedBox(height: safe.top),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(safe.left, 0, 0, safe.bottom),
            children: [
              Stack(
                children: [
                  if (selected != null)
                    AnimatedPositioned(
                      key: selectionKey,
                      duration: duration,
                      curve: curve,
                      top:
                          LingyunSidebarMetrics.rowTop(sections, selected) +
                          LingyunSidebarMetrics.selectionVerticalInset,
                      left: LingyunSidebarMetrics.selectionHorizontalInset,
                      right: LingyunSidebarMetrics.selectionHorizontalInset,
                      height:
                          LingyunSidebarMetrics.rowHeight -
                          LingyunSidebarMetrics.selectionVerticalInset * 2,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.fills.secondary,
                            borderRadius: BorderRadius.circular(
                              LiquidGlassRadii.small,
                            ),
                          ),
                        ),
                      ),
                    ),
                  _rows(colors),
                ],
              ),
            ],
          ),
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              LingyunSidebarMetrics.contentPadding + safe.left,
              8,
              LingyunSidebarMetrics.contentPadding,
              LingyunSidebarMetrics.contentPadding + safe.bottom,
            ),
            child: footer,
          ),
      ],
    );
  }

  Widget _rows(LingyunColors colors) {
    final children = <Widget>[];
    var flat = 0;
    for (var s = 0; s < sections.length; s++) {
      final section = sections[s];
      if (s > 0) {
        children.add(const SizedBox(height: LingyunSidebarMetrics.sectionGap));
      }
      final header = section.header;
      if (header != null) {
        children.add(
          SizedBox(
            height: LingyunSidebarMetrics.sectionHeaderHeight,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LingyunSidebarMetrics.contentPadding,
                ),
                child: Text(
                  header,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LingyunTextStyles.footnote(
                    emphasized: true,
                    color: colors.labels.secondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      for (final item in section.items) {
        final index = flat;
        flat += 1;
        children.add(
          SizedBox(
            height: LingyunSidebarMetrics.rowHeight,
            child: _SidebarRow(
              item: item,
              selected: selectedIndex == index,
              onTap: item.enabled ? () => onSelected?.call(index) : null,
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final LingyunSidebarItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    final labelColor = !item.enabled
        ? colors.labels.tertiary
        : selected
        ? colors.system.blue
        : colors.labels.primary;
    return Semantics(
      key: item.key,
      button: true,
      selected: selected,
      enabled: item.enabled,
      label: item.label,
      child: CupertinoListTile(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: const Color(0x00000000),
        backgroundColorActivated: colors.labels.primary.withValues(alpha: 0.10),
        onTap: onTap,
        leading: item.icon == null
            ? null
            : Icon(item.icon, color: labelColor, size: 22),
        title: Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LingyunTextStyles.body(color: labelColor),
        ),
      ),
    );
  }
}

/// Thick column beside [body]. The column animates open and closed.
///
/// Stack order matches sheets: [backdrop] (stripes or content) is the
/// bottom child, [LingyunSidebar] covers it directly. No opaque plate and
/// no extra clip between them. The outer clip only hides the column as
/// its width changes.
///
/// The width follows `Curves.fastEaseInToSlowEaseOut` — the curve inside
/// [CupertinoPageTransition] — and [LiquidGlassMotion.emphasized]. The
/// page-transition widget itself is a full-route slide plus an edge
/// shadow. Putting that shadow between the stripes and the Thick platter
/// would break the sheet assembly, so the column uses the system curve
/// without that shadow. Unpublished iOS 27.1 spring numbers are not
/// written down. **对照官方观感 / 待核验**.
///
/// [body] is the detail. Put a [LingyunToolbar] there when the bar should
/// share a regular / wide split. This layout does not become a vertical
/// system toolbar.
class LingyunSidebarLayout extends StatefulWidget {
  const LingyunSidebarLayout({
    super.key,
    required this.body,
    required this.sections,
    this.title,
    this.subtitle,
    this.selectedIndex,
    this.onSelected,
    this.footer,
    this.expanded = true,
    this.backdrop,
    this.flushLeading = true,
    this.width = LingyunSidebarMetrics.preferredWidth,
    this.columnKey,
    this.selectionKey,
  });

  final Widget body;
  final List<LingyunSidebarSection> sections;
  final String? title;
  final String? subtitle;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final Widget? footer;
  final bool expanded;

  /// Painted under the Thick platter in the same [Stack].
  final Widget? backdrop;
  final bool flushLeading;

  /// Expanded width. Defaults to [LingyunSidebarMetrics.preferredWidth].
  final double width;
  final Key? columnKey;
  final Key? selectionKey;

  @override
  State<LingyunSidebarLayout> createState() => _LingyunSidebarLayoutState();
}

class _LingyunSidebarLayoutState extends State<LingyunSidebarLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LiquidGlassMotion.defaults.emphasized,
      value: widget.expanded ? 1 : 0,
    );
    // Same pair CupertinoPageTransition installs. Not a token.
    _curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastEaseInToSlowEaseOut,
      reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
    );
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sync() {
    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.emphasized,
    );
    _controller.duration = duration;
    _controller.reverseDuration = duration;
    if (duration == Duration.zero) {
      _controller.value = widget.expanded ? 1 : 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant LingyunSidebarLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
    if (oldWidget.expanded != widget.expanded &&
        _controller.duration != Duration.zero) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnKey = widget.columnKey ?? const Key('lingyun-sidebar-column');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _curved,
          builder: (context, child) {
            final revealed = widget.width * _curved.value;
            return SizedBox(
              key: columnKey,
              width: revealed,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: widget.width,
                  maxWidth: widget.width,
                  child: SizedBox(width: widget.width, child: child),
                ),
              ),
            );
          },
          child: Stack(
            key: const Key('lingyun-sidebar-stack'),
            fit: StackFit.expand,
            children: [
              widget.backdrop ?? const SizedBox.expand(),
              LingyunSidebar(
                sections: widget.sections,
                title: widget.title,
                subtitle: widget.subtitle,
                selectedIndex: widget.selectedIndex,
                onSelected: widget.onSelected,
                footer: widget.footer,
                flushLeading: widget.flushLeading,
                selectionKey: widget.selectionKey,
              ),
            ],
          ),
        ),
        Expanded(child: widget.body),
      ],
    );
  }
}
