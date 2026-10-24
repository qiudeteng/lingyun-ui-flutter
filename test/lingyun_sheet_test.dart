import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
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
      final library = File(
        'lib/src/widgets/lingyun_sheet.dart',
      ).readAsStringSync();
      final gallery = File(
        'example/lib/pages/sheets_page.dart',
      ).readAsStringSync();
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

Widget _app({required Widget home, Brightness brightness = Brightness.light}) {
  final glass = brightness == Brightness.dark
      ? LiquidGlassTheme.dark
      : LiquidGlassTheme.light;
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: LingyunMaterialTheme.themeData(
      brightness,
    ).copyWith(extensions: [glass]),
    home: home,
  );
}
