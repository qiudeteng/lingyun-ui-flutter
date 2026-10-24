import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Bounds used to simulate page buckets. Not device-model detection.
///
/// [horizontalSizeClass] is set only when the width proxy would disagree
/// with the size class being shown.
enum LayoutPreset {
  live('Live window', null, 'This window’s bounds. No device check.'),
  compact(
    'Compact',
    Size(390, 844),
    'Width under 600. Spec is tab + stack. Bottom Dock.',
  ),
  compactBounds(
    'Compact bounds',
    Size(678, 466),
    'Explicit compact size class. The width proxy would call 678 regular.',
    horizontalSizeClass: 'compact',
  ),
  regular(
    'Regular',
    Size(834, 1112),
    'Spec is sidebar + split. Glass rail, one content column.',
  ),
  division(
    'Regular + division',
    Size(951, 669),
    'none + split, plus an active division region. Not a pose.',
    splitOnly: true,
  ),
  wide(
    'Wide',
    Size(1440, 900),
    'Sidebar + split at ≥ 1200. Three columns. 待核验 vs design.',
  );

  const LayoutPreset(
    this.label,
    this.size,
    this.caption, {
    this.horizontalSizeClass,
    this.splitOnly = false,
  });

  final String label;
  final Size? size;
  final String caption;

  /// `compact`, `regular`, `unspecified`, or null (width proxy).
  final String? horizontalSizeClass;

  /// Use `none` + `split` so the seam sits between two content columns.
  final bool splitOnly;
}

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key, this.initialPreset, this.stageOnly = false});

  /// Used by tests and screenshot captures. A `?preset=` query wins.
  final LayoutPreset? initialPreset;

  /// Paint only the page stage, filling the parent.
  ///
  /// Screenshot captures set the view to the bucket size and turn this on.
  /// The gallery header plus [FittedBox] would otherwise scale every preset
  /// into the leftover window, so a wide stage no longer reads as wide.
  final bool stageOnly;

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  late LayoutPreset _preset;
  int _index = 0;

  static const _destinations = [
    GlassTabBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    GlassTabBarItem(icon: Icons.grid_view_rounded, label: 'Browse'),
    GlassTabBarItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _preset = widget.initialPreset ?? LayoutPreset.regular;
    final name = Uri.base.queryParameters['preset'];
    if (name != null) {
      for (final preset in LayoutPreset.values) {
        if (preset.name == name) {
          _preset = preset;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stageOnly) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final simulated =
              constraints.hasBoundedWidth && constraints.hasBoundedHeight
              ? Size(constraints.maxWidth, constraints.maxHeight)
              : _preset.size;
          return _frame(context, simulated);
        },
      );
    }
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: LingyunLayout.layoutMarginOf(context).copyWith(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Layout',
                key: const Key('layout-title'),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'LingyunPage sends LingyunPageSpec to the iOS host and, off '
                'iOS, paints the same container map. Compact is tab + stack. '
                'Regular and wide are sidebar + split. ArrangementView stays '
                'on the native track (LY_IOS_27_1_SDK=1).',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _preset.caption,
                key: const Key('layout-preset-caption'),
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in LayoutPreset.values)
                    ChoiceChip(
                      key: Key('preset-${preset.name}'),
                      label: Text(preset.label),
                      selected: _preset == preset,
                      onSelected: (_) => setState(() => _preset = preset),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _preset.size == null
                ? _frame(context, null)
                : Center(
                    child: FittedBox(
                      child: SizedBox(
                        width: _preset.size!.width,
                        height: _preset.size!.height,
                        child: _frame(context, _preset.size),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _frame(BuildContext context, Size? simulated) {
    final page = _DemoPage(
      preset: _preset,
      simulated: simulated,
      index: _index,
      destinations: _destinations,
      onIndex: (index) => setState(() => _index = index),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white54),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: simulated == null
            ? page
            : MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(size: simulated, padding: _paddingFor(_preset)),
                child: page,
              ),
      ),
    );
  }

  static EdgeInsets _paddingFor(LayoutPreset preset) {
    return switch (preset) {
      LayoutPreset.compact => const EdgeInsets.fromLTRB(0, 47, 0, 34),
      LayoutPreset.compactBounds => const EdgeInsets.fromLTRB(20, 12, 20, 12),
      LayoutPreset.regular => const EdgeInsets.fromLTRB(0, 24, 0, 20),
      LayoutPreset.division => const EdgeInsets.fromLTRB(8, 20, 8, 20),
      LayoutPreset.wide => EdgeInsets.zero,
      LayoutPreset.live => EdgeInsets.zero,
    };
  }
}

class _DemoPage extends StatelessWidget {
  const _DemoPage({
    required this.preset,
    required this.simulated,
    required this.index,
    required this.destinations,
    required this.onIndex,
  });

  final LayoutPreset preset;
  final Size? simulated;
  final int index;
  final List<GlassTabBarItem> destinations;
  final ValueChanged<int> onIndex;

  @override
  Widget build(BuildContext context) {
    final width = simulated?.width ?? MediaQuery.sizeOf(context).width;
    final bucket = resolveFlutterPageBucket(
      width: width,
      horizontalSizeClass: preset.horizontalSizeClass,
    );
    final spec = preset.splitOnly
        ? const LingyunPageSpec(
            chrome: LingyunPageChrome.none,
            navigation: LingyunPageNavigation.split,
            primaryLabel: 'Primary',
            secondaryLabel: 'Secondary',
          )
        : lingyunPageSpecForBucket(
            bucket,
            primaryLabel: 'Home',
            secondaryLabel: 'Browse',
          );
    final regions = preset.splitOnly && simulated != null
        ? [lingyunPageDivisionStub(simulated!)]
        : const <LingyunPageRegion>[];
    return LingyunPage(
      spec: spec,
      horizontalSizeClass: preset.horizontalSizeClass,
      regions: regions,
      destinations: destinations,
      currentIndex: index,
      onDestinationSelected: onIndex,
      secondary: const _Pane(
        title: 'Secondary',
        body: 'Content column when the container has two content panes.',
      ),
      primary: const _PrimaryPane(),
    );
  }
}

class _PrimaryPane extends StatelessWidget {
  const _PrimaryPane();

  @override
  Widget build(BuildContext context) {
    final scope = LingyunPageScope.of(context);
    final size = MediaQuery.sizeOf(context);
    return _Pane(
      title: 'Primary',
      body:
          '${scope.bucket.name} · ${scope.spec.chrome.name} · '
          '${scope.container.root}\n'
          '${size.width.toStringAsFixed(0)}×${size.height.toStringAsFixed(0)}',
      labelKey: const Key('layout-class-label'),
    );
  }
}

class _Pane extends StatelessWidget {
  const _Pane({required this.title, required this.body, this.labelKey});

  final String title;
  final String body;
  final Key? labelKey;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox.expand(
      child: GlassCard(
        material: MaterialTier.regular,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(body, key: labelKey, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
