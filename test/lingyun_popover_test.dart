import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LingyunPopoverMetrics', () {
    test('a top anchor opens below and centers on the anchor', () {
      const anchor = Rect.fromLTWH(360, 40, 80, 36);
      const metrics = LingyunPopoverMetrics(
        bounds: Size(800, 600),
        safeArea: EdgeInsets.zero,
        anchor: anchor,
      );
      expect(metrics.placement, LingyunPopoverPlacement.below);
      expect(metrics.arrowEdge, LingyunPopoverArrowEdge.top);
      const chrome = Size(240, 120);
      final origin = metrics.originFor(chrome);
      expect(origin.dx, anchor.center.dx - chrome.width / 2);
      expect(origin.dy, anchor.bottom + LingyunPopoverLayout.anchorGap);
      expect(metrics.arrowCenterFor(chrome), chrome.width / 2);
      expect(metrics.tipFor(chrome), Offset(chrome.width / 2, 0));
      expect(metrics.alignmentFor(chrome), const Alignment(0, -1));
    });

    test('a preferred side is dropped when the room is under the minimum', () {
      const metrics = LingyunPopoverMetrics(
        bounds: Size(800, 600),
        safeArea: EdgeInsets.zero,
        anchor: Rect.fromLTWH(360, 524, 80, 36),
        preferredPlacement: LingyunPopoverPlacement.below,
      );
      expect(
        metrics.roomFor(LingyunPopoverPlacement.below),
        lessThan(LingyunPopoverLayout.minRoom),
      );
      expect(metrics.placement, LingyunPopoverPlacement.above);
      final origin = metrics.originFor(const Size(240, 120));
      expect(origin.dy, 524 - LingyunPopoverLayout.anchorGap - 120);
    });

    test(
      'the chrome stays inside the margin when the anchor is at the edge',
      () {
        const metrics = LingyunPopoverMetrics(
          bounds: Size(400, 600),
          safeArea: EdgeInsets.zero,
          anchor: Rect.fromLTWH(0, 40, 40, 36),
        );
        final origin = metrics.originFor(const Size(320, 100));
        expect(origin.dx, LingyunPopoverLayout.screenMargin);
      },
    );

    test('compact class does not change the width cap or the plate', () {
      const anchor = Rect.fromLTWH(660, 80, 80, 36);
      const wide = LingyunPopoverMetrics(
        bounds: Size(1400, 900),
        safeArea: EdgeInsets.zero,
        anchor: anchor,
      );
      const compact = LingyunPopoverMetrics(
        bounds: Size(1400, 900),
        safeArea: EdgeInsets.zero,
        anchor: anchor,
        horizontalSizeClass: 'compact',
      );
      expect(compact.bucket, LingyunPageWidthBucket.compact);
      expect(wide.bucket, LingyunPageWidthBucket.wide);
      expect(compact.maxBodyWidth, wide.maxBodyWidth);
      expect(compact.maxBodyWidth, LingyunPopoverLayout.maxWidth);
      expect(compact.placement, wide.placement);
    });

    test('keyboard bottom inset flips placement upward', () {
      const anchor = Rect.fromLTWH(150, 280, 80, 44);
      const resting = LingyunPopoverMetrics(
        bounds: Size(390, 844),
        safeArea: EdgeInsets.only(bottom: 34),
        anchor: anchor,
      );
      const lifted = LingyunPopoverMetrics(
        bounds: Size(390, 844),
        safeArea: EdgeInsets.only(bottom: 500),
        anchor: anchor,
      );
      expect(resting.roomFor(LingyunPopoverPlacement.below), greaterThan(96));
      expect(resting.placement, LingyunPopoverPlacement.below);
      expect(
        lifted.roomFor(LingyunPopoverPlacement.below),
        lessThan(lifted.roomFor(LingyunPopoverPlacement.above)),
      );
      expect(lifted.placement, LingyunPopoverPlacement.above);
    });

    test('RTL after places the chrome before the anchor', () {
      const anchor = Rect.fromLTWH(640, 80, 80, 40);
      const metrics = LingyunPopoverMetrics(
        bounds: Size(800, 600),
        safeArea: EdgeInsets.zero,
        anchor: anchor,
        preferredPlacement: LingyunPopoverPlacement.after,
        textDirection: TextDirection.rtl,
      );
      expect(metrics.placement, LingyunPopoverPlacement.after);
      expect(metrics.arrowEdge, LingyunPopoverArrowEdge.right);
      final origin = metrics.originFor(const Size(200, 80));
      expect(origin.dx, anchor.left - LingyunPopoverLayout.anchorGap - 200);
    });
  });

  test('popover sources stay off sheets, menus, and spring tokens', () {
    final library = _withoutComments(
      File('lib/src/widgets/lingyun_popover.dart').readAsStringSync(),
    );
    final gallery = File('example/lib/pages/popovers_page.dart')
        .readAsStringSync();
    final button = File('lib/src/widgets/glass_button.dart').readAsStringSync();
    expect(library.contains('LiquidGlassStyle.regularMedium'), isTrue);
    expect(library.contains('SpringDescription'), isFalse);
    expect(library.contains('stiffness'), isFalse);
    expect(library.contains('CupertinoPopupSurface'), isFalse);
    expect(library.contains('CupertinoActionSheet'), isFalse);
    expect(library.contains('CupertinoContextMenu'), isFalse);
    expect(library.contains('MaterialTier.thick'), isFalse);
    expect(library.contains('showLingyunSheet'), isFalse);
    expect(library.contains('FadeTransition'), isFalse);
    expect(library.contains('LingyunPopoverMotion.duration'), isTrue);
    expect(library.contains('viewInsets.bottom'), isTrue);
    expect(button.contains('0.97'), isTrue);
    expect(LingyunPopoverMotion.pressedScale, 0.97);
    for (final source in [library, gallery]) {
      final imports = source
          .split('\n')
          .where((line) => line.startsWith('import '))
          .toList();
      expect(
        imports.any(
          (line) =>
              line.contains('package:flutter/cupertino.dart') ||
              line.contains('package:flutter/material.dart'),
        ),
        isFalse,
      );
      expect(source.contains('CompatibilityBridge'), isFalse);
      expect(source.contains('UIScreen'), isFalse);
    }
    expect(gallery.contains('弹出框'), isTrue);
    expect(gallery.contains('浅色'), isTrue);
    expect(gallery.contains('深色'), isTrue);
    expect(gallery.contains('Regular Medium'), isTrue);
    expect(gallery.contains('菜单'), isTrue);
    expect(gallery.contains('操作表'), isTrue);
  });

  group('showLingyunPopover gestures', () {
    testWidgets('opens from the anchor with Regular Medium and no fade', (
      tester,
    ) async {
      await _pumpAnchor(tester, alignment: Alignment.topCenter);
      await tester.tap(find.byKey(const Key('popover-anchor')));
      await tester.pump();
      final route = ModalRoute.of(
        tester.element(find.byKey(const Key('lingyun-popover-scale'))),
      )!;
      expect(route.transitionDuration, LiquidGlassMotion.defaults.standard);
      final start = _scale(tester);
      await tester.pump(const Duration(milliseconds: 80));
      final mid = _scale(tester);
      expect(start, lessThan(0.9));
      expect(mid, greaterThan(start));
      expect(mid, lessThan(1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(_scale(tester), closeTo(1, 0.02));

      final surface = tester.widget<GlassSurface>(
        find.byKey(const Key('lingyun-popover-platter')),
      );
      expect(surface.style, LiquidGlassStyle.regularMedium);
      expect(surface.material, isNull);
      expect(surface.tokens, isNull);
      expect(surface.enableHoverHighlight, isFalse);

      final button = tester.getRect(find.byKey(const Key('popover-anchor')));
      final arrow = tester.getRect(
        find.byKey(const Key('lingyun-popover-arrow')),
      );
      final platter = tester.getRect(
        find.byKey(const Key('lingyun-popover-platter')),
      );
      expect(arrow.center.dx, closeTo(button.center.dx, 12));
      expect(
        arrow.top,
        closeTo(button.bottom + LingyunPopoverLayout.anchorGap, 4),
      );
      expect(platter.top, greaterThan(arrow.top));
      expect(_platterFadesIn(tester), isFalse);
    });

    testWidgets('outside tap reverses the scale and dismisses', (tester) async {
      await _pumpAnchor(tester, alignment: Alignment.topCenter);
      await tester.tap(find.byKey(const Key('popover-anchor')));
      await tester.pumpAndSettle();
      expect(find.text('查看详情'), findsOneWidget);
      await tester.tapAt(const Offset(8, 560));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(_scale(tester), lessThan(1));
      expect(_scale(tester), greaterThan(0));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lingyun-popover-platter')), findsNothing);
      expect(find.text('已关闭'), findsOneWidget);
    });

    testWidgets('press flexes the row then a tap returns its label', (
      tester,
    ) async {
      await _pumpAnchor(tester, alignment: Alignment.topCenter);
      await tester.tap(find.byKey(const Key('popover-anchor')));
      await tester.pumpAndSettle();
      final action = find.byKey(const Key('popover-action'));
      final gesture = await tester.startGesture(tester.getCenter(action));
      await tester.pump();
      final pressed = _actionScale(tester);
      expect(pressed.scale, LingyunPopoverMotion.pressedScale);
      expect(pressed.duration, LiquidGlassMotion.defaults.quick);
      await gesture.moveBy(const Offset(0, 180));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lingyun-popover-platter')), findsOneWidget);
      expect(_actionScale(tester).scale, 1);

      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lingyun-popover-platter')), findsNothing);
      expect(find.text('查看详情'), findsOneWidget);
    });

    testWidgets('a low anchor flips the popover above it', (tester) async {
      await _pumpAnchor(tester, alignment: Alignment.bottomCenter);
      await tester.tap(find.byKey(const Key('popover-anchor')));
      await tester.pumpAndSettle();
      final button = tester.getRect(find.byKey(const Key('popover-anchor')));
      final platter = tester.getRect(
        find.byKey(const Key('lingyun-popover-platter')),
      );
      expect(platter.bottom, lessThan(button.top));
    });

    testWidgets('reduce motion shows the full scale immediately', (
      tester,
    ) async {
      await _pumpAnchor(
        tester,
        alignment: Alignment.topCenter,
        reduceMotion: true,
      );
      await tester.tap(find.byKey(const Key('popover-anchor')));
      await tester.pump();
      expect(find.text('查看详情'), findsOneWidget);
      expect(_scale(tester), 1);
      final route = ModalRoute.of(
        tester.element(find.byKey(const Key('lingyun-popover-platter'))),
      )!;
      expect(route.transitionDuration, Duration.zero);
      expect(route.reverseTransitionDuration, Duration.zero);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('popover-action'))),
      );
      await tester.pump();
      final pressed = _actionScale(tester);
      expect(pressed.scale, LingyunPopoverMotion.pressedScale);
      expect(pressed.duration, Duration.zero);
      await gesture.up();
      await tester.pump();
    });
  });

  testWidgets('route backdrop is sampled by the Regular Medium plate', (
    tester,
  ) async {
    const size = Size(480, 420);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('popover-blur-probe'),
        child: _app(
          home: Builder(
            builder: (context) {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Builder(
                    builder: (anchorContext) {
                      return GlassButton.label(
                        label: '打开',
                        onPressed: () {
                          showLingyunPopover<void>(
                            context,
                            anchorContext: anchorContext,
                            backdrop: (context, metrics) {
                              return const Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ColoredBox(color: Color(0xFF101010)),
                                  ),
                                  Expanded(
                                    child: ColoredBox(color: Color(0xFFF4F4F6)),
                                  ),
                                ],
                              );
                            },
                            builder: (context) => const SizedBox(
                              height: 80,
                              width: double.infinity,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    final bytes = await _rgba(tester, const Key('popover-blur-probe'));
    final rect = tester.getRect(
      find.byKey(const Key('lingyun-popover-platter')),
    );
    final width = size.width.round();
    int red(int x, int y) => bytes[(y * width + x) * 4];
    final y = (rect.center.dy).round().clamp(1, size.height.round() - 2);
    final left = (rect.left + 28).round();
    final right = (rect.right - 28).round();
    expect((red(left, y) - red(right, y)).abs(), greaterThan(12));
  });
}

double _scale(WidgetTester tester) {
  return tester
      .widget<ScaleTransition>(find.byKey(const Key('lingyun-popover-scale')))
      .scale
      .value;
}

/// Doc comments name the APIs this file refuses to call. The hygiene
/// check looks at the remaining source.
String _withoutComments(String source) {
  final block = RegExp(r'/\*[\s\S]*?\*/');
  final line = RegExp(r'//.*');
  return source.replaceAll(block, '').replaceAll(line, '');
}

/// Enter / exit must not fade the platter. Page routes and the press veil
/// use their own fades and are outside this walk.
bool _platterFadesIn(WidgetTester tester) {
  final platter = tester.element(
    find.byKey(const Key('lingyun-popover-platter')),
  );
  var fades = false;
  platter.visitAncestorElements((ancestor) {
    if (ancestor.widget.key == const Key('lingyun-popover-scale')) {
      return false;
    }
    if (ancestor.widget is FadeTransition) {
      fades = true;
    }
    return true;
  });
  return fades;
}

AnimatedScale _actionScale(WidgetTester tester) {
  return tester.widget<AnimatedScale>(
    find.descendant(
      of: find.byKey(const Key('popover-action')),
      matching: find.byType(AnimatedScale),
    ),
  );
}

Future<void> _pumpAnchor(
  WidgetTester tester, {
  required Alignment alignment,
  bool reduceMotion = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(800, 600);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    _app(
      reduceMotion: reduceMotion,
      home: _AnchorHost(alignment: alignment),
    ),
  );
  await tester.pumpAndSettle();
}

class _AnchorHost extends StatefulWidget {
  const _AnchorHost({required this.alignment});

  final Alignment alignment;

  @override
  State<_AnchorHost> createState() => _AnchorHostState();
}

class _AnchorHostState extends State<_AnchorHost> {
  String _result = '尚未';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: widget.alignment,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Builder(
              builder: (anchorContext) {
                return GlassButton.label(
                  key: const Key('popover-anchor'),
                  label: '打开',
                  onPressed: () async {
                    final value = await showLingyunPopover<String>(
                      context,
                      anchorContext: anchorContext,
                      builder: (context) {
                        return LingyunPopoverAction(
                          key: const Key('popover-action'),
                          label: '查看详情',
                          onPressed: () => Navigator.pop(context, '查看详情'),
                        );
                      },
                    );
                    if (!mounted) return;
                    setState(() => _result = value ?? '已关闭');
                  },
                );
              },
            ),
          ),
        ),
        Align(alignment: Alignment.bottomLeft, child: Text(_result)),
      ],
    );
  }
}

Widget _app({required Widget home, bool reduceMotion = false}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: LingyunMaterialTheme.themeData(Brightness.light)
        .copyWith(extensions: const [LiquidGlassTheme.light]),
    home: LingyunAdaptivity(reduceMotion: reduceMotion, child: home),
  );
}

Future<List<int>> _rgba(WidgetTester tester, Key key) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List();
  });
  return bytes!;
}
