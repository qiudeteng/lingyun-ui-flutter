import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/pages/action_sheets_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Writes the light and dark Action Sheets gallery boards.
///
/// Run from `example/`: `flutter test tool/capture_action_sheet_screenshots.dart`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture action sheet boards', (tester) async {
    await _capture(
      tester,
      brightness: Brightness.light,
      path: '../docs/screenshots/action_sheets_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      path: '../docs/screenshots/action_sheets_dark.png',
    );
  });
}

Future<void> _capture(
  WidgetTester tester, {
  required Brightness brightness,
  required String path,
}) async {
  await tester.binding.setSurfaceSize(const Size(1280, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final canvas = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFD1D1D6);

  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('action-sheet-shot'),
      child: ColoredBox(
        color: canvas,
        child: CupertinoApp(
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(brightness: brightness),
          home: ActionSheetsPage(brightness: brightness),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('action-sheet-shot')),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path).writeAsBytesSync(bytes!);
}
