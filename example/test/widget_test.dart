import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:example/wallpaper.dart';

void main() {
  testWidgets('gallery boots on Materials', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    expect(find.byKey(const Key('preset-duoInner')), findsOneWidget);

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

  test('unknown bg query falls back to the design canvas', () {
    expect(GalleryBackground.fromQuery(null), GalleryBackground.canvas);
    expect(GalleryBackground.fromQuery('meadow'), GalleryBackground.meadow);
    expect(GalleryBackground.fromQuery('nope'), GalleryBackground.canvas);
    expect(GalleryCanvasColors.light, const Color(0xFFD1D1D6));
    expect(GalleryCanvasColors.dark, const Color(0xFF000000));
  });

  testWidgets('background control stays across tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
}
