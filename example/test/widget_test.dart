import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

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
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await tester.tap(find.text('Glass').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-default')), findsOneWidget);
    expect(find.text('Regular Small'), findsWidgets);

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
}
