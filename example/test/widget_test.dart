import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('gallery boots on Materials', (tester) async {
    await tester.pumpWidget(const LingyunGlassDemoApp());
    expect(find.text('Materials'), findsWidgets);
    expect(find.byKey(const Key('materials-title')), findsOneWidget);
    expect(find.byKey(const Key('material-thin')), findsOneWidget);
    expect(find.byKey(const Key('material-regular')), findsOneWidget);
    expect(find.byKey(const Key('material-thick')), findsOneWidget);
  });

  testWidgets('gallery can open Layout and Accessibility', (tester) async {
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await tester.tap(find.text('Layout').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('layout-title')), findsOneWidget);
    expect(find.byKey(const Key('preset-duoInner')), findsOneWidget);

    await tester.tap(find.text('Access').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('a11y-title')), findsOneWidget);
    expect(find.text('Reduce transparency'), findsOneWidget);
    expect(find.text('Reduce motion'), findsOneWidget);
  });
}
