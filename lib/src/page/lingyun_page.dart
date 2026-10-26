import 'package:material_ui/material_ui.dart';

import '../layout/lingyun_layout.dart';
import '../tokens/liquid_glass_style.dart';
import '../widgets/glass_tab_bar.dart';
import '../widgets/lingyun_tab_bar.dart';
import 'lingyun_native_page.dart';
import 'lingyun_page_spec.dart';

/// Flutter width bucket for [LingyunPage].
///
/// Matches `LYPageWidthBucket.resolve` when [horizontalSizeClass] is
/// `compact`, `regular`, or `unspecified`: only a compact class is compact,
/// and wide is regular-or-unspecified with width >= [LingyunBreakpoints.large].
/// `unspecified` is not compact. Vertical size class is ignored.
///
/// When [horizontalSizeClass] is null, Flutter has no size class to read.
/// The skeleton then uses the width proxy (`<` [LingyunBreakpoints.regular]
/// is compact). iOS does not use that 600 cut; [LingyunNativePage] reports
/// the real class.
LingyunPageWidthBucket resolveFlutterPageBucket({
  required double width,
  String? horizontalSizeClass,
}) {
  switch (horizontalSizeClass) {
    case 'compact':
      return LingyunPageWidthBucket.compact;
    case 'regular':
    case 'unspecified':
      if (width >= LingyunBreakpoints.large) return LingyunPageWidthBucket.wide;
      return LingyunPageWidthBucket.regular;
    case null:
      if (width < LingyunBreakpoints.regular) {
        return LingyunPageWidthBucket.compact;
      }
      if (width >= LingyunBreakpoints.large) return LingyunPageWidthBucket.wide;
      return LingyunPageWidthBucket.regular;
    default:
      assert(
        false,
        'horizontalSizeClass must be compact, regular, unspecified, or null.',
      );
      return resolveFlutterPageBucket(width: width);
  }
}

/// Recommended [LingyunPageSpec] for a bucket.
///
/// Compact → tab + stack. Regular and wide → sidebar + split.
/// Callers can ignore this and pass any [LingyunPageSpec]; [LingyunPage]
/// does not rewrite chrome on its own. There is no Duo pose.
LingyunPageSpec lingyunPageSpecForBucket(
  LingyunPageWidthBucket bucket, {
  String primaryLabel = 'Primary',
  String secondaryLabel = 'Secondary',
}) {
  final compact = bucket == LingyunPageWidthBucket.compact;
  return LingyunPageSpec(
    chrome: compact ? LingyunPageChrome.tab : LingyunPageChrome.sidebar,
    navigation: compact
        ? LingyunPageNavigation.stack
        : LingyunPageNavigation.split,
    primaryLabel: primaryLabel,
    secondaryLabel: secondaryLabel,
  );
}

/// Center division rectangle for a Flutter simulation.
///
/// The iOS host sends real regions on [LingyunPageSnapshot]. Nothing here
/// is applied unless a caller puts it in [LingyunPage.regions].
LingyunPageRegion lingyunPageDivisionStub(Size size) {
  final band = LingyunLayout.hingeBandOf(size);
  return LingyunPageRegion(
    kind: 'division',
    isActive: true,
    x: band.left,
    y: band.top,
    width: band.width,
    height: band.height,
  );
}

/// Page shell.
///
/// When [embedNativeHost] is true (the default) and this process is iOS,
/// the shell is [LingyunNativePage]. [primary], [secondary], and
/// [destinations] are not mounted. The native view paints `LYPageScaffold`
/// from the two [LingyunPageSpec] labels. The layout demo and the native
/// page use that host.
///
/// When [embedNativeHost] is false, [primary] stays mounted. Tab chrome is
/// [LingyunTabBar]: `UITabBarController` on iOS (system Liquid Glass, and a
/// vertical bar when the system moves it), and the Flutter system dock on
/// every other platform. The same [GlassTabBarItem] list and
/// [onDestinationSelected] callback drive both. The example gallery uses
/// this so the four workbenches stay Flutter while the device tab bar is
/// the system one. A glass sidebar rail is still the Flutter skeleton.
/// Arrangement is not drawn here. iOS 27.1 `ArrangementView` and reserved
/// regions link in the native page host only when `LY_IOS_27_1_SDK=1`.
/// The system tab bar does not need that flag.
///
/// The shell needs a bounded box.
class LingyunPage extends StatelessWidget {
  const LingyunPage({
    super.key,
    required this.spec,
    required this.primary,
    this.secondary,
    this.destinations = const [],
    this.currentIndex = 0,
    this.onDestinationSelected,
    this.horizontalSizeClass,
    this.regions = const [],
    this.onSnapshot,
    this.embedNativeHost = true,
  });

  /// Same object the iOS host receives. Not a pose enum.
  final LingyunPageSpec spec;

  /// Detail / main body. Shown on the trailing side when there are two
  /// content columns.
  final Widget primary;

  /// Leading content column when the container has two content columns.
  final Widget? secondary;

  /// Tab / rail items. Empty falls back to [LingyunPageSpec] labels.
  ///
  /// Not mounted when [embedNativeHost] embeds [LingyunNativePage]. That
  /// host's tab has only the spec's two labels. With the host off, tab
  /// chrome passes this list to [LingyunTabBar].
  final List<GlassTabBarItem> destinations;

  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;

  /// `compact`, `regular`, `unspecified`, or null.
  ///
  /// Null uses the Flutter width proxy. `compact` forces the compact bucket
  /// even when the width is over 600 (outer-display simulation).
  final String? horizontalSizeClass;

  /// Simulation regions. Native regions arrive via [onSnapshot], not here.
  ///
  /// An active `division` inserts a non-interactive seam between content
  /// columns. The skeleton does not invent one.
  final List<LingyunPageRegion> regions;

  final ValueChanged<LingyunPageSnapshot>? onSnapshot;

  /// When true, an iOS process replaces this shell with [LingyunNativePage].
  ///
  /// The layout demo leaves this at the default so the metrics host still
  /// mounts. The example gallery shell sets it false: [primary] stays, and
  /// tab chrome is still the system tab bar on iOS via [LingyunTabBar].
  /// [onSnapshot] runs only when the page host is actually embedded.
  final bool embedNativeHost;

  /// Flutter glass-rail width, excluding the leading safe area.
  ///
  /// Not the system sidebar width, and not the formal Materials Thick
  /// sidebar column. **待核验 vs design**.
  static const double flutterRailWidth = 96;

  @override
  Widget build(BuildContext context) {
    return LingyunLayoutBuilder(
      builder: (context, layout) {
        final bucket = resolveFlutterPageBucket(
          width: layout.size.width,
          horizontalSizeClass: horizontalSizeClass,
        );
        final container = resolveLingyunPageContainer(spec, bucket: bucket);
        final skeleton = _LingyunPageSkeleton(
          spec: spec,
          container: container,
          primary: primary,
          secondary: secondary,
          destinations: destinations,
          currentIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          regions: regions,
        );
        final Widget shell = embedNativeHost
            ? LingyunNativePage(
                spec: spec,
                onSnapshot: onSnapshot,
                placeholder: skeleton,
              )
            : skeleton;
        return LingyunPageScope(
          spec: spec,
          bucket: bucket,
          container: container,
          child: shell,
        );
      },
    );
  }
}

/// Resolved spec, bucket, and container for descendants of [LingyunPage].
class LingyunPageScope extends InheritedWidget {
  const LingyunPageScope({
    super.key,
    required this.spec,
    required this.bucket,
    required this.container,
    required super.child,
  });

  final LingyunPageSpec spec;
  final LingyunPageWidthBucket bucket;
  final LingyunPageContainer container;

  static LingyunPageScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'LingyunPageScope not found in context.');
    return scope!;
  }

  static LingyunPageScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LingyunPageScope>();
  }

  @override
  bool updateShouldNotify(LingyunPageScope oldWidget) {
    return spec != oldWidget.spec ||
        bucket != oldWidget.bucket ||
        container.root != oldWidget.container.root ||
        container.columns != oldWidget.container.columns ||
        container.usesArrangement != oldWidget.container.usesArrangement;
  }
}

class _LingyunPageSkeleton extends StatelessWidget {
  const _LingyunPageSkeleton({
    required this.spec,
    required this.container,
    required this.primary,
    required this.secondary,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.regions,
  });

  final LingyunPageSpec spec;
  final LingyunPageContainer container;
  final Widget primary;
  final Widget? secondary;
  final List<GlassTabBarItem> destinations;
  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<LingyunPageRegion> regions;

  bool get _showTab => container.wrapsTabView;

  /// A permanent rail only when the split is actually showing more than one
  /// column. Compact collapses, matching `NavigationSplitView`.
  bool get _showRail =>
      spec.chrome == LingyunPageChrome.sidebar &&
      container.chromeApplied &&
      container.columns >= 2;

  List<GlassTabBarItem> get _items {
    if (destinations.isNotEmpty) return destinations;
    return [
      GlassTabBarItem(icon: Icons.crop_square, label: spec.primaryLabel),
      GlassTabBarItem(icon: Icons.crop_square, label: spec.secondaryLabel),
    ];
  }

  int get _index {
    final items = _items;
    if (currentIndex < 0) return 0;
    if (currentIndex >= items.length) return items.length - 1;
    return currentIndex;
  }

  LingyunPageRegion? get _division {
    if (container.usesArrangement || container.columns < 2) return null;
    for (final region in regions) {
      if (region.isActive && region.kind == 'division' && region.width > 0) {
        return region;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (container.usesArrangement) {
      return _ArrangementFallback(spec: spec, primary: primary);
    }

    final primaryPane = KeyedSubtree(
      key: const Key('lingyun-page-primary'),
      child: primary,
    );
    final secondaryPane = KeyedSubtree(
      key: const Key('lingyun-page-secondary'),
      child: secondary ?? Text(spec.secondaryLabel),
    );

    final Widget columns;
    if (container.columns >= 3) {
      columns = _ColumnRow(
        division: _division,
        panes: [secondaryPane, primaryPane],
      );
    } else if (container.columns == 2 &&
        spec.chrome != LingyunPageChrome.sidebar) {
      columns = _ColumnRow(
        division: _division,
        panes: [secondaryPane, primaryPane],
      );
    } else {
      columns = primaryPane;
    }

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showRail)
          _Rail(items: _items, index: _index, onChanged: onDestinationSelected),
        Expanded(child: columns),
      ],
    );

    return Column(
      key: const Key('lingyun-page-skeleton'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _showTab
              ? LingyunTabBar(
                  barKey: const Key('lingyun-page-tab-bar'),
                  items: _items,
                  currentIndex: _index,
                  onChanged: (index) => onDestinationSelected?.call(index),
                  child: body,
                )
              : body,
        ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<GlassTabBarItem> items;
  final int index;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    return SizedBox(
      width: LingyunPage.flutterRailWidth + safe.left,
      child: Padding(
        padding: EdgeInsets.only(left: safe.left, top: safe.top),
        child: Align(
          alignment: Alignment.topCenter,
          child: GlassTabBar(
            key: const Key('lingyun-page-sidebar'),
            style: GlassTabBarStyle.sidebar,
            glassStyle: LiquidGlassStyle.dock,
            items: items,
            currentIndex: index,
            onChanged: (value) => onChanged?.call(value),
          ),
        ),
      ),
    );
  }
}

class _ColumnRow extends StatelessWidget {
  const _ColumnRow({required this.panes, required this.division});

  final List<Widget> panes;
  final LingyunPageRegion? division;

  @override
  Widget build(BuildContext context) {
    final gutter = LingyunLayout.gutterFor(
      LingyunLayout.widthClassForWidth(MediaQuery.sizeOf(context).width),
    );
    return Padding(
      padding: EdgeInsets.all(gutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < panes.length; i++) ...[
            if (i > 0 && division != null)
              SizedBox(
                key: const Key('lingyun-page-division'),
                width: division!.width,
                child: const IgnorePointer(child: SizedBox.expand()),
              )
            else if (i > 0)
              const SizedBox(width: 12),
            Expanded(child: panes[i]),
          ],
        ],
      ),
    );
  }
}

class _ArrangementFallback extends StatelessWidget {
  const _ArrangementFallback({required this.spec, required this.primary});

  final LingyunPageSpec spec;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      key: const Key('lingyun-page-arrangement-fallback'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${spec.primaryLabel}。ArrangementView 属于 iOS 宿主，'
            '仅在 LY_IOS_27_1_SDK=1 时链接。此骨架不绘制铰链。',
            style: text.bodySmall,
          ),
        ),
        Expanded(
          child: KeyedSubtree(
            key: const Key('lingyun-page-primary'),
            child: primary,
          ),
        ),
      ],
    );
  }
}
