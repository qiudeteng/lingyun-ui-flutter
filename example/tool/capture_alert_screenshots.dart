import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/pages/alerts_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Writes the light and dark Alerts gallery boards.
///
/// Run from `example/`: `flutter test tool/capture_alert_screenshots.dart`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture alert boards', (tester) async {
    await _capture(
      tester,
      brightness: Brightness.light,
      path: '../docs/screenshots/alerts_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      path: '../docs/screenshots/alerts_dark.png',
    );
  });
}

Future<void> _capture(
  WidgetTester tester, {
  required Brightness brightness,
  required String path,
}) async {
  await tester.binding.setSurfaceSize(const Size(1280, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final canvas = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFD1D1D6);

  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('alert-shot'),
      child: ColoredBox(
        color: canvas,
        child: CupertinoApp(
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(brightness: brightness),
          home: AlertsPage(brightness: brightness),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('alert-shot')),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path).writeAsBytesSync(bytes!);
}
