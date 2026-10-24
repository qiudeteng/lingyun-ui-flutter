import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// iOS `LYPage` 宿主。当前进程没有 UIKit 时，只展示紧凑 / 常规说明。
class NativePage extends StatefulWidget {
  const NativePage({super.key});

  @override
  State<NativePage> createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  LingyunPageChrome _chrome = LingyunPageChrome.tab;
  LingyunPageNavigation _navigation = LingyunPageNavigation.stack;
  LingyunPageSnapshot? _snapshot;

  LingyunPageSpec get _spec => LingyunPageSpec(
    chrome: _chrome,
    navigation: _navigation,
    primaryLabel: '主栏',
    secondaryLabel: '次栏',
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final spec = _spec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '原生页',
                  key: const Key('native-page-title'),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'iOS 宿主只看水平尺寸类别和这块视图的可用范围。'
                  '外屏折叠是紧凑，半开和全开都是常规。铰链是系统预留区域。',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _ChoiceRow<LingyunPageChrome>(
                  label: '饰条',
                  keyPrefix: 'chrome',
                  values: LingyunPageChrome.values,
                  selected: _chrome,
                  display: _chromeLabel,
                  onChanged: (value) => setState(() => _chrome = value),
                ),
                const SizedBox(height: 8),
                _ChoiceRow<LingyunPageNavigation>(
                  label: '导航',
                  keyPrefix: 'navigation',
                  values: LingyunPageNavigation.values,
                  selected: _navigation,
                  display: _navigationLabel,
                  onChanged: (value) => setState(() => _navigation = value),
                ),
                const SizedBox(height: 12),
                _BucketNote(
                  noteKey: const Key('native-page-compact-note'),
                  title: '紧凑',
                  body:
                      '水平尺寸类别为紧凑，包括折叠后的外屏。'
                      '${_line(spec, LingyunPageWidthBucket.compact)} '
                      '系统标签栏可能贴在侧面。内容按每一边的安全区留白。',
                ),
                _BucketNote(
                  noteKey: const Key('native-page-regular-note'),
                  title: '常规',
                  body:
                      '水平尺寸类别为常规。半开和全开相同。'
                      '${_line(spec, LingyunPageWidthBucket.regular)} '
                      '处于激活状态的分割区域就是铰链。控件不要压在那块区域上。',
                ),
                _BucketNote(
                  noteKey: const Key('native-page-wide-note'),
                  title: '宽屏',
                  body:
                      '已经是常规，并且可用宽度至少 '
                      '${LingyunBreakpoints.large.toStringAsFixed(0)} pt'
                      '（LingyunBreakpoints.large，不是套件色值）。'
                      '${_line(spec, LingyunPageWidthBucket.wide)}',
                ),
                if (_snapshot != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '实时 ${_bucketWire(_snapshot!.widthBucket)}，'
                    '水平 ${_sizeClass(_snapshot!.horizontalSizeClass)}，'
                    '已挂载 ${_snapshot!.mountedRoot}，'
                    '${_snapshot!.columns} 列',
                    key: const Key('native-page-live'),
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white54),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LingyunNativePage(
                  key: const Key('native-page-host'),
                  spec: spec,
                  onSnapshot: (snapshot) {
                    if (!mounted) return;
                    setState(() => _snapshot = snapshot);
                  },
                  placeholder: const _HostPlaceholder(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _line(LingyunPageSpec spec, LingyunPageWidthBucket bucket) {
    final container = resolveLingyunPageContainer(spec, bucket: bucket);
    final columns = container.columns == 0 ? '系统排列' : '${container.columns} 列';
    return '${container.root}，$columns。';
  }
}

class _HostPlaceholder extends StatelessWidget {
  const _HostPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x22000000),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            'LYPage 是 iOS 平台视图。当前进程没有 UIKit 宿主，'
            '所以不用固定分辨率去模拟骨架。请在 iOS 27.1 SDK 上运行示例，'
            '才能看到 TabView、NavigationSplitView，以及设置 '
            'LY_IOS_27_1_SDK 之后的 ArrangementView。',
            key: Key('native-page-placeholder'),
          ),
        ),
      ),
    );
  }
}

class _BucketNote extends StatelessWidget {
  const _BucketNote({
    required this.noteKey,
    required this.title,
    required this.body,
  });

  final Key noteKey;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$title。',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: body),
          ],
        ),
        key: noteKey,
      ),
    );
  }
}

class _ChoiceRow<T extends Enum> extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.keyPrefix,
    required this.values,
    required this.selected,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final String keyPrefix;
  final List<T> values;
  final T selected;
  final String Function(T value) display;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label),
        for (final value in values)
          ChoiceChip(
            key: Key('native-$keyPrefix-${value.name}'),
            label: Text(display(value)),
            selected: value == selected,
            onSelected: (_) => onChanged(value),
          ),
      ],
    );
  }
}

String _chromeLabel(LingyunPageChrome value) {
  return switch (value) {
    LingyunPageChrome.tab => '标签',
    LingyunPageChrome.sidebar => '侧栏',
    LingyunPageChrome.none => '无',
  };
}

String _navigationLabel(LingyunPageNavigation value) {
  return switch (value) {
    LingyunPageNavigation.stack => '栈',
    LingyunPageNavigation.split => '分栏',
    LingyunPageNavigation.arrangementSplit => '排列分栏',
    LingyunPageNavigation.arrangementOverlay => '排列叠加',
  };
}

String _bucketWire(String raw) {
  return switch (raw) {
    'compact' => '紧凑',
    'regular' => '常规',
    'wide' => '宽屏',
    _ => raw,
  };
}

String _sizeClass(String raw) {
  return switch (raw) {
    'compact' => '紧凑',
    'regular' => '常规',
    'unspecified' => '未指定',
    _ => raw,
  };
}
