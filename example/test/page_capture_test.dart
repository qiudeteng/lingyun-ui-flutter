import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/pages/layout_page.dart';
import 'package:example/wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Writes Layout-page screenshots when `PAGE_CAPTURE=1`.
///
/// From `example/`:
///
/// ```bash
/// PAGE_CAPTURE=1 flutter test test/page_capture_test.dart
/// ```
///
/// PowerShell: `$env:PAGE_CAPTURE='1'; flutter test test/page_capture_test.dart`
///
/// cmd: `set PAGE_CAPTURE=1&& flutter test test/page_capture_test.dart`
void main() {
  final capture = Platform.environment['PAGE_CAPTURE'] == '1';

  testWidgets('write LingyunPage layout screenshots', (tester) async {
    const presets = [
      LayoutPreset.compact,
      LayoutPreset.regular,
      LayoutPreset.wide,
    ];
    for (final preset in presets) {
      for (final dark in [false, true]) {
        final name = 'page_${preset.name}_${dark ? 'dark' : 'light'}.png';
        await _capture(tester, preset: preset, dark: dark, fileName: name);
      }
    }
  }, skip: !capture);
}

Future<void> _capture(
  WidgetTester tester, {
  required LayoutPreset preset,
  required bool dark,
  required String fileName,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1100, 820);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final glass = dark ? LiquidGlassTheme.dark : LiquidGlassTheme.light;
  final theme = (dark ? ThemeData.dark() : ThemeData.light()).copyWith(
    extensions: [glass],
  );
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: GalleryBackgroundScope(
        mode: GalleryBackground.canvas,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: RepaintBoundary(
            key: const Key('page-capture'),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const SystemWallpaper(),
                LayoutPage(initialPreset: preset),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('page-capture')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('../docs/screenshots/$fileName');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  });
}
