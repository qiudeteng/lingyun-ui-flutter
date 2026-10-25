import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/pages/wave1c_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Writes light and dark boards for segmented controls and page controls.
///
/// Run from `example/`:
/// `flutter test tool/capture_wave1c_screenshots.dart`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture segmented and page control boards', (tester) async {
    await _capture(
      tester,
      brightness: Brightness.light,
      panel: Wave1cPanel.segmented,
      height: 1040,
      path: '../docs/screenshots/segmented_controls_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      panel: Wave1cPanel.segmented,
      height: 1040,
      path: '../docs/screenshots/segmented_controls_dark.png',
    );
    await _capture(
      tester,
      brightness: Brightness.light,
      panel: Wave1cPanel.pages,
      height: 760,
      path: '../docs/screenshots/page_controls_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      panel: Wave1cPanel.pages,
      height: 760,
      path: '../docs/screenshots/page_controls_dark.png',
    );
  });
}

Future<void> _capture(
  WidgetTester tester, {
  required Brightness brightness,
  required Wave1cPanel panel,
  required double height,
  required String path,
}) async {
  await tester.binding.setSurfaceSize(Size(1280, height));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final canvas = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFD1D1D6);
  final mode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  final glass = brightness == Brightness.dark
      ? LiquidGlassTheme.dark
      : LiquidGlassTheme.light;

  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('wave1c-shot'),
      child: ColoredBox(
        color: canvas,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            extensions: const [LiquidGlassTheme.light],
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            extensions: const [LiquidGlassTheme.dark],
          ),
          home: LingyunTheme(
            brightness: brightness,
            child: Theme(
              data: ThemeData(brightness: brightness, extensions: [glass]),
              child: Wave1cPage(
                themeMode: mode,
                onThemeModeChanged: (_) {},
                initialPanel: panel,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('wave1c-notes')), findsOneWidget);
  expect(
    tester.getRect(find.byKey(const Key('wave1c-notes'))).bottom,
    lessThan(height),
  );

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('wave1c-shot')),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path).writeAsBytesSync(bytes!);
}
