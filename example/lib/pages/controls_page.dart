import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Knob and track gallery.
///
/// Specimens compose a round knob on a track. Sizes are the symbol bodies
/// measured from Sketch share `04c24d8b-38fb-4afb-8836-36617e022f02`, not
/// layer-style tokens (those have no corner radius):
///
/// * Toggle artboard `Toggles/*/1 - Idle` is 64×28. The idle thumb fill on
///   that render is 24pt tall and inset 2; this page draws it as a circle
///   of that height so it is not the old 64×36 slab.
/// * Slider bar inside `Sliders/*/Mid` is 6pt tall. The knob symbol is 24pt
///   tall and rides that bar, centered.
///
/// The gray specimen field is gone: it hid the 5% black / blur-36 shadow.
/// Leave clear room around each control; [ControlKnobStack] does not clip.
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
    final hasIdleKnob = catalog.knobIdle != null;

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
          '开关和滑杆把圆旋钮叠在轨道上。'
          '填充、描边、阴影来自设计稿的 Controls 层样式。'
          '不是材质四档，也不是液态玻璃的常规、清透或程序坞。'
          '层样式里没有背景模糊，也没有圆角。'
          '旋钮画成直径 24 的圆，高度对齐符号里的旋钮。'
          '开关轨道 64×28，滑杆轨道高 6。这些是示意外形，不是新的令牌。',
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
        Text('开关 · $tone', style: LingyunTextStyles.headline(color: label)),
        const SizedBox(height: 8),
        _SampleRow(
          title: '关 · 静止',
          label: label,
          secondary: secondary,
          detail: hasIdleKnob
              ? '未着色轨道。圆旋钮靠左。${_styleDetail(catalog.trackUnfilledIdle)}'
              : '未着色轨道。深色没有静止旋钮层样式，这里不补白色。',
          child: _ToggleSpecimen(
            catalog: catalog,
            on: false,
            clicked: false,
            trackKey: const Key('track-unfilled-idle'),
            knobKey: hasIdleKnob ? const Key('knob-idle') : null,
          ),
        ),
        _SampleRow(
          title: '开 · 静止',
          label: label,
          secondary: secondary,
          detail: hasIdleKnob
              ? '着色轨道。圆旋钮靠右。${_styleDetail(catalog.trackFilledIdle)}'
              : '着色轨道。${_styleDetail(catalog.trackFilledIdle)}',
          child: _ToggleSpecimen(
            catalog: catalog,
            on: true,
            clicked: false,
            trackKey: const Key('track-filled-idle'),
          ),
        ),
        if (!hasIdleKnob)
          _MissingRow(
            key: const Key('knob-idle-missing'),
            title: '静止旋钮',
            note: '深色没有静止旋钮层样式。开关画板上的旋钮看起来是白的，这里不把它写成令牌。',
            label: secondary,
          ),
        _SampleRow(
          title: '关 · 按下',
          label: label,
          secondary: secondary,
          detail:
              '未着色按下。阴影在下，发光在上。稿没有写叠加顺序，待核验。'
              '${_styleDetail(catalog.trackUnfilledClicked)}',
          child: _ToggleSpecimen(
            catalog: catalog,
            on: false,
            clicked: true,
            trackKey: const Key('track-unfilled-clicked'),
            knobKey: const Key('knob-clicked'),
          ),
        ),
        _SampleRow(
          title: '开 · 按下',
          label: label,
          secondary: secondary,
          detail: '着色按下。${_styleDetail(catalog.trackFilledClicked)}',
          child: _ToggleSpecimen(
            catalog: catalog,
            on: true,
            clicked: true,
            trackKey: const Key('track-filled-clicked'),
          ),
        ),
        const SizedBox(height: 8),
        Text('滑杆 · $tone', style: LingyunTextStyles.headline(color: label)),
        const SizedBox(height: 8),
        _SampleRow(
          title: '中部 · 静止',
          label: label,
          secondary: secondary,
          detail: hasIdleKnob ? '圆旋钮骑在轨道上，着色在左。轨道条高 6。' : '深色没有静止旋钮，只留轨道。着色在左。',
          child: _SliderSpecimen(
            key: const Key('slider-idle'),
            catalog: catalog,
            clicked: false,
          ),
        ),
        _SampleRow(
          title: '中部 · 按下',
          label: label,
          secondary: secondary,
          detail: '按下的圆旋钮叠在同一条轨道上。',
          child: _SliderSpecimen(
            key: const Key('slider-clicked'),
            catalog: catalog,
            clicked: true,
          ),
        ),
        const SizedBox(height: 8),
        _SampleRow(
          title: '未着色 · 禁用',
          label: label,
          secondary: secondary,
          detail: _styleDetail(catalog.trackUnfilledDisabled),
          child: _Halo(
            child: ControlLayerView(
              key: const Key('track-unfilled-disabled'),
              style: catalog.trackUnfilledDisabled,
              width: _toggleTrackWidth,
              height: _toggleTrackHeight,
              borderRadius: _stadium(_toggleTrackHeight),
            ),
          ),
        ),
        _MissingRow(
          key: const Key('track-filled-disabled-missing'),
          title: '着色 · 禁用',
          note: '设计稿没有这一层。',
          label: secondary,
        ),
        const SizedBox(height: 8),
        Text(
          '按下阴影的高斯半径是 3，饱和度字段是 0。'
          '图上的模糊用了界面库阴影的半径换算，不是稿里的 σ，待核验。'
          '0 不按去色处理。'
          '发光描边的 Plus Darker 先按颜色本身画，公式待核验。'
          '描边检查器里还有一条未启用的渐变，没有画。'
          '步进器没有单独的旋钮或轨道层样式。'
          '静止旋钮的阴影是模糊 36、下移 3、黑色 5%。示意四周留出空位，避免被裁掉。',
          key: const Key('controls-notes'),
          style: LingyunTextStyles.footnote(color: secondary),
        ),
      ],
    );
  }
}

/// Toggle artboard, points.
const double _toggleTrackWidth = 64;

const double _toggleTrackHeight = 28;

/// Shared knob height from the toggle and slider symbols, drawn as a circle.
const double _knobDiameter = 24;

/// Gap between the toggle thumb and the pill.
const double _knobInset = 2;

/// Slider bar height inside the 52pt artboard. The 370×22 symbol also
/// includes tick padding, which this specimen does not draw.
const double _sliderTrackHeight = 6;

const double _sliderTrackWidth = 280;

/// Room for blur 36 and the 3pt offset. Not a token.
const EdgeInsets _haloPadding = EdgeInsets.fromLTRB(36, 28, 36, 44);

BorderRadius _stadium(double height) => BorderRadius.circular(height / 2);

class _Halo extends StatelessWidget {
  const _Halo({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: _haloPadding, child: child);
  }
}

class _SampleRow extends StatelessWidget {
  const _SampleRow({
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
          child,
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

class _ToggleSpecimen extends StatelessWidget {
  const _ToggleSpecimen({
    required this.catalog,
    required this.on,
    required this.clicked,
    this.trackKey,
    this.knobKey,
  });

  final ControlLayerCatalog catalog;
  final bool on;
  final bool clicked;
  final Key? trackKey;
  final Key? knobKey;

  @override
  Widget build(BuildContext context) {
    final track = on
        ? (clicked ? catalog.trackFilledClicked : catalog.trackFilledIdle)
        : (clicked ? catalog.trackUnfilledClicked : catalog.trackUnfilledIdle);
    final drawKnob = clicked || catalog.knobIdle != null;
    final knobLeft = on
        ? _toggleTrackWidth - _knobInset - _knobDiameter
        : _knobInset;

    return _Halo(
      child: SizedBox(
        width: _toggleTrackWidth,
        height: _toggleTrackHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ControlLayerView(
              key: trackKey,
              style: track,
              width: _toggleTrackWidth,
              height: _toggleTrackHeight,
              borderRadius: _stadium(_toggleTrackHeight),
            ),
            if (drawKnob)
              Positioned(
                left: knobLeft,
                top: _knobInset,
                child: ControlKnobStack(
                  key: knobKey,
                  brightness: catalog.brightness,
                  width: _knobDiameter,
                  height: _knobDiameter,
                  clicked: clicked,
                  borderRadius: _stadium(_knobDiameter),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SliderSpecimen extends StatelessWidget {
  const _SliderSpecimen({
    super.key,
    required this.catalog,
    required this.clicked,
  });

  final ControlLayerCatalog catalog;
  final bool clicked;

  @override
  Widget build(BuildContext context) {
    final filled = clicked
        ? catalog.trackFilledClicked
        : catalog.trackFilledIdle;
    final unfilled = clicked
        ? catalog.trackUnfilledClicked
        : catalog.trackUnfilledIdle;
    final drawKnob = clicked || catalog.knobIdle != null;
    final knobLeft = (_sliderTrackWidth - _knobDiameter) * 0.62;
    final fillWidth = knobLeft + _knobDiameter / 2;
    final trackTop = (_knobDiameter - _sliderTrackHeight) / 2;
    final trackRadius = _stadium(_sliderTrackHeight);

    return _Halo(
      child: SizedBox(
        width: _sliderTrackWidth,
        height: _knobDiameter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              width: _sliderTrackWidth,
              top: trackTop,
              height: _sliderTrackHeight,
              child: Stack(
                children: [
                  ControlLayerView(
                    style: unfilled,
                    width: _sliderTrackWidth,
                    height: _sliderTrackHeight,
                    borderRadius: trackRadius,
                  ),
                  ClipRect(
                    clipper: _LeftWidthClip(fillWidth),
                    child: ControlLayerView(
                      style: filled,
                      width: _sliderTrackWidth,
                      height: _sliderTrackHeight,
                      borderRadius: trackRadius,
                    ),
                  ),
                ],
              ),
            ),
            if (drawKnob)
              Positioned(
                left: knobLeft,
                top: 0,
                child: ControlKnobStack(
                  brightness: catalog.brightness,
                  width: _knobDiameter,
                  height: _knobDiameter,
                  clicked: clicked,
                  borderRadius: _stadium(_knobDiameter),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Keeps the left cap of a full-width pill and cuts a straight edge under
/// the knob. The layer style itself has no radius.
class _LeftWidthClip extends CustomClipper<Rect> {
  const _LeftWidthClip(this.width);

  final double width;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, width, size.height);

  @override
  bool shouldReclip(covariant _LeftWidthClip oldClipper) {
    return oldClipper.width != width;
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
