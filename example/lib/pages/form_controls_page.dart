import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Which Wave 1b control the gallery is showing.
///
/// `?page=toggles` (also `toggle`), `?page=sliders` (`slider`), and
/// `?page=steppers` (`stepper`) all open this page on that segment.
enum FormControlPanel {
  toggles,
  sliders,
  steppers;

  /// Query value for this page, or null when [page] is some other gallery.
  static FormControlPanel? fromQuery(String? page) {
    return switch (page) {
      'toggles' || 'toggle' => FormControlPanel.toggles,
      'sliders' || 'slider' => FormControlPanel.sliders,
      'steppers' || 'stepper' => FormControlPanel.steppers,
      _ => null,
    };
  }
}

/// Toggle, slider, and stepper gallery.
///
/// Plates are [LingyunToggle], [LingyunSlider], and [LingyunStepper].
/// Fills come from [ControlLayerCatalog]. Sizes are [ControlMetrics].
/// The padding around each control is only there so the blur-36 shadow
/// is not covered by the next row. It is not a token.
class FormControlsPage extends StatefulWidget {
  const FormControlsPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.initialPanel = FormControlPanel.toggles,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final FormControlPanel initialPanel;

  @override
  State<FormControlsPage> createState() => _FormControlsPageState();
}

class _FormControlsPageState extends State<FormControlsPage> {
  late FormControlPanel _panel = widget.initialPanel;
  bool _toggle = true;
  double _slider = 0.5;
  int _step = 3;

  @override
  void didUpdateWidget(FormControlsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPanel != widget.initialPanel) {
      _panel = widget.initialPanel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = LingyunColors.forBrightness(brightness);
    final label = colors.labels.primary;
    final secondary = colors.labels.secondary;
    final catalog = ControlLayerCatalog.forBrightness(brightness);
    final tone = brightness == Brightness.dark ? '深色' : '浅色';
    final hasIdleKnob = catalog.knobIdle != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      children: [
        Text(
          '开关、滑杆与步进器',
          key: const Key('form-controls-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: label),
        ),
        const SizedBox(height: 8),
        Text(
          '开关和滑杆把直径 24 的圆旋钮叠在轨道上。'
          '颜色来自已验收的 Controls 层样式，这里不另写色值。'
          '开关轨道 64×28，滑杆轨道高 6。'
          '深色没有静止旋钮，不补白色。'
          '着色轨道没有禁用样式，禁用时整条用未着色禁用。'
          '步进器没有独立旋钮或轨道，板面复用未着色轨道。'
          '不是材质四档，也不是液态玻璃。',
          style: LingyunTextStyles.body(color: label),
        ),
        const SizedBox(height: 12),
        SegmentedButton<FormControlPanel>(
          key: const Key('form-controls-panel'),
          segments: const [
            ButtonSegment(value: FormControlPanel.toggles, label: Text('开关')),
            ButtonSegment(value: FormControlPanel.sliders, label: Text('滑杆')),
            ButtonSegment(value: FormControlPanel.steppers, label: Text('步进器')),
          ],
          selected: {_panel},
          onSelectionChanged: (set) => setState(() => _panel = set.first),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          key: const Key('form-controls-brightness'),
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
            ButtonSegment(value: ThemeMode.system, label: Text('系统')),
            ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
          ],
          selected: {widget.themeMode},
          onSelectionChanged: (set) => widget.onThemeModeChanged(set.first),
        ),
        const SizedBox(height: 24),
        if (_panel == FormControlPanel.toggles) ...[
          Text('开关 · $tone', style: LingyunTextStyles.headline(color: label)),
          const SizedBox(height: 8),
          _Row(
            title: '关 · 静止',
            label: label,
            secondary: secondary,
            detail: hasIdleKnob
                ? '未着色轨道。圆旋钮靠左。${_fills(catalog.trackUnfilledIdle)}'
                : '未着色轨道。深色不画静止旋钮。${_fills(catalog.trackUnfilledIdle)}',
            child: LingyunToggle(
              key: const Key('toggle-off-idle'),
              value: false,
              brightness: brightness,
              onChanged: _keepBool,
              semanticLabel: '关，静止',
            ),
          ),
          _Row(
            title: '开 · 静止',
            label: label,
            secondary: secondary,
            detail: hasIdleKnob
                ? '着色轨道。圆旋钮靠右。${_fills(catalog.trackFilledIdle)}'
                : '着色轨道。深色不画静止旋钮。${_fills(catalog.trackFilledIdle)}',
            child: LingyunToggle(
              key: const Key('toggle-on-idle'),
              value: true,
              brightness: brightness,
              onChanged: _keepBool,
              semanticLabel: '开，静止',
            ),
          ),
          _Row(
            title: '关 · 按下',
            label: label,
            secondary: secondary,
            detail: '未着色按下。${_fills(catalog.trackUnfilledClicked)}',
            child: LingyunToggle(
              key: const Key('toggle-off-pressed'),
              value: false,
              brightness: brightness,
              forcePressed: true,
              onChanged: _keepBool,
              semanticLabel: '关，按下',
            ),
          ),
          _Row(
            title: '开 · 按下',
            label: label,
            secondary: secondary,
            detail: '着色按下。${_fills(catalog.trackFilledClicked)}',
            child: LingyunToggle(
              key: const Key('toggle-on-pressed'),
              value: true,
              brightness: brightness,
              forcePressed: true,
              onChanged: _keepBool,
              semanticLabel: '开，按下',
            ),
          ),
          _Row(
            title: '关 · 禁用',
            label: label,
            secondary: secondary,
            detail:
                '未着色禁用。${_fills(catalog.trackUnfilledDisabled)}'
                '着色禁用稿面没有，这里不另造颜色。',
            child: LingyunToggle(
              key: const Key('toggle-off-disabled'),
              value: false,
              brightness: brightness,
              semanticLabel: '关，禁用',
            ),
          ),
          _Row(
            title: '开 · 禁用',
            label: label,
            secondary: secondary,
            detail: hasIdleKnob
                ? '轨道仍是未着色禁用。旋钮留在开的一侧，表示数值，不表示着色。'
                : '轨道仍是未着色禁用。深色不画静止旋钮，开着也不补白色。',
            child: LingyunToggle(
              key: const Key('toggle-on-disabled'),
              value: true,
              brightness: brightness,
              semanticLabel: '开，禁用',
            ),
          ),
          _Row(
            title: '可点按',
            label: label,
            secondary: secondary,
            detail: _toggle ? '实时：开' : '实时：关',
            child: LingyunToggle(
              key: const Key('toggle-live'),
              value: _toggle,
              brightness: brightness,
              onChanged: (value) => setState(() => _toggle = value),
              semanticLabel: '实时开关',
            ),
          ),
        ],
        if (_panel == FormControlPanel.sliders) ...[
          Text('滑杆 · $tone', style: LingyunTextStyles.headline(color: label)),
          const SizedBox(height: 8),
          _Row(
            title: '中部 · 静止',
            label: label,
            secondary: secondary,
            detail: hasIdleKnob
                ? '圆旋钮骑在高 6 的轨道上，着色到旋钮中心。'
                : '深色不画静止旋钮。着色到数值处，其余是未着色轨道。',
            child: LingyunSlider(
              key: const Key('slider-mid-idle'),
              value: 0.5,
              brightness: brightness,
              onChanged: _keepDouble,
              semanticLabel: '中部，静止',
            ),
          ),
          _Row(
            title: '中部 · 按下',
            label: label,
            secondary: secondary,
            detail: '按下的圆旋钮叠在同一条轨道上。',
            child: LingyunSlider(
              key: const Key('slider-mid-pressed'),
              value: 0.5,
              brightness: brightness,
              forcePressed: true,
              onChanged: _keepDouble,
              semanticLabel: '中部，按下',
            ),
          ),
          _Row(
            title: '禁用',
            label: label,
            secondary: secondary,
            detail: '着色禁用稿面没有，所以不画着色段。轨道是未着色禁用。',
            child: LingyunSlider(
              key: const Key('slider-disabled'),
              value: 0.5,
              brightness: brightness,
              semanticLabel: '滑杆，禁用',
            ),
          ),
          _Row(
            title: '可拖动',
            label: label,
            secondary: secondary,
            detail: '实时：${(_slider * 100).round()}%',
            child: LingyunSlider(
              key: const Key('slider-live'),
              value: _slider,
              brightness: brightness,
              onChanged: (value) => setState(() => _slider = value),
              semanticLabel: '实时滑杆',
            ),
          ),
        ],
        if (_panel == FormControlPanel.steppers) ...[
          Text('步进器 · $tone', style: LingyunTextStyles.headline(color: label)),
          const SizedBox(height: 8),
          _Row(
            title: '静止',
            label: label,
            secondary: secondary,
            detail: '未着色轨道。没有旋钮。分隔线是系统分隔线。',
            child: LingyunStepper(
              key: const Key('stepper-idle'),
              value: 3,
              brightness: brightness,
              onChanged: _keepInt,
              decrementLabel: '减少',
              incrementLabel: '增加',
            ),
          ),
          _Row(
            title: '减少 · 按下',
            label: label,
            secondary: secondary,
            detail: '按住的一侧是未着色按下。另一侧仍是静止。',
            child: LingyunStepper(
              key: const Key('stepper-decrement-pressed'),
              value: 3,
              brightness: brightness,
              forcePressed: LingyunStepperSide.decrement,
              onChanged: _keepInt,
              decrementLabel: '减少',
              incrementLabel: '增加',
            ),
          ),
          _Row(
            title: '增加 · 按下',
            label: label,
            secondary: secondary,
            detail: '右侧是未着色按下。',
            child: LingyunStepper(
              key: const Key('stepper-increment-pressed'),
              value: 3,
              brightness: brightness,
              forcePressed: LingyunStepperSide.increment,
              onChanged: _keepInt,
              decrementLabel: '减少',
              incrementLabel: '增加',
            ),
          ),
          _Row(
            title: '禁用',
            label: label,
            secondary: secondary,
            detail: '整板是未着色禁用。加减号用三级标签色。',
            child: LingyunStepper(
              key: const Key('stepper-disabled'),
              value: 3,
              brightness: brightness,
              decrementLabel: '减少',
              incrementLabel: '增加',
            ),
          ),
          _Row(
            title: '可点按',
            label: label,
            secondary: secondary,
            detail: '实时：$_step。到 0 或到 8 时，对应一侧停用。',
            child: LingyunStepper(
              key: const Key('stepper-live'),
              value: _step,
              min: 0,
              max: 8,
              brightness: brightness,
              onChanged: (value) => setState(() => _step = value),
              decrementLabel: '减少',
              incrementLabel: '增加',
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          '静止旋钮的阴影是模糊 36、下移 3。示意四周留出空位，避免被下一行挡住。'
          '按下阴影和发光的叠加顺序、高斯半径换算、Plus Darker 仍待核验，跟旋钮页相同。'
          '步进器外形 92×32 来自画板，胶囊是调用方的形状，不是新的圆角令牌。',
          key: const Key('form-controls-notes'),
          style: LingyunTextStyles.footnote(color: secondary),
        ),
      ],
    );
  }
}

void _keepBool(bool _) {}

void _keepDouble(double _) {}

void _keepInt(int _) {}

/// Room for blur 36 and the 3pt offset. Not a token.
const EdgeInsets _shadowRoom = EdgeInsets.fromLTRB(36, 28, 36, 44);

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.detail,
    required this.label,
    required this.secondary,
    required this.child,
  });

  final String title;
  final String detail;
  final Color label;
  final Color secondary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
            flex: 3,
            child: Padding(
              padding: _shadowRoom,
              child: Align(
                alignment: Alignment.centerLeft,
                heightFactor: 1,
                child: child,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
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

String _fills(ControlLayerStyle style) {
  return style.fills.map(_hex).join(' + ');
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
