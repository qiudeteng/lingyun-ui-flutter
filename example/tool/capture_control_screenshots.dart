import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:example/pages/controls_page.dart';

/// Writes the light and dark knob / track gallery boards.
///
/// Run from `example/`: `flutter test tool/capture_control_screenshots.dart`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture knob and track boards', (tester) async {
    await _capture(
      tester,
      brightness: Brightness.light,
      path: '../docs/screenshots/controls_knob_track_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      path: '../docs/screenshots/controls_knob_track_dark.png',
    );
  });
}

Future<void> _capture(
  WidgetTester tester, {
  required Brightness brightness,
  required String path,
}) async {
  await tester.binding.setSurfaceSize(const Size(1280, 1160));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final canvas = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFD1D1D6);
  final mode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('controls-shot'),
      child: ColoredBox(
        color: canvas,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          home: ControlsPage(themeMode: mode, onThemeModeChanged: (_) {}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('controls-shot')),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path).writeAsBytesSync(bytes!);
}
