import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:example/pages/native_page.dart';
import 'package:example/wallpaper.dart';

void main() {
  testWidgets('gallery boots on Materials', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    expect(find.text('Materials'), findsWidgets);
    expect(find.byKey(const Key('materials-title')), findsOneWidget);
    expect(find.byKey(const Key('material-ultrathin')), findsOneWidget);
    expect(find.byKey(const Key('material-thin')), findsOneWidget);
    expect(find.byKey(const Key('material-regular')), findsOneWidget);
    expect(find.byKey(const Key('material-thick')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('radius-large')), 200);
    expect(find.byKey(const Key('radius-small')), findsOneWidget);
    expect(find.byKey(const Key('radius-medium')), findsOneWidget);
    expect(find.byKey(const Key('radius-large')), findsOneWidget);
  });

  testWidgets('gallery can open Glass, Layout and Accessibility', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await tester.tap(find.text('Glass').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-default')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-pressed')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-disabled')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-clear')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-destructive')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-prominent')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-medium')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-large')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-symbol')), findsOneWidget);
    expect(
      find.byKey(const Key('glass-button-prominent-disabled')),
      findsOneWidget,
    );
    expect(find.text('Regular Small'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('glass-button-live')),
      200,
    );
    await tester.tap(find.byKey(const Key('glass-button-live')));
    await tester.pumpAndSettle();
    expect(find.text('Tapped 1'), findsOneWidget);

    await tester.tap(find.text('Layout').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('layout-title')), findsOneWidget);
    expect(find.byKey(const Key('preset-regular')), findsOneWidget);
    expect(find.byKey(const Key('layout-class-label')), findsOneWidget);
    expect(find.textContaining('regular · sidebar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('preset-compact')));
    await tester.pumpAndSettle();
    expect(find.textContaining('compact · tab'), findsOneWidget);

    await tester.tap(find.byKey(const Key('preset-wide')));
    await tester.pumpAndSettle();
    expect(find.textContaining('wide · sidebar'), findsOneWidget);

    await tester.tap(find.text('Tabs').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab-bar-title')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('tab-stage-tinted')),
      300,
    );
    expect(find.byKey(const Key('tab-stage-standard')), findsOneWidget);
    expect(find.byKey(const Key('tab-stage-floating-3')), findsOneWidget);
    expect(find.byKey(const Key('tab-stage-floating-4')), findsOneWidget);
    expect(find.byKey(const Key('tab-stage-floating-5')), findsOneWidget);
    expect(find.byKey(const Key('tab-stage-tinted')), findsOneWidget);
    expect(find.textContaining('System Blue'), findsWidgets);

    await tester.tap(find.text('Access').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('a11y-title')), findsOneWidget);
    expect(find.text('Reduce transparency'), findsOneWidget);
    expect(find.text('Reduce motion'), findsOneWidget);
  });

  testWidgets('native page lists compact and regular skeletons', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NativePage())),
    );
    expect(find.byKey(const Key('native-page-title')), findsOneWidget);
    expect(find.byKey(const Key('native-page-compact-note')), findsOneWidget);
    expect(find.byKey(const Key('native-page-regular-note')), findsOneWidget);
    expect(find.byKey(const Key('native-page-placeholder')), findsOneWidget);
    expect(find.byKey(const Key('native-page-host')), findsOneWidget);

    final arrangement = find.byKey(
      const Key('native-navigation-arrangementSplit'),
    );
    await tester.ensureVisible(arrangement);
    await tester.tap(arrangement);
    await tester.pump();
    expect(find.textContaining('ArrangementView'), findsWidgets);
  });

  test('unknown bg query falls back to the design canvas', () {
    expect(GalleryBackground.fromQuery(null), GalleryBackground.canvas);
    expect(GalleryBackground.fromQuery('meadow'), GalleryBackground.meadow);
    expect(GalleryBackground.fromQuery('nope'), GalleryBackground.canvas);
    expect(GalleryCanvasColors.light, const Color(0xFFD1D1D6));
    expect(GalleryCanvasColors.dark, const Color(0xFF000000));
  });

  testWidgets('background control stays across tabs', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());

    expect(find.byKey(const Key('gallery-bg-control')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-canvas')), findsOneWidget);
    final canvas = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byKey(const Key('gallery-bg-canvas')),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(canvas.color, GalleryCanvasColors.light);

    await tester.tap(find.byKey(const Key('gallery-bg-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('gallery-bg-option-meadow')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gallery-bg-meadow')), findsOneWidget);

    await tester.tap(find.text('Glass').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-meadow')), findsOneWidget);

    await tester.tap(find.text('Tabs').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab-bar-title')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-meadow')), findsWidgets);
  });

  testWidgets('alerts page shows system dialog states', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await tester.tap(find.text('提示').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('alert-title')), findsOneWidget);
    expect(find.text('提示'), findsWidgets);
    expect(find.byKey(const Key('alert-stage-single')), findsOneWidget);
    expect(find.byKey(const Key('alert-stage-dual')), findsOneWidget);
    expect(find.byKey(const Key('alert-stage-destructive')), findsOneWidget);
    expect(find.byKey(const Key('alert-stage-title-message')), findsOneWidget);
    expect(find.byKey(const Key('alert-stage-message-only')), findsOneWidget);

    final dual = find.byKey(const Key('alert-stage-dual'));
    final cancel = find.descendant(of: dual, matching: find.text('取消'));
    final confirm = find.descendant(of: dual, matching: find.text('确认'));
    expect(tester.getRect(cancel).left, lessThan(tester.getRect(confirm).left));

    expect(find.textContaining('尚未弹出'), findsOneWidget);
    await tester.tap(find.byKey(const Key('alert-live-single')));
    await tester.pumpAndSettle();
    expect(find.text('已保存'), findsWidgets);
    await tester.tap(find.text('好').last);
    await tester.pumpAndSettle();
    expect(find.text('实时路由 · 上次结果：好'), findsOneWidget);
  });
}
