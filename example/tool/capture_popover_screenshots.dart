import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/pages/popovers_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Writes the light and dark Popovers gallery boards.
///
/// Run from `example/`:
///
/// ```bash
/// flutter test tool/capture_popover_screenshots.dart
/// ```
///
/// ```powershell
/// flutter test tool/capture_popover_screenshots.dart
/// ```
///
/// The plate is Liquid Glass Regular Medium. That choice is non-binding
/// (待核验). Light board is the `#D1D1D6` canvas; dark is `#000000`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture popover boards', (tester) async {
    await _capture(
      tester,
      brightness: Brightness.light,
      path: '../docs/screenshots/popovers_light.png',
    );
    await _capture(
      tester,
      brightness: Brightness.dark,
      path: '../docs/screenshots/popovers_dark.png',
    );
  });
}

Future<void> _capture(
  WidgetTester tester, {
  required Brightness brightness,
  required String path,
}) async {
  await tester.binding.setSurfaceSize(const Size(1440, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final glass = brightness == Brightness.dark
      ? LiquidGlassTheme.dark
      : LiquidGlassTheme.light;
  final canvas = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFD1D1D6);

  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('popover-shot'),
      child: ColoredBox(
        color: canvas,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: LingyunMaterialTheme.themeData(brightness)
              .copyWith(extensions: [glass]),
          home: PopoversPage(brightness: brightness),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('popover-shot')),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path).writeAsBytesSync(bytes!);
}
