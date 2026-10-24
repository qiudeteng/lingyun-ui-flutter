import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:example/pages/form_controls_page.dart';

/// Writes light and dark boards for toggles, sliders, and steppers.
///
/// Run from `example/`:
/// `flutter test tool/capture_form_control_screenshots.dart`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture toggle, slider, and stepper boards', (tester) async {
    await _capture(
      tester,
      brightness: Brightness.light,
      panel: FormControlPanel.toggles,
      path: '../docs/screenshots/form_controls_toggles_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      panel: FormControlPanel.toggles,
      path: '../docs/screenshots/form_controls_toggles_dark.png',
    );
    await _capture(
      tester,
      brightness: Brightness.light,
      panel: FormControlPanel.sliders,
      path: '../docs/screenshots/form_controls_sliders_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      panel: FormControlPanel.sliders,
      path: '../docs/screenshots/form_controls_sliders_dark.png',
    );
    await _capture(
      tester,
      brightness: Brightness.light,
      panel: FormControlPanel.steppers,
      path: '../docs/screenshots/form_controls_steppers_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      panel: FormControlPanel.steppers,
      path: '../docs/screenshots/form_controls_steppers_dark.png',
    );
  });
}

Future<void> _capture(
  WidgetTester tester, {
  required Brightness brightness,
  required FormControlPanel panel,
  required String path,
}) async {
  const height = 1500.0;
  await tester.binding.setSurfaceSize(const Size(1280, height));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final canvas = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFD1D1D6);
  final mode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('form-controls-shot'),
      child: ColoredBox(
        color: canvas,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          home: FormControlsPage(
            themeMode: mode,
            onThemeModeChanged: (_) {},
            initialPanel: panel,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('form-controls-notes')), findsOneWidget);
  expect(
    tester.getRect(find.byKey(const Key('form-controls-notes'))).bottom,
    lessThan(height),
  );

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('form-controls-shot')),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path).writeAsBytesSync(bytes!);
}
