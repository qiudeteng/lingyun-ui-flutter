import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Sketch **Sheets** gallery.
///
/// Chrome on every platter is Materials Thick. Copy on this page is
/// Simplified Chinese. Light / dark follows [brightness]; the segmented
/// control asks the gallery to switch.
class SheetsPage extends StatefulWidget {
  const SheetsPage({
    super.key,
    this.brightness = Brightness.light,
    this.onBrightnessChanged,
  });

  final Brightness brightness;
  final ValueChanged<Brightness>? onBrightnessChanged;

  @override
  State<SheetsPage> createState() => _SheetsPageState();
}

class _SheetsPageState extends State<SheetsPage> {
  final GlobalKey<NavigatorState> _compactNav = GlobalKey<NavigatorState>();
  bool _keyboard = false;
  String _result = '尚未弹出';

  void _setResult(String? value) {
    if (!mounted) return;
    setState(() => _result = value ?? '已关闭');
  }

  Future<void> _openWindow() async {
    final value = await showLingyunSheet<String>(
      context,
      grabberLabel: '抓手',
      semanticsLabel: '工作表',
      backdrop: _sheetBackdrop,
      builder: _sheetBody,
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
            final phone = const EdgeInsets.only(top: 47, bottom: 34);
            final medium = SizedBox(
              height: 520,
              child: _Specimen(
                detent: LingyunSheetDetent.medium,
                stageKey: const Key('sheet-stage-compact-medium'),
                maxWidth: 390,
                safeArea: phone,
              ),
            );
            final large = SizedBox(
              height: 520,
              child: _Specimen(
                detent: LingyunSheetDetent.large,
                stageKey: const Key('sheet-stage-compact-large'),
                maxWidth: 390,
                safeArea: phone,
              ),
            );
            return ListView(
              key: const Key('sheet-gallery-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                _header(),
                const SizedBox(height: 12),
                if (sideBySide)
                  SizedBox(
                    height: 520,
                    child: Row(
                      children: [
                        Expanded(child: medium),
                        const SizedBox(width: 12),
                        Expanded(child: large),
                      ],
                    ),
                  )
                else ...[
                  medium,
                  const SizedBox(height: 12),
                  large,
                ],
                const SizedBox(height: 12),
                const SizedBox(
                  height: 280,
                  child: _Specimen(
                    detent: LingyunSheetDetent.large,
                    stageKey: Key('sheet-stage-wide'),
                    safeArea: EdgeInsets.only(top: 16, bottom: 16),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 360, child: _live()),
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
          '工作表',
          key: const Key('sheet-title'),
          style: LingyunTextStyles.title1(emphasized: true, color: label),
        ),
        const SizedBox(height: 4),
        Text(
          'chrome = Materials Thick。不是液态玻璃，不是玻璃按钮，也不是程序坞。'
          '中档约一半高，高档在顶部留一隙。抓手可拖；滚到顶后下拉会带动工作表。'
          '圆角、遮罩和比例待核验。',
          key: const Key('sheet-thick-note'),
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
                Brightness.light: Text('浅色', key: Key('sheet-theme-light')),
                Brightness.dark: Text('深色', key: Key('sheet-theme-dark')),
              },
              onValueChanged: (value) {
                if (value != null) widget.onBrightnessChanged?.call(value);
              },
            ),
            Text(
              '上次结果：$_result',
              key: const Key('sheet-result'),
              style: LingyunTextStyles.footnote(color: label),
            ),
          ],
        ),
      ],
    );
  }

  Widget _live() {
    final colors = LingyunColors.forBrightness(widget.brightness);
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = mathMin(360, constraints.maxWidth * 0.46);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: frameWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '紧凑框',
                    style: LingyunTextStyles.caption1(
                      emphasized: true,
                      color: colors.labels.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(child: _compactFrame()),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _controls(colors)),
          ],
        );
      },
    );
  }

  Widget _controls(LingyunColors colors) {
    final label = colors.labels.primary;
    final secondary = colors.labels.secondary;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text('交互', style: LingyunTextStyles.headline(color: label)),
        const SizedBox(height: 6),
        Text(
          '当前窗口按这个窗口的宽度分档。紧凑框固定在手机宽度里，用来看贴底和键盘。'
          '桌面没有软键盘时，打开「模拟键盘」。真机键盘走系统 insets。',
          style: LingyunTextStyles.footnote(color: secondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CupertinoSwitch(
              key: const Key('sheet-keyboard'),
              value: _keyboard,
              onChanged: (value) => setState(() => _keyboard = value),
            ),
            const SizedBox(width: 8),
            Text('模拟键盘', style: LingyunTextStyles.body(color: label)),
          ],
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          key: const Key('sheet-open-window'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onPressed: () {
            _openWindow();
          },
          child: const Text('在当前窗口弹出'),
        ),
      ],
    );
  }

  Widget _compactFrame() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final parent = MediaQuery.of(context);
        return MediaQuery(
          data: parent.copyWith(
            size: size,
            padding: const EdgeInsets.only(top: 47, bottom: 34),
            viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
            viewInsets: _keyboard
                ? const EdgeInsets.only(bottom: _keyboardInset)
                : EdgeInsets.zero,
          ),
          child: _SimulatedKeyboard(
            enabled: _keyboard,
            inset: _keyboardInset,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Navigator(
                key: _compactNav,
                onGenerateRoute: (settings) {
                  return CupertinoPageRoute<void>(
                    builder: (routeContext) {
                      return _CompactLauncher(
                        onOpen: () async {
                          final value = await showLingyunSheet<String>(
                            routeContext,
                            useRootNavigator: false,
                            grabberLabel: '抓手',
                            semanticsLabel: '工作表',
                            backdrop: _sheetBackdrop,
                            builder: _sheetBody,
                          );
                          _setResult(value);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

const double _keyboardInset = 150;

class _SimulatedKeyboard extends InheritedWidget {
  const _SimulatedKeyboard({
    required this.enabled,
    required this.inset,
    required super.child,
  });

  final bool enabled;
  final double inset;

  static _SimulatedKeyboard? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SimulatedKeyboard>();
  }

  @override
  bool updateShouldNotify(_SimulatedKeyboard oldWidget) {
    return enabled != oldWidget.enabled || inset != oldWidget.inset;
  }
}

class _CompactLauncher extends StatelessWidget {
  const _CompactLauncher({required this.onOpen});

  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    final keyboard = _SimulatedKeyboard.maybeOf(context);
    final showKeyboard = keyboard?.enabled ?? false;
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '收件箱',
                style: LingyunTextStyles.headline(color: colors.labels.primary),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                key: const Key('sheet-open-compact'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: () {
                  onOpen();
                },
                child: const Text('在紧凑框弹出'),
              ),
            ],
          ),
        ),
        if (showKeyboard)
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: keyboard!.inset,
              child: ColoredBox(
                color: colors.grays.gray5,
                child: Center(
                  child: Text(
                    '键盘',
                    style: LingyunTextStyles.footnote(
                      color: colors.labels.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Specimen extends StatelessWidget {
  const _Specimen({
    required this.detent,
    required this.stageKey,
    required this.safeArea,
    this.maxWidth,
  });

  final LingyunSheetDetent detent;
  final Key stageKey;
  final EdgeInsets safeArea;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.of(context).colors;
    final stop = detent == LingyunSheetDetent.medium ? '中档' : '高档';
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = maxWidth == null
            ? constraints.maxWidth
            : mathMin(maxWidth!, constraints.maxWidth);
        final bucket = switch (resolveFlutterPageBucket(width: width)) {
          LingyunPageWidthBucket.compact => '紧凑',
          LingyunPageWidthBucket.regular => '常规',
          LingyunPageWidthBucket.wide => '宽',
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$bucket · $stop',
              style: LingyunTextStyles.caption1(
                emphasized: true,
                color: colors.labels.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Center(
                child: SizedBox(width: width, child: _plate(colors)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _plate(LingyunColors colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = LingyunSheetMetrics(
          bounds: Size(constraints.maxWidth, constraints.maxHeight),
          safeArea: safeArea,
          keyboardInset: 0,
        );
        final sheetW = mathMin(
          metrics.width,
          mathMax(0, constraints.maxWidth - _stripePadH * 2),
        );
        final sheetH = mathMin(
          metrics.heightFor(detent),
          mathMax(0, constraints.maxHeight - _stripePadV * 2),
        );
        final side = (constraints.maxWidth - sheetW) / 2;
        // Materials Thick swatch: stripes are the stack's bottom child,
        // GlassSurface sits in the padding directly above them. No opaque
        // box and no clip between the two.
        return Stack(
          key: stageKey,
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _SheetStripePainter(
                left: side - _stripePadH,
                width: sheetW + _stripePadH * 2,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                side,
                _stripePadV,
                side,
                _stripePadV,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: sheetW,
                  height: sheetH,
                  child: LingyunSheet(
                    attachedToBottom: metrics.attachedToBottom,
                    grabberLabel: '抓手',
                    child: _specimenBody(colors),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _specimenBody(LingyunColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '编辑项目',
            style: LingyunTextStyles.headline(color: colors.labels.primary),
          ),
          const SizedBox(height: 6),
          Text(
            '周末散步',
            style: LingyunTextStyles.body(color: colors.labels.primary),
          ),
          Text(
            '滨江公园',
            style: LingyunTextStyles.footnote(color: colors.labels.secondary),
          ),
        ],
      ),
    );
  }
}

Widget _sheetBody(BuildContext context, LingyunSheetController controller) {
  final colors = LingyunTheme.colorsOf(context);
  final label = colors.labels.primary;
  final secondary = colors.labels.secondary;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('编辑项目', style: LingyunTextStyles.title2(color: label)),
      const SizedBox(height: 4),
      Text(
        '拖动抓手，或滚到顶后继续下拉。',
        style: LingyunTextStyles.footnote(color: secondary),
      ),
      const SizedBox(height: 8),
      CupertinoTextField(
        key: const Key('sheet-note-field'),
        placeholder: '添加备注',
        style: LingyunTextStyles.body(color: label),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      const SizedBox(height: 4),
      Wrap(
        spacing: 4,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: () => controller.animateTo(LingyunSheetDetent.medium),
            child: const Text('中档'),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: () => controller.animateTo(LingyunSheetDetent.large),
            child: const Text('高档'),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: () => Navigator.of(context).pop('完成'),
            child: const Text('完成'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text('名称', style: LingyunTextStyles.headline(color: label)),
      Text('周末散步', style: LingyunTextStyles.body(color: secondary)),
      const SizedBox(height: 8),
      Text('地点', style: LingyunTextStyles.headline(color: label)),
      Text('滨江公园', style: LingyunTextStyles.body(color: secondary)),
      const SizedBox(height: 480),
      Text('列表底部', style: LingyunTextStyles.footnote(color: secondary)),
    ],
  );
}

double mathMin(double a, double b) => a < b ? a : b;

/// Same inset as the Materials page stripe field (`horizontal: 28`,
/// `vertical: 14`). Not a token.
const double _stripePadH = 28;
const double _stripePadV = 14;

double mathMax(double a, double b) => a > b ? a : b;

/// Bands painted in the sheet route, as the stack child under the platter.
///
/// The route does not sample the page under it. [left] / [width] are the
/// stripe field: the platter plus the Materials padding, not the window.
Widget _sheetBackdrop(
  BuildContext context,
  LingyunSheetMetrics metrics,
  Rect platter,
) {
  return CustomPaint(
    painter: _SheetStripePainter(
      left: platter.left - _stripePadH,
      width: platter.width + _stripePadH * 2,
    ),
    child: const SizedBox.expand(),
  );
}

/// Vertical bands. Same colors as the Materials page stripe field, not a token.
class _SheetStripePainter extends CustomPainter {
  const _SheetStripePainter({required this.left, required this.width});

  final double left;
  final double width;

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
    if (size.width <= 0 || size.height <= 0 || width <= 0) return;
    final band = width / bands.length;
    final paint = Paint();
    for (var i = 0; i < bands.length; i++) {
      paint.color = bands[i];
      canvas.drawRect(
        Rect.fromLTWH(left + i * band, 0, band + 0.5, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SheetStripePainter oldDelegate) {
    return oldDelegate.left != left || oldDelegate.width != width;
  }
}
