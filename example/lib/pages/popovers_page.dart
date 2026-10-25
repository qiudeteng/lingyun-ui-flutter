import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Sketch **Popovers** gallery.
///
/// Chrome is Liquid Glass Regular Medium (non-binding, 待核验). Copy on
/// this page is Simplified Chinese. Light / dark follows [brightness].
class PopoversPage extends StatefulWidget {
  const PopoversPage({
    super.key,
    this.brightness = Brightness.light,
    this.onBrightnessChanged,
  });

  final Brightness brightness;
  final ValueChanged<Brightness>? onBrightnessChanged;

  @override
  State<PopoversPage> createState() => _PopoversPageState();
}

class _PopoversPageState extends State<PopoversPage> {
  String _result = '尚未弹出';

  void _setResult(String? value) {
    if (!mounted) return;
    setState(() => _result = value ?? '已关闭');
  }

  Future<void> _open(BuildContext anchorContext) async {
    final value = await showLingyunPopover<String>(
      context,
      anchorContext: anchorContext,
      semanticsLabel: '弹出框',
      preferredPlacement: LingyunPopoverPlacement.below,
      backdrop: _liveBackdrop,
      builder: (context) {
        final colors = LingyunTheme.colorsOf(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '已选 2 项',
              style: LingyunTextStyles.headline(color: colors.labels.primary),
            ),
            const SizedBox(height: 2),
            Text(
              '周末散步',
              style: LingyunTextStyles.footnote(color: colors.labels.secondary),
            ),
            const SizedBox(height: 8),
            LingyunPopoverAction(
              key: const Key('popover-action-detail'),
              label: '查看详情',
              onPressed: () => Navigator.pop(context, '查看详情'),
            ),
            LingyunPopoverAction(
              key: const Key('popover-action-close'),
              label: '关闭',
              onPressed: () => Navigator.pop(context, '关闭'),
            ),
          ],
        );
      },
    );
    _setResult(value);
  }

  @override
  Widget build(BuildContext context) {
    return LingyunTheme(
      brightness: widget.brightness,
      child: CupertinoTheme(
        data: LingyunTheme.cupertinoThemeFor(widget.brightness),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide = constraints.maxWidth >= 960;
            final below = _stage(
              themeContext: context,
              title: '箭头朝上',
              stageKey: const Key('popover-stage-below'),
              placement: LingyunPopoverPlacement.below,
              pressed: false,
            );
            final above = _stage(
              themeContext: context,
              title: '箭头朝下',
              stageKey: const Key('popover-stage-above'),
              placement: LingyunPopoverPlacement.above,
              pressed: false,
            );
            final after = _stage(
              themeContext: context,
              title: '箭头朝后',
              stageKey: const Key('popover-stage-after'),
              placement: LingyunPopoverPlacement.after,
              pressed: false,
            );
            final pressed = _stage(
              themeContext: context,
              title: '按下',
              stageKey: const Key('popover-stage-pressed'),
              placement: LingyunPopoverPlacement.below,
              pressed: true,
            );
            return ListView(
              key: const Key('popover-gallery-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                _header(),
                const SizedBox(height: 12),
                if (sideBySide)
                  SizedBox(
                    height: 340,
                    child: Row(
                      children: [
                        Expanded(child: below),
                        const SizedBox(width: 12),
                        Expanded(child: above),
                      ],
                    ),
                  )
                else ...[
                  SizedBox(height: 340, child: below),
                  const SizedBox(height: 12),
                  SizedBox(height: 340, child: above),
                ],
                const SizedBox(height: 12),
                if (sideBySide)
                  SizedBox(
                    height: 280,
                    child: Row(
                      children: [
                        Expanded(child: after),
                        const SizedBox(width: 12),
                        Expanded(child: pressed),
                      ],
                    ),
                  )
                else ...[
                  SizedBox(height: 280, child: after),
                  const SizedBox(height: 12),
                  SizedBox(height: 280, child: pressed),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    final colors = LingyunColors.forBrightness(widget.brightness);
    final label = colors.labels.primary;
    final secondary = colors.labels.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '弹出框',
          key: const Key('popover-title'),
          style: LingyunTextStyles.title1(emphasized: true, color: label),
        ),
        const SizedBox(height: 4),
        Text(
          'chrome = 液态玻璃 Regular Medium（非约束，待核验）。'
          '不是厚材质，不是菜单，也不是操作表。'
          '进出场从箭头尖端缩放，不淡出，也不新写弹簧。'
          '按压沿用玻璃按钮。减弱动态时时长为零。点外面收起。',
          key: const Key('popover-motion-note'),
          style: LingyunTextStyles.footnote(color: secondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CupertinoSlidingSegmentedControl<Brightness>(
              groupValue: widget.brightness,
              children: const {
                Brightness.light: Text('浅色', key: Key('popover-theme-light')),
                Brightness.dark: Text('深色', key: Key('popover-theme-dark')),
              },
              onValueChanged: (value) {
                if (value != null) widget.onBrightnessChanged?.call(value);
              },
            ),
            Builder(
              builder: (anchorContext) {
                return GlassButton.label(
                  key: const Key('popover-open'),
                  label: '打开弹出框',
                  onPressed: () => _open(anchorContext),
                );
              },
            ),
            Text(
              '上次结果：$_result',
              key: const Key('popover-result'),
              style: LingyunTextStyles.footnote(color: label),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stage({
    required BuildContext themeContext,
    required String title,
    required Key stageKey,
    required LingyunPopoverPlacement placement,
    required bool pressed,
  }) {
    final colors = LingyunTheme.of(themeContext).colors;
    final popover = LingyunPopover(
      placement: placement,
      child: _sample(colors, pressed: pressed),
    );
    final chip = _chip(colors);
    final plate = _plate(stageKey: stageKey, popover: popover);
    final vertical =
        placement == LingyunPopoverPlacement.below ||
        placement == LingyunPopoverPlacement.above;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: LingyunTextStyles.caption1(
            emphasized: true,
            color: colors.labels.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: vertical
              ? Column(
                  children: [
                    if (placement == LingyunPopoverPlacement.below) chip,
                    Expanded(child: plate),
                    if (placement == LingyunPopoverPlacement.above) chip,
                  ],
                )
              : Row(
                  children: [
                    chip,
                    const SizedBox(width: 4),
                    Expanded(child: plate),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _chip(LingyunColors colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.fills.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '分享',
          style: LingyunTextStyles.footnote(color: colors.labels.primary),
        ),
      ),
    );
  }

  Widget _plate({required Key stageKey, required Widget popover}) {
    return Stack(
      key: stageKey,
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        const CustomPaint(
          painter: _PopoverStripePainter(),
          child: SizedBox.expand(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Center(child: popover),
        ),
      ],
    );
  }

  Widget _sample(LingyunColors colors, {required bool pressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '已选 2 项',
          style: LingyunTextStyles.headline(color: colors.labels.primary),
        ),
        const SizedBox(height: 2),
        Text(
          '周末散步',
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 8),
        LingyunPopoverAction(
          label: '查看详情',
          forcePressed: pressed,
          onPressed: () {},
        ),
      ],
    );
  }
}

Widget _liveBackdrop(BuildContext context, LingyunPopoverMetrics metrics) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final color in _PopoverStripePainter.bands)
        Expanded(child: ColoredBox(color: color)),
    ],
  );
}

/// Vertical bands. Same colors as the Materials page stripe field, not a token.
class _PopoverStripePainter extends CustomPainter {
  const _PopoverStripePainter();

  static const List<Color> bands = [
    Color(0xFF5C5C60),
    Color(0xFF7A7A7E),
    Color(0xFF9A9A9E),
    Color(0xFFB4B4B8),
    Color(0xFFC8C8CC),
    Color(0xFFD8D8DC),
    Color(0xFFE8E8EC),
    Color(0xFFF4F4F6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final band = size.width / bands.length;
    final paint = Paint();
    for (var i = 0; i < bands.length; i++) {
      paint.color = bands[i];
      canvas.drawRect(
        Rect.fromLTWH(i * band, 0, band + 0.5, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PopoverStripePainter oldDelegate) => false;
}
