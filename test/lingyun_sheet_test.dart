import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LingyunSheetMetrics', () {
    test('compact phone is full width with a half-height medium stop', () {
      const safe = EdgeInsets.only(top: 54, bottom: 34);
      const metrics = LingyunSheetMetrics(
        bounds: Size(390, 844),
        safeArea: safe,
        keyboardInset: 0,
      );
      expect(metrics.bucket, LingyunPageWidthBucket.compact);
      expect(metrics.attachedToBottom, isTrue);
      expect(metrics.width, 390);
      expect(metrics.left, 0);
      expect(metrics.bottomOffset, 0);
      final top = 844 * LingyunSheetLayout.largeTopGapFraction;
      expect(metrics.topInset, greaterThan(54));
      expect(metrics.topInset, top);
      expect(
        metrics.heightFor(LingyunSheetDetent.medium),
        844 * LingyunSheetLayout.mediumFraction,
      );
      expect(metrics.heightFor(LingyunSheetDetent.large), 844 - top);
      expect(
        metrics.heightFor(LingyunSheetDetent.medium),
        lessThan(metrics.heightFor(LingyunSheetDetent.large)),
      );
      expect(
        metrics.borderRadius,
        LingyunSheetLayout.borderRadius(attachedToBottom: true),
      );
    });

    test('an explicit compact class stays full bleed on a wide canvas', () {
      const metrics = LingyunSheetMetrics(
        bounds: Size(1400, 900),
        safeArea: EdgeInsets.zero,
        keyboardInset: 0,
        horizontalSizeClass: 'compact',
      );
      expect(metrics.bucket, LingyunPageWidthBucket.compact);
      expect(metrics.width, 1400);
      expect(metrics.attachedToBottom, isTrue);
    });

    test('regular and wide sheets are inset and capped', () {
      const regular = LingyunSheetMetrics(
        bounds: Size(800, 700),
        safeArea: EdgeInsets.zero,
        keyboardInset: 0,
      );
      expect(regular.bucket, LingyunPageWidthBucket.regular);
      expect(regular.attachedToBottom, isFalse);
      expect(regular.width, lessThan(800));
      expect(
        regular.width,
        lessThanOrEqualTo(LingyunSheetLayout.regularMaxWidth),
      );
      expect(regular.left, greaterThan(0));
      expect(regular.bottomOffset, LingyunSheetLayout.regularBottomGap);

      const wide = LingyunSheetMetrics(
        bounds: Size(1440, 900),
        safeArea: EdgeInsets.zero,
        keyboardInset: 0,
      );
      expect(wide.bucket, LingyunPageWidthBucket.wide);
      expect(wide.width, LingyunSheetLayout.regularMaxWidth);
      expect(wide.left, (1440 - LingyunSheetLayout.regularMaxWidth) / 2);
      expect(
        wide.borderRadius,
        LingyunSheetLayout.borderRadius(attachedToBottom: false),
      );
    });

    test('keyboard lifts the bottom and shortens both stops', () {
      const resting = LingyunSheetMetrics(
        bounds: Size(390, 844),
        safeArea: EdgeInsets.only(top: 54),
        keyboardInset: 0,
      );
      const lifted = LingyunSheetMetrics(
        bounds: Size(390, 844),
        safeArea: EdgeInsets.only(top: 54),
        keyboardInset: 300,
      );
      expect(lifted.bottomOffset, 300);
      expect(lifted.stageHeight, 544);
      final top = 54 > 544 * LingyunSheetLayout.largeTopGapFraction
          ? 54.0
          : 544 * LingyunSheetLayout.largeTopGapFraction;
      expect(lifted.topInset, top);
      expect(lifted.heightFor(LingyunSheetDetent.large), 844 - 300 - top);
      expect(
        lifted.heightFor(LingyunSheetDetent.medium),
        lessThanOrEqualTo(lifted.heightFor(LingyunSheetDetent.large)),
      );
      expect(
        lifted.heightFor(LingyunSheetDetent.large),
        lessThan(resting.heightFor(LingyunSheetDetent.large)),
      );
    });
  });

  test(
    'sheet sources stay on the independent packages and Materials Thick',
    () {
      final library = File('lib/src/widgets/lingyun_sheet.dart')
          .readAsStringSync();
      final gallery = File('example/lib/pages/sheets_page.dart')
          .readAsStringSync();
      expect(library.contains('MaterialTier.thick'), isTrue);
      final glassStart = library.indexOf('return GlassSurface(');
      final glassEnd = library.indexOf('child:', glassStart);
      final glassCall = library.substring(glassStart, glassEnd);
      expect(glassCall.contains('style:'), isFalse);
      expect(glassCall.contains('tokens:'), isFalse);
      expect(library.contains('LiquidGlassStyle'), isFalse);
      expect(library.contains('GlassButton'), isFalse);
      expect(library.contains('GlassTabBar'), isFalse);
      expect(library.contains('UIScreen'), isFalse);
      expect(
        library.contains('package:cupertino_ui/cupertino_ui.dart'),
        isTrue,
      );
      expect(library.contains('package:material_ui/material_ui.dart'), isTrue);
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
      }
      expect(gallery.contains('工作表'), isTrue);
      expect(gallery.contains('浅色'), isTrue);
      expect(gallery.contains('深色'), isTrue);
      expect(gallery.contains('Materials Thick'), isTrue);
      expect(gallery.contains('GlassButton'), isFalse);
      expect(gallery.contains('LiquidGlassStyle'), isFalse);
    },
  );

  group('showLingyunSheet', () {
    testWidgets('platter is Materials Thick and shows the grabber', (
      tester,
    ) async {
      await _open(tester, size: const Size(390, 844));
      expect(find.text('编辑项目'), findsOneWidget);
      expect(find.byKey(const Key('lingyun-sheet-grabber')), findsOneWidget);
      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.material, MaterialTier.thick);
      expect(surface.style, isNull);
      expect(surface.tokens, isNull);
      expect(surface.enableHoverHighlight, isFalse);
      expect(
        surface.borderRadius,
        LingyunSheetLayout.borderRadius(attachedToBottom: true),
      );
      final rect = tester.getRect(
        find.byKey(const Key('lingyun-sheet-platter')),
      );
      const metrics = LingyunSheetMetrics(
        bounds: Size(390, 844),
        safeArea: EdgeInsets.zero,
        keyboardInset: 0,
      );
      expect(rect.width, closeTo(metrics.width, 1));
      expect(rect.bottom, closeTo(844 - metrics.bottomOffset, 1));
      expect(
        rect.height,
        closeTo(metrics.heightFor(LingyunSheetDetent.medium), 1),
      );
    });

    testWidgets('wide bounds inset the card', (tester) async {
      await _open(tester, size: const Size(1200, 800));
      final rect = tester.getRect(
        find.byKey(const Key('lingyun-sheet-platter')),
      );
      const metrics = LingyunSheetMetrics(
        bounds: Size(1200, 800),
        safeArea: EdgeInsets.zero,
        keyboardInset: 0,
      );
      expect(metrics.bucket, LingyunPageWidthBucket.wide);
      expect(rect.width, closeTo(metrics.width, 1));
      expect(rect.left, closeTo(metrics.left, 1));
      expect(rect.width, lessThan(1200));
      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.material, MaterialTier.thick);
      expect(
        surface.borderRadius,
        LingyunSheetLayout.borderRadius(attachedToBottom: false),
      );
    });

    testWidgets('explicit compact class ignores a wide window', (tester) async {
      await _open(
        tester,
        size: const Size(1200, 800),
        horizontalSizeClass: 'compact',
      );
      final rect = tester.getRect(
        find.byKey(const Key('lingyun-sheet-platter')),
      );
      expect(rect.width, closeTo(1200, 1));
      expect(rect.left, closeTo(0, 1));
    });

    testWidgets('keyboard inset lifts the bottom edge', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        _app(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              viewInsets: EdgeInsets.only(bottom: 280),
            ),
            child: SizedBox.expand(
              child: Navigator(
                onGenerateRoute: (settings) {
                  return CupertinoPageRoute<void>(
                    builder: (context) {
                      return CupertinoButton(
                        onPressed: () {
                          showLingyunSheet<void>(
                            context,
                            useRootNavigator: false,
                            builder: (context, controller) =>
                                const Text('编辑项目'),
                          );
                        },
                        child: const Text('打开'),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      final rect = tester.getRect(
        find.byKey(const Key('lingyun-sheet-platter')),
      );
      const metrics = LingyunSheetMetrics(
        bounds: Size(390, 844),
        safeArea: EdgeInsets.zero,
        keyboardInset: 280,
      );
      expect(rect.bottom, closeTo(844 - metrics.bottomOffset, 1));
      expect(
        rect.height,
        closeTo(metrics.heightFor(LingyunSheetDetent.medium), 1),
      );
    });

    testWidgets('controller moves from medium to large', (tester) async {
      final controller = LingyunSheetController();
      await _open(tester, size: const Size(390, 844), controller: controller);
      final before = tester
          .getSize(find.byKey(const Key('lingyun-sheet-platter')))
          .height;
      controller.animateTo(LingyunSheetDetent.large);
      await tester.pumpAndSettle();
      final after = tester
          .getSize(find.byKey(const Key('lingyun-sheet-platter')))
          .height;
      expect(after, greaterThan(before));
      expect(controller.detent, LingyunSheetDetent.large);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('dragging the grabber up settles on the large stop', (
      tester,
    ) async {
      await _open(tester, size: const Size(390, 844));
      final before = tester
          .getSize(find.byKey(const Key('lingyun-sheet-platter')))
          .height;
      await tester.drag(
        find.byKey(const Key('lingyun-sheet-grabber')),
        const Offset(0, -420),
      );
      await tester.pumpAndSettle();
      final after = tester
          .getSize(find.byKey(const Key('lingyun-sheet-platter')))
          .height;
      expect(after, greaterThan(before + 200));
    });

    testWidgets('outside tap dismisses', (tester) async {
      await _open(tester, size: const Size(390, 844));
      expect(find.text('编辑项目'), findsOneWidget);
      await tester.tapAt(const Offset(40, 8));
      await tester.pumpAndSettle();
      expect(find.text('编辑项目'), findsNothing);
    });

    testWidgets('thick platter keeps black and white backdrop apart', (
      tester,
    ) async {
      final colors = await _samplePlatter(tester);
      expect(
        (colors.$1 - colors.$2).abs(),
        greaterThan(4),
        reason: 'Thick must sample the backdrop, not a flat fill',
      );
    });

    testWidgets('thick platter keeps the materials ramp apart', (tester) async {
      final colors = await _sampleRamp(tester);
      expect(
        (colors.$1 - colors.$2).abs(),
        greaterThan(8),
        reason:
            'Vertical materials bands must stay apart under Thick. '
            'A flat #F7 / #343436 means the blur averaged one color.',
      );
    });

    testWidgets('presented sheet samples stripes on the page below', (
      tester,
    ) async {
      final colors = await _sampleRoute(tester);
      expect(
        (colors.$1 - colors.$2).abs(),
        greaterThan(4),
        reason: 'The open sheet must sample the page, not an empty route layer',
      );
    });

    testWidgets('dark theme still resolves Materials Thick', (tester) async {
      await _open(
        tester,
        size: const Size(390, 844),
        brightness: Brightness.dark,
      );
      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.material, MaterialTier.thick);
      expect(surface.style, isNull);
      expect(find.text('编辑项目'), findsOneWidget);
    });
  });
}

Future<void> _open(
  WidgetTester tester, {
  required Size size,
  Brightness brightness = Brightness.light,
  LingyunSheetController? controller,
  String? horizontalSizeClass,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    _app(
      brightness: brightness,
      home: Builder(
        builder: (context) {
          return CupertinoButton(
            onPressed: () {
              showLingyunSheet<void>(
                context,
                controller: controller,
                horizontalSizeClass: horizontalSizeClass,
                builder: (context, sheetController) {
                  return const Text('编辑项目');
                },
              );
            },
            child: const Text('打开'),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
}

Future<(int, int)> _samplePlatter(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(320, 240);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('sheet-blur-probe'),
      child: _app(
        home: const Stack(
          fit: StackFit.expand,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: ColoredBox(color: Color(0xFF101010))),
                Expanded(child: ColoredBox(color: Color(0xFFF4F4F6))),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: LingyunSheet(
                showGrabber: false,
                attachedToBottom: false,
                child: SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('sheet-blur-probe')),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List();
  });
  final width = boundary.size.width.round();
  int red(int x, int y) => bytes![(y * width + x) * 4];
  return (red(60, 120), red(250, 120));
}

const List<Color> _materialBands = [
  Color(0xFF5C5C60),
  Color(0xFF7A7A7E),
  Color(0xFF9A9A9E),
  Color(0xFFB4B4B8),
  Color(0xFFC8C8CC),
  Color(0xFFD8D8DC),
  Color(0xFFE8E8EC),
  Color(0xFFF4F4F6),
];

Future<(int, int)> _sampleRamp(WidgetTester tester) async {
  const size = Size(320, 280);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('sheet-ramp-probe'),
      child: _app(
        home: const Stack(
          fit: StackFit.expand,
          children: [
            _BandField(),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: LingyunSheet(
                  showGrabber: false,
                  attachedToBottom: true,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  final bytes = await _rgba(tester, const Key('sheet-ramp-probe'));
  final width = size.width.round();
  int red(int x, int y) => bytes[(y * width + x) * 4];
  // y=200 sits inside the platter. x centers the darkest and lightest bands.
  return (red(20, 200), red(300, 200));
}

Future<(int, int)> _sampleRoute(WidgetTester tester) async {
  const size = Size(320, 280);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('sheet-route-probe'),
      child: _app(
        home: Builder(
          builder: (context) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const _BandField(),
                Align(
                  alignment: Alignment.topLeft,
                  child: CupertinoButton(
                    onPressed: () {
                      showLingyunSheet<void>(
                        context,
                        builder: (context, controller) =>
                            const SizedBox.shrink(),
                      );
                    },
                    child: const Text('打开'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
  final bytes = await _rgba(tester, const Key('sheet-route-probe'));
  final rect = tester.getRect(find.byKey(const Key('lingyun-sheet-platter')));
  final width = size.width.round();
  int red(int x, int y) => bytes[(y * width + x) * 4];
  final y = (rect.center.dy).round().clamp(0, size.height.round() - 1);
  return (red(20, y), red(300, y));
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

class _BandField extends StatelessWidget {
  const _BandField();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final color in _materialBands)
          Expanded(child: ColoredBox(color: color)),
      ],
    );
  }
}

Widget _app({required Widget home, Brightness brightness = Brightness.light}) {
  final glass = brightness == Brightness.dark
      ? LiquidGlassTheme.dark
      : LiquidGlassTheme.light;
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: LingyunMaterialTheme.themeData(brightness)
        .copyWith(extensions: [glass]),
    home: home,
  );
}
