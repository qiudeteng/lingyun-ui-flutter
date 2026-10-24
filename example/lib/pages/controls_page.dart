import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Knob and track gallery.
///
/// Plates are [ControlLayerStyle] fills, borders, and shadows. The gray
/// band is a specimen field so white knobs and faint tracks stay visible.
/// It is not a token. Sizes on this page are specimen sizes, not kit radii.
class ControlsPage extends StatelessWidget {
  const ControlsPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = LingyunColors.forBrightness(brightness);
    final label = colors.labels.primary;
    final secondary = colors.labels.secondary;
    final catalog = ControlLayerCatalog.forBrightness(brightness);
    final tone = brightness == Brightness.dark ? '深色' : '浅色';

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      children: [
        Text(
          '旋钮与轨道',
          key: const Key('controls-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: label),
        ),
        const SizedBox(height: 8),
        Text(
          '开关、滑杆、步进器以后共用这里的轨道和旋钮。'
          '数值来自设计稿的 Controls 层样式。'
          '不是材质四档，也不是液态玻璃的常规、清透或程序坞。'
          '层样式里没有背景模糊，也没有圆角。下面的高度和宽度只是示意。',
          style: LingyunTextStyles.body(color: label),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          key: const Key('controls-brightness'),
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
            ButtonSegment(value: ThemeMode.system, label: Text('系统')),
            ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
          ],
          selected: {themeMode},
          onSelectionChanged: (set) => onThemeModeChanged(set.first),
        ),
        const SizedBox(height: 24),
        Text('轨道 · $tone', style: LingyunTextStyles.headline(color: label)),
        const SizedBox(height: 8),
        _TrackRow(
          plateKey: const Key('track-filled-idle'),
          title: '着色 · 静止',
          style: catalog.trackFilledIdle,
          label: label,
          secondary: secondary,
        ),
        _TrackRow(
          plateKey: const Key('track-filled-clicked'),
          title: '着色 · 按下',
          style: catalog.trackFilledClicked,
          label: label,
          secondary: secondary,
        ),
        _MissingRow(
          key: const Key('track-filled-disabled-missing'),
          title: '着色 · 禁用',
          note: '设计稿没有这一层。',
          label: secondary,
        ),
        _TrackRow(
          plateKey: const Key('track-unfilled-idle'),
          title: '未着色 · 静止',
          style: catalog.trackUnfilledIdle,
          label: label,
          secondary: secondary,
        ),
        _TrackRow(
          plateKey: const Key('track-unfilled-clicked'),
          title: '未着色 · 按下',
          style: catalog.trackUnfilledClicked,
          label: label,
          secondary: secondary,
        ),
        _TrackRow(
          plateKey: const Key('track-unfilled-disabled'),
          title: '未着色 · 禁用',
          style: catalog.trackUnfilledDisabled,
          label: label,
          secondary: secondary,
        ),
        const SizedBox(height: 16),
        Text('旋钮 · $tone', style: LingyunTextStyles.headline(color: label)),
        const SizedBox(height: 8),
        if (catalog.knobIdle != null)
          _KnobRow(
            plateKey: const Key('knob-idle'),
            title: '静止',
            brightness: brightness,
            clicked: false,
            label: label,
            secondary: secondary,
            detail: _styleDetail(catalog.knobIdle!),
          )
        else
          _MissingRow(
            key: const Key('knob-idle-missing'),
            title: '静止',
            note: '深色没有静止旋钮层样式。开关画板上的旋钮看起来是白的，这里不把它写成令牌。',
            label: secondary,
          ),
        _KnobRow(
          plateKey: const Key('knob-clicked'),
          title: '按下',
          brightness: brightness,
          clicked: true,
          label: label,
          secondary: secondary,
          detail: '阴影在下，发光在上。稿没有写叠加顺序，待核验。',
        ),
        const SizedBox(height: 16),
        Text(
          '按下阴影的高斯半径是 3，饱和度字段是 0。'
          '图上的模糊用了界面库阴影的半径换算，不是稿里的 σ，待核验。'
          '0 不按去色处理。'
          '发光描边的 Plus Darker 先按颜色本身画，公式待核验。'
          '描边检查器里还有一条未启用的渐变，没有画。'
          '步进器没有单独的旋钮或轨道层样式。'
          '设计文件里的控件层样式这次没有重新打开。',
          key: const Key('controls-notes'),
          style: LingyunTextStyles.footnote(color: secondary),
        ),
      ],
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.plateKey,
    required this.title,
    required this.style,
    required this.label,
    required this.secondary,
  });

  final Key plateKey;
  final String title;
  final ControlLayerStyle style;
  final Color label;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              title,
              style: LingyunTextStyles.subheadline(
                emphasized: true,
                color: label,
              ),
            ),
          ),
          Expanded(
            child: _Band(
              child: ControlLayerView(
                key: plateKey,
                style: style,
                height: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 280,
            child: Text(
              _styleDetail(style),
              style: LingyunTextStyles.caption1(color: secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _KnobRow extends StatelessWidget {
  const _KnobRow({
    required this.plateKey,
    required this.title,
    required this.brightness,
    required this.clicked,
    required this.label,
    required this.secondary,
    required this.detail,
  });

  final Key plateKey;
  final String title;
  final Brightness brightness;
  final bool clicked;
  final Color label;
  final Color secondary;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              title,
              style: LingyunTextStyles.subheadline(
                emphasized: true,
                color: label,
              ),
            ),
          ),
          _Band(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: ControlKnobStack(
                key: plateKey,
                brightness: brightness,
                width: 64,
                height: 36,
                clicked: clicked,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              detail,
              style: LingyunTextStyles.caption1(color: secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingRow extends StatelessWidget {
  const _MissingRow({
    super.key,
    required this.title,
    required this.note,
    required this.label,
  });

  final String title;
  final String note;
  final Color label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            child: Text(
              title,
              style: LingyunTextStyles.subheadline(color: label),
            ),
          ),
          Expanded(
            child: Text(note, style: LingyunTextStyles.caption1(color: label)),
          ),
        ],
      ),
    );
  }
}

/// Specimen field. Not a Controls color.
class _Band extends StatelessWidget {
  const _Band({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF8E8E93)),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

String _styleDetail(ControlLayerStyle style) {
  final fills = style.fills.map(_hex).join(' + ');
  final parts = <String>[
    if (fills.isNotEmpty) fills,
    for (final border in style.borders)
      '描边 ${_hex(border.color)} × ${border.thickness}',
    for (final shadow in style.shadows)
      '阴影 ${_hex(shadow.color)} 模糊 ${shadow.blurRadius} 偏移 ${shadow.offset.dy}',
    if (style.gaussianRadius != null) '高斯半径 ${style.gaussianRadius}',
  ];
  return parts.join(' · ');
}

String _hex(Color color) {
  final a = (color.a * 255).round();
  final r = (color.r * 255).round();
  final g = (color.g * 255).round();
  final b = (color.b * 255).round();
  String channel(int value) {
    return value.toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  final rgb = '${channel(r)}${channel(g)}${channel(b)}';
  if (a == 255) return '#$rgb';
  return '#$rgb${channel(a)}';
}
