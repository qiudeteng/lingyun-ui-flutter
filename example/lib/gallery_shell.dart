import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'gallery_catalog.dart';
import 'gallery_preview.dart';
import 'wallpaper.dart';

/// Root gallery chrome.
///
/// Three levels, on every width:
/// 1. [LingyunPage] Dock tabs for the four groups. This is
///    [GlassTabBarStyle.floatingPill] with [LiquidGlassStyle.dock], drawn
///    by [LingyunPage]. It is not a sidebar rail and not Material navigation.
/// 2. The selected tab's workbench page (「基础工作台」and the same
///    pattern for the other three). Several sections. Each section is an
///    inset grouped list on Materials Regular, labeled with that workbench
///    name. Not a Liquid Glass tray. The page fill is the system grouped
///    background.
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
/// preview cluster (`chrome=0`).
///
/// The cluster (浅色 / 暗黑, 降低透明度, 画板, 画布) sits in the top-right
/// of the workbench and of a pushed demo. A fixed [frame] hoists that
/// cluster above the board. The demo, including the Dock, is clipped
/// and centered on the board. The backdrop outside the board is the
/// same wallpaper.
class GalleryShell extends StatefulWidget {
  const GalleryShell({
    super.key,
    required this.pageBuilder,
    required this.background,
    required this.onBackgroundChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.reduceTransparency,
    required this.onReduceTransparency,
    required this.frame,
    required this.onFrameChanged,
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
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final bool reduceTransparency;
  final ValueChanged<bool> onReduceTransparency;
  final GalleryPreviewFrame frame;
  final ValueChanged<GalleryPreviewFrame> onFrameChanged;
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

  Widget _cluster() {
    return GalleryPreviewCluster(
      themeMode: widget.themeMode,
      onThemeModeChanged: widget.onThemeModeChanged,
      reduceTransparency: widget.reduceTransparency,
      onReduceTransparency: widget.onReduceTransparency,
      frame: widget.frame,
      onFrameChanged: widget.onFrameChanged,
      background: widget.background,
      onBackgroundChanged: widget.onBackgroundChanged,
    );
  }

  Widget _backButton(Color label) {
    return CupertinoButton(
      key: const Key('gallery-back'),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      minimumSize: Size.zero,
      onPressed: _back,
      child: Text(
        '返回${_group.workbenchTitle}',
        style: LingyunTextStyles.body(color: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pushed = _pushedId;
    final framed = widget.frame.logicalSize != null;
    final showTools = !widget.bare && !framed;
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
                preview: showTools ? _cluster() : null,
                onOpen: _open,
              )
            : _DemoLayer(
                key: ValueKey('demo-$pushed'),
                groupLabel: _group.workbenchTitle,
                showChrome: showTools,
                preview: showTools ? _cluster() : null,
                onBack: _back,
                child: widget.pageBuilder(context, pushed),
              ),
      ),
    );

    final page = widget.bare
        ? stage
        : LingyunPage(
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
          );

    final board = framed
        ? GalleryDeviceStage(frame: widget.frame, child: page)
        : page;

    final body = framed && !widget.bare
        ? Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                  child: GalleryPreviewBar(
                    key: const Key('gallery-preview-chrome'),
                    leading: pushed == null
                        ? null
                        : _backButton(LiquidGlassLabels.primaryOf(context)),
                    cluster: _cluster(),
                  ),
                ),
              ),
              Expanded(child: board),
            ],
          )
        : board;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [const SystemWallpaper(), body],
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

/// Level 2. Each section is one inset [GlassList]: Materials Regular
/// around inset grouped rows. There is no Liquid Glass tray around the
/// group, and it is not Thick. The page fill is the system grouped
/// background. Plain lists have no platter; this page does not use them.
class GalleryWorkbench extends StatelessWidget {
  const GalleryWorkbench({
    super.key,
    required this.group,
    required this.onOpen,
    this.preview,
  });

  final GalleryGroup group;

  /// Top-right cluster. Null when the shell hoists it above a device frame,
  /// and when `chrome=0`.
  final Widget? preview;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.brightnessOf(context);
    final colors = LingyunColors.forBrightness(brightness);
    final label = colors.liquidGlassLabels.primary;
    final secondary = colors.liquidGlassLabels.secondary;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.workbenchTitle,
          key: const Key('gallery-workbench-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: label),
        ),
        const SizedBox(height: 4),
        Text(
          '点一行打开示例。',
          key: const Key('gallery-workbench-subtitle'),
          style: LingyunTextStyles.subheadline(color: secondary),
        ),
      ],
    );
    return CupertinoTheme(
      data: CupertinoThemeData(brightness: brightness),
      child: Builder(
        builder: (context) {
          return ColoredBox(
            key: const Key('gallery-workbench-background'),
            color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tools = preview;
                        if (tools == null) return title;
                        if (constraints.maxWidth < 820) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              title,
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: tools,
                              ),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: title),
                            const SizedBox(width: 12),
                            tools,
                          ],
                        );
                      },
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
            ),
          );
        },
      ),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            child: Text(
              section.title,
              key: Key('gallery-section-${section.id}'),
              style: LingyunTextStyles.footnote(
                emphasized: true,
                color: secondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              cardLabel,
              key: Key('gallery-card-label-${section.id}'),
              style: LingyunTextStyles.footnote(emphasized: true, color: label),
            ),
          ),
          GlassList(
            key: Key('gallery-card-${section.id}'),
            style: GlassListStyle.inset,
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
    );
  }
}

class _DemoLayer extends StatelessWidget {
  const _DemoLayer({
    super.key,
    required this.groupLabel,
    required this.showChrome,
    required this.preview,
    required this.onBack,
    required this.child,
  });

  final String groupLabel;
  final bool showChrome;
  final Widget? preview;
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
            child: GalleryPreviewBar(
              leading: CupertinoButton(
                key: const Key('gallery-back'),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                onPressed: onBack,
                child: Text(
                  '返回$groupLabel',
                  style: LingyunTextStyles.body(color: label),
                ),
              ),
              cluster: preview!,
            ),
          ),
        ),
        Expanded(child: page),
      ],
    );
  }
}
