import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'gallery_catalog.dart';
import 'wallpaper.dart';

/// Root gallery chrome.
///
/// Three levels, on every width:
/// 1. [LingyunPage] Dock tabs for the four groups. This is
///    [GlassTabBarStyle.floatingPill] with [LiquidGlassStyle.dock], drawn
///    by [LingyunPage]. It is not a sidebar rail and not Material navigation.
/// 2. The selected tab's workbench page (「基础工作台」and the same
///    pattern for the other three). Several sections. Each section is one
///    Regular Medium card labeled with that workbench name. The card's
///    content is a plain list of demo rows.
/// 3. A row stack-pushes the demo. [返回] pops back to the workbench.
///
/// [lingyunPageSpecForBucket] would switch regular and wide to a sidebar
/// rail. This shell does not: the locked IA is tabs, then the workbench,
/// then the demo. The rail stays inside the layout demo and the 侧栏 page.
///
/// A known [initialPage] opens level 3 directly and wins over
/// [initialHome] / [initialTab]. Otherwise a known `home` or `tab`
/// (`foundation`, `controls`, `overlays`, `chrome`) opens that workbench.
/// [tab] wins when both name a workbench. Missing or unknown values open
/// the 基础 workbench. [bare] hides the tabs, the back bar, and the
/// background chip (`chrome=0`).
class GalleryShell extends StatefulWidget {
  const GalleryShell({
    super.key,
    required this.pageBuilder,
    required this.background,
    required this.onBackgroundChanged,
    this.initialPage,
    this.initialHome,
    this.initialTab,
    this.bare = false,
  });

  final String? initialPage;
  final String? initialHome;
  final String? initialTab;
  final bool bare;
  final GalleryBackground background;
  final ValueChanged<GalleryBackground> onBackgroundChanged;
  final Widget Function(BuildContext context, String entryId) pageBuilder;

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  late int _groupIndex;
  String? _pushedId;
  int _motionSign = 1;

  @override
  void initState() {
    super.initState();
    final selection = resolveGallerySelection(widget.initialPage);
    if (selection != null) {
      _groupIndex = galleryGroups.indexWhere(
        (group) => group.id == selection.group.id,
      );
      _pushedId = selection.entry.id;
      return;
    }
    final workbench =
        resolveGalleryWorkbench(widget.initialTab) ??
        resolveGalleryWorkbench(widget.initialHome);
    _groupIndex = workbench == null
        ? 0
        : galleryGroups.indexWhere((group) => group.id == workbench.id);
    _pushedId = null;
  }

  GalleryGroup get _group => galleryGroups[_groupIndex];

  void _selectGroup(int index) {
    if (index < 0 || index >= galleryGroups.length) return;
    setState(() {
      _motionSign = _pushedId == null ? 1 : -1;
      _groupIndex = index;
      _pushedId = null;
    });
  }

  void _open(String id) {
    setState(() {
      _motionSign = 1;
      _pushedId = id;
    });
  }

  void _back() {
    setState(() {
      _motionSign = -1;
      _pushedId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pushed = _pushedId;
    final stage = ClipRect(
      child: AnimatedSwitcher(
        duration: LiquidGlassMotion.durationOf(
          context,
          LiquidGlassMotion.defaults.quick,
        ),
        switchInCurve: LiquidGlassMotion.curveOf(
          context,
          LiquidGlassMotion.defaults.quickCurve,
        ),
        switchOutCurve: LiquidGlassMotion.curveOf(
          context,
          LiquidGlassMotion.defaults.quickCurve,
        ),
        layoutBuilder: _fillStage,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: Offset(0.08 * _motionSign, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: pushed == null
            ? GalleryWorkbench(
                key: ValueKey('workbench-${_group.id}'),
                group: _group,
                showBackgroundControl: !widget.bare,
                background: widget.background,
                onBackgroundChanged: widget.onBackgroundChanged,
                onOpen: _open,
              )
            : _DemoLayer(
                key: ValueKey('demo-$pushed'),
                groupLabel: _group.workbenchTitle,
                showChrome: !widget.bare,
                background: widget.background,
                onBackgroundChanged: widget.onBackgroundChanged,
                onBack: _back,
                child: widget.pageBuilder(context, pushed),
              ),
      ),
    );

    if (widget.bare) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [const SystemWallpaper(), stage],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SystemWallpaper(),
          LingyunPage(
            spec: LingyunPageSpec(
              chrome: LingyunPageChrome.tab,
              navigation: LingyunPageNavigation.stack,
              primaryLabel: _group.label,
              secondaryLabel: _group.label,
            ),
            destinations: [
              for (final group in galleryGroups)
                GlassTabBarItem(
                  icon: group.icon,
                  selectedIcon: group.selectedIcon,
                  label: group.label,
                ),
            ],
            currentIndex: _groupIndex,
            onDestinationSelected: _selectGroup,
            primary: stage,
          ),
        ],
      ),
    );
  }
}

Widget _fillStage(Widget? current, List<Widget> previous) {
  return Stack(
    fit: StackFit.expand,
    alignment: Alignment.center,
    children: [...previous, if (current != null) current],
  );
}

/// Level 2. Each section card is Liquid Glass Regular Medium. The list
/// inside is plain, so the card is the only platter. Not the Dock, and
/// not a Materials tier.
class GalleryWorkbench extends StatelessWidget {
  const GalleryWorkbench({
    super.key,
    required this.group,
    required this.showBackgroundControl,
    required this.background,
    required this.onBackgroundChanged,
    required this.onOpen,
  });

  final GalleryGroup group;
  final bool showBackgroundControl;
  final GalleryBackground background;
  final ValueChanged<GalleryBackground> onBackgroundChanged;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunColors.forBrightness(Theme.brightnessOf(context));
    final label = colors.liquidGlassLabels.primary;
    final secondary = colors.liquidGlassLabels.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.workbenchTitle,
                        key: const Key('gallery-workbench-title'),
                        style: LingyunTextStyles.largeTitle(
                          emphasized: true,
                          color: label,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '点一行打开示例。',
                        key: const Key('gallery-workbench-subtitle'),
                        style: LingyunTextStyles.subheadline(color: secondary),
                      ),
                    ],
                  ),
                ),
                if (showBackgroundControl)
                  GalleryBackgroundButton(
                    mode: background,
                    onChanged: onBackgroundChanged,
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            key: const Key('gallery-workbench'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              for (final section in group.sections)
                _WorkbenchSection(
                  section: section,
                  cardLabel: group.workbenchTitle,
                  onOpen: onOpen,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkbenchSection extends StatelessWidget {
  const _WorkbenchSection({
    required this.section,
    required this.cardLabel,
    required this.onOpen,
  });

  final GallerySection section;
  final String cardLabel;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunColors.forBrightness(Theme.brightnessOf(context));
    final label = colors.liquidGlassLabels.primary;
    final secondary = colors.liquidGlassLabels.secondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              section.title,
              key: Key('gallery-section-${section.id}'),
              style: LingyunTextStyles.footnote(
                emphasized: true,
                color: secondary,
              ),
            ),
          ),
          GlassCard(
            key: Key('gallery-card-${section.id}'),
            style: LiquidGlassStyle.regularMedium,
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Text(
                    cardLabel,
                    key: Key('gallery-card-label-${section.id}'),
                    style: LingyunTextStyles.footnote(
                      emphasized: true,
                      color: label,
                    ),
                  ),
                ),
                GlassList(
                  style: GlassListStyle.plain,
                  sections: [
                    GlassListSection(
                      tiles: [
                        for (final entry in section.entries)
                          GlassListTile(
                            key: Key('gallery-entry-${entry.id}'),
                            title: entry.label,
                            subtitle: entry.detail,
                            leading: Icon(entry.icon),
                            showChevron: true,
                            onTap: () => onOpen(entry.id),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoLayer extends StatelessWidget {
  const _DemoLayer({
    super.key,
    required this.groupLabel,
    required this.showChrome,
    required this.background,
    required this.onBackgroundChanged,
    required this.onBack,
    required this.child,
  });

  final String groupLabel;
  final bool showChrome;
  final GalleryBackground background;
  final ValueChanged<GalleryBackground> onBackgroundChanged;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final page = KeyedSubtree(
      key: const Key('gallery-body'),
      child: showChrome
          ? MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: child,
            )
          : child,
    );
    if (!showChrome) return page;
    final label = LiquidGlassLabels.primaryOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                CupertinoButton(
                  key: const Key('gallery-back'),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  onPressed: onBack,
                  child: Text(
                    '返回$groupLabel',
                    style: LingyunTextStyles.body(color: label),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GalleryBackgroundButton(
                    mode: background,
                    onChanged: onBackgroundChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: page),
      ],
    );
  }
}
