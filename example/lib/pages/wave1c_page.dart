import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Which Wave 1c control the gallery is showing.
///
/// `?page=segmented` (also `segments`) and `?page=pages`
/// (`page-controls`, `pagecontrol`) open this page on that segment.
enum Wave1cPanel {
  segmented,
  pages;

  static Wave1cPanel? fromQuery(String? page) {
    return switch (page) {
      'segmented' || 'segments' => Wave1cPanel.segmented,
      'pages' || 'page-controls' || 'pagecontrol' => Wave1cPanel.pages,
      _ => null,
    };
  }
}

/// Segmented controls and page controls.
///
/// Visible copy is Simplified Chinese. Colors come from [LingyunTheme].
class Wave1cPage extends StatefulWidget {
  const Wave1cPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.initialPanel = Wave1cPanel.segmented,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Wave1cPanel initialPanel;

  @override
  State<Wave1cPage> createState() => _Wave1cPageState();
}

class _Wave1cPageState extends State<Wave1cPage> {
  late Wave1cPanel _panel = widget.initialPanel;
  int _live = 0;
  int _reduced = 0;

  @override
  void didUpdateWidget(Wave1cPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPanel != widget.initialPanel) {
      _panel = widget.initialPanel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    final primary = colors.liquidGlassLabels.primary;
    final secondary = colors.liquidGlassLabels.secondary;
    final adaptivity = LingyunAdaptivity.maybeOf(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      children: [
        Text(
          '分段与页面控件',
          key: const Key('wave1c-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: primary),
        ),
        const SizedBox(height: 8),
        Text(
          '分段的选中滑块是液态玻璃透镜，材质为常规小，和玻璃按钮相同。'
          '轨道是系统填充的三级色，不是玻璃，也不是厚材质。'
          '默认选中标签用液态玻璃主色，和玻璃按钮一致；'
          '只有传入着色时，选中标签才改用着色。滑块本身不变成色块。'
          '小尺寸高 32，大尺寸高 50。宽 370 是样张宽度，控件会随父级伸展。'
          '点按后透镜滑到新的一段。按下时透镜略收，和玻璃按钮同一手感。'
          '减少动态效果会关掉弹性，透镜直接落点。'
          '弹簧回弹幅度没有写成令牌。',
          style: LingyunTextStyles.body(color: primary),
        ),
        const SizedBox(height: 16),
        _specimen(
          LingyunSegmentedControl<Wave1cPanel>(
            key: const Key('wave1c-panel'),
            segments: const [
              LingyunSegment(value: Wave1cPanel.segmented, label: '分段'),
              LingyunSegment(value: Wave1cPanel.pages, label: '页点'),
            ],
            selected: _panel,
            onChanged: (value) => setState(() => _panel = value),
          ),
        ),
        const SizedBox(height: 12),
        _specimen(
          LingyunSegmentedControl<ThemeMode>(
            key: const Key('wave1c-brightness'),
            segments: const [
              LingyunSegment(value: ThemeMode.light, label: '浅色'),
              LingyunSegment(value: ThemeMode.system, label: '系统'),
              LingyunSegment(value: ThemeMode.dark, label: '深色'),
            ],
            selected: widget.themeMode,
            onChanged: widget.onThemeModeChanged,
          ),
        ),
        const SizedBox(height: 24),
        if (_panel == Wave1cPanel.segmented) ...[
          _caption(primary, '小尺寸 · 两段'),
          _specimen(
            const LingyunSegmentedControl<int>(
              key: Key('segmented-two'),
              segments: [
                LingyunSegment(value: 0, label: '列表'),
                LingyunSegment(value: 1, label: '地图'),
              ],
              selected: 0,
              onChanged: _keepInt,
            ),
          ),
          _caption(primary, '小尺寸 · 三段，按下'),
          _detail(secondary, '按下态钉住，方便对照。松手后的缩放和玻璃按钮相同。'),
          _specimen(
            const LingyunSegmentedControl<int>(
              key: Key('segmented-pressed'),
              segments: [
                LingyunSegment(value: 0, label: '年'),
                LingyunSegment(value: 1, label: '月'),
                LingyunSegment(value: 2, label: '日'),
              ],
              selected: 1,
              forcePressed: true,
              onChanged: _keepInt,
            ),
          ),
          _caption(primary, '小尺寸 · 五段'),
          _specimen(
            const LingyunSegmentedControl<int>(
              key: Key('segmented-five'),
              segments: [
                LingyunSegment(value: 0, label: '全部'),
                LingyunSegment(value: 1, label: '照片'),
                LingyunSegment(value: 2, label: '相簿'),
                LingyunSegment(value: 3, label: '人物'),
                LingyunSegment(value: 4, label: '地点'),
              ],
              selected: 2,
              onChanged: _keepInt,
            ),
          ),
          _caption(primary, '大尺寸 · 三段'),
          _specimen(
            const LingyunSegmentedControl<int>(
              key: Key('segmented-large'),
              size: LingyunSegmentedControlSize.large,
              segments: [
                LingyunSegment(value: 0, label: '今天'),
                LingyunSegment(value: 1, label: '最近'),
                LingyunSegment(value: 2, label: '归档'),
              ],
              selected: 0,
              onChanged: _keepInt,
            ),
          ),
          _caption(primary, '禁用'),
          _detail(secondary, '不能点。标签用三级色。透镜仍是液态玻璃。'),
          _specimen(
            const LingyunSegmentedControl<int>(
              key: Key('segmented-disabled'),
              segments: [
                LingyunSegment(value: 0, label: '开'),
                LingyunSegment(value: 1, label: '关'),
              ],
              selected: 0,
            ),
          ),
          _caption(primary, '着色标签'),
          _detail(secondary, '选中标签改用系统红。滑块仍是液态玻璃，不是色块。'),
          _specimen(
            LingyunSegmentedControl<int>(
              key: const Key('segmented-tint'),
              segments: const [
                LingyunSegment(value: 0, label: '标准'),
                LingyunSegment(value: 1, label: '强调'),
              ],
              selected: 1,
              tint: colors.system.red,
              onChanged: _keepInt,
            ),
          ),
          _caption(primary, '实时'),
          _detail(secondary, '实时：${_liveLabel(_live)}。点按后透镜滑过去。'),
          _specimen(
            LingyunSegmentedControl<int>(
              key: const Key('segmented-live'),
              segments: const [
                LingyunSegment(value: 0, label: '左'),
                LingyunSegment(value: 1, label: '中'),
                LingyunSegment(value: 2, label: '右'),
              ],
              selected: _live,
              onChanged: (value) => setState(() => _live = value),
            ),
          ),
          _caption(primary, '减少动态效果'),
          _detail(secondary, '这一条关掉弹性。点按后透镜直接落点。'),
          _specimen(
            LingyunAdaptivity(
              reduceMotion: true,
              reduceTransparency: adaptivity?.reduceTransparency ?? false,
              highContrast: adaptivity?.highContrast ?? false,
              child: LingyunSegmentedControl<int>(
                key: const Key('segmented-reduced'),
                segments: const [
                  LingyunSegment(value: 0, label: '静'),
                  LingyunSegment(value: 1, label: '动'),
                ],
                selected: _reduced,
                onChanged: (value) => setState(() => _reduced = value),
              ),
            ),
          ),
        ] else ...[
          Text(
            '页面控件默认只指示当前位置，不能点。'
            '当前页是实心点，其余对比更低。'
            '不传着色时，当前点用液态玻璃主色，其余用三级色。'
            '传入着色后，当前点跟着色，其余降低对比。'
            '圆点是内容，不是液态玻璃，也不是厚材质。'
            '忙碌底上的托盘才是液态玻璃常规小，用来保住对比。'
            '页码变化时高亮点短移。减少动态效果时直接落点。',
            style: LingyunTextStyles.body(color: primary),
          ),
          const SizedBox(height: 16),
          _caption(primary, '五页 · 当前第 3 页'),
          _detail(secondary, '指示器。不能点。'),
          _pages(
            const LingyunPageControl(
              key: Key('page-five'),
              count: 5,
              currentIndex: 2,
              semanticLabel: '第 3 页，共 5 页',
            ),
          ),
          _caption(primary, '八页 · 当前第 1 页'),
          _pages(
            const LingyunPageControl(
              key: Key('page-eight'),
              count: 8,
              currentIndex: 0,
              semanticLabel: '第 1 页，共 8 页',
            ),
          ),
          _caption(primary, '着色'),
          _detail(secondary, '当前点跟系统红。其余是同一颜色的低对比。'),
          _pages(
            LingyunPageControl(
              key: const Key('page-tint'),
              count: 5,
              currentIndex: 1,
              tint: colors.system.red,
              semanticLabel: '第 2 页，共 5 页',
            ),
          ),
          _caption(primary, '忙碌背景'),
          _detail(secondary, '托盘是液态玻璃常规小。圆点仍是内容层。'),
          _specimen(
            _BusyPlate(
              colors: [
                colors.system.red,
                colors.system.orange,
                colors.system.yellow,
                colors.system.green,
                colors.system.teal,
                colors.system.cyan,
                colors.system.blue,
                colors.system.purple,
              ],
              child: LingyunPageControl(
                key: const Key('page-busy'),
                count: 5,
                currentIndex: 2,
                platter: true,
                semanticLabel: '第 3 页，共 5 页',
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '不是厚材质。选中透镜和忙碌底托盘都是液态玻璃。',
          key: const Key('wave1c-notes'),
          style: LingyunTextStyles.footnote(color: secondary),
        ),
      ],
    );
  }
}

String _liveLabel(int index) {
  return switch (index) {
    0 => '左',
    1 => '中',
    _ => '右',
  };
}

void _keepInt(int _) {}

Widget _caption(Color color, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Text(text, style: LingyunTextStyles.headline(color: color)),
  );
}

Widget _detail(Color color, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: LingyunTextStyles.caption1(color: color)),
  );
}

Widget _specimen(Widget child) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final width = maxWidth < LingyunSegmentedMetrics.specimenWidth
          ? maxWidth
          : LingyunSegmentedMetrics.specimenWidth;
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(width: width, child: child),
      );
    },
  );
}

Widget _pages(Widget child) {
  return Align(alignment: Alignment.centerLeft, child: child);
}

class _BusyPlate extends StatelessWidget {
  const _BusyPlate({required this.colors, required this.child});

  final List<Color> colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _BandPainter(colors))),
          child,
        ],
      ),
    );
  }
}

class _BandPainter extends CustomPainter {
  const _BandPainter(this.colors);

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final band = size.width / colors.length;
    for (var i = 0; i < colors.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * band, 0, band + 0.5, size.height),
        Paint()..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BandPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
