import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Bounds used to simulate page buckets. Not device-model detection.
///
/// [horizontalSizeClass] is set only when the width proxy would disagree
/// with the size class being shown.
enum LayoutPreset {
  live('当前窗口', null, '用这块窗口的范围，不按机型判断。'),
  compact('紧凑', Size(390, 844), '宽度小于 600。规格是标签加栈。底栏是程序坞。'),
  compactBounds(
    '紧凑范围',
    Size(678, 466),
    '显式指定紧凑尺寸类别。若只看宽度，678 会被当成常规。',
    horizontalSizeClass: 'compact',
  ),
  regular('常规', Size(834, 1112), '规格是侧栏加分栏。玻璃侧栏，一列内容。'),
  division(
    '常规加分割',
    Size(951, 669),
    '无饰条加分栏，并带一块激活的分割区域。这不是姿态。',
    splitOnly: true,
  ),
  wide('宽屏', Size(1440, 900), '宽度至少 1200 时用侧栏加分栏。三列。相对设计稿待核验。');

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
      label: '首页',
    ),
    GlassTabBarItem(icon: Icons.grid_view_rounded, label: '浏览'),
    GlassTabBarItem(icon: Icons.person_outline, label: '我的'),
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
                '布局',
                key: const Key('layout-title'),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'LingyunPage 把 LingyunPageSpec 交给 iOS 宿主；'
                '不在 iOS 上时，按同一张容器表绘制。紧凑是标签加栈。'
                '常规和宽屏是侧栏加分栏。这条 rail 是 '
                'GlassTabBarStyle.sidebar（液态玻璃 Dock），不是 '
                'Materials Thick 正式侧栏。ArrangementView 只在原生侧'
                '（LY_IOS_27_1_SDK=1）。',
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
                data: MediaQuery.of(context)
                    .copyWith(size: simulated, padding: _paddingFor(_preset)),
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
            primaryLabel: '主栏',
            secondaryLabel: '次栏',
          )
        : lingyunPageSpecForBucket(
            bucket,
            primaryLabel: '首页',
            secondaryLabel: '浏览',
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
      secondary: const _Pane(title: '次栏', body: '容器有两列内容时显示这一列。'),
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
      title: '主栏',
      body:
          '${_bucketLabel(scope.bucket)} · ${_chromeLabel(scope.spec.chrome)} · '
          '${scope.container.root}\n'
          '${size.width.toStringAsFixed(0)}×${size.height.toStringAsFixed(0)}',
      labelKey: const Key('layout-class-label'),
    );
  }
}

String _bucketLabel(LingyunPageWidthBucket bucket) {
  return switch (bucket) {
    LingyunPageWidthBucket.compact => '紧凑',
    LingyunPageWidthBucket.regular => '常规',
    LingyunPageWidthBucket.wide => '宽屏',
  };
}

String _chromeLabel(LingyunPageChrome chrome) {
  return switch (chrome) {
    LingyunPageChrome.tab => '标签',
    LingyunPageChrome.sidebar => '侧栏',
    LingyunPageChrome.none => '无',
  };
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
