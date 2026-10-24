import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/pages/layout_page.dart';
import 'package:example/wallpaper.dart';
import 'package:material_ui/material_ui.dart';
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
///
/// Each shot is the page stage at that bucket's size, plus a canvas margin
/// so the design canvas is the image corner (`#D1D1D6` / `#000000`).
/// The gallery letterbox is not used: a shared 1100-wide view scales the
/// wide stage under 1200 and hides the rail.
void main() {
  final capture = Platform.environment['PAGE_CAPTURE'] == '1';

  testWidgets('stage fills its width bucket on the design canvas', (
    tester,
  ) async {
    for (final shot in _shots) {
      for (final dark in [false, true]) {
        await _pumpStage(tester, shot: shot, dark: dark);
        _expectBucket(shot.preset);
        _expectCanvasColor(tester, dark);
      }
    }
  });

  testWidgets('write LingyunPage layout screenshots', (tester) async {
    for (final shot in _shots) {
      for (final dark in [false, true]) {
        final name = 'page_${shot.preset.name}_${dark ? 'dark' : 'light'}.png';
        await _capture(tester, shot: shot, dark: dark, fileName: name);
      }
    }
  }, skip: !capture);
}

/// Page stage sizes. The image is this size plus [_canvasMargin] on each edge.
///
/// Compact is portrait. Regular is a landscape split under 1200. Wide is at
/// least 1200 so the three-column container is the wide bucket.
const _shots = <_Shot>[
  _Shot(LayoutPreset.compact, Size(390, 844)),
  _Shot(LayoutPreset.regular, Size(1024, 768)),
  _Shot(LayoutPreset.wide, Size(1440, 900)),
];

const _canvasMargin = 24.0;

class _Shot {
  const _Shot(this.preset, this.pageSize);

  final LayoutPreset preset;
  final Size pageSize;

  Size get view => Size(
    pageSize.width + _canvasMargin * 2,
    pageSize.height + _canvasMargin * 2,
  );
}

Future<void> _pumpStage(
  WidgetTester tester, {
  required _Shot shot,
  required bool dark,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = shot.view;
  tester.platformDispatcher.platformBrightnessTestValue = dark
      ? Brightness.dark
      : Brightness.light;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration.zero,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF6B7C93),
        extensions: const [LiquidGlassTheme.light],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6B7C93),
        extensions: const [LiquidGlassTheme.dark],
      ),
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
                Padding(
                  padding: const EdgeInsets.all(_canvasMargin),
                  child: LayoutPage(
                    initialPreset: shot.preset,
                    stageOnly: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void _expectBucket(LayoutPreset preset) {
  expect(find.byKey(const Key('layout-class-label')), findsOneWidget);
  switch (preset) {
    case LayoutPreset.compact:
      expect(find.textContaining('compact · tab'), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-tab-bar')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-sidebar')), findsNothing);
      expect(find.byKey(const Key('lingyun-page-secondary')), findsNothing);
    case LayoutPreset.regular:
      expect(find.textContaining('regular · sidebar'), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-sidebar')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-primary')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-tab-bar')), findsNothing);
      expect(find.byKey(const Key('lingyun-page-secondary')), findsNothing);
    case LayoutPreset.wide:
      expect(find.textContaining('wide · sidebar'), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-sidebar')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-secondary')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-primary')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-tab-bar')), findsNothing);
    default:
      fail('screenshot preset $preset is not a width bucket');
  }
}

void _expectCanvasColor(WidgetTester tester, bool dark) {
  final canvas = tester.widget<ColoredBox>(
    find.descendant(
      of: find.byKey(const Key('gallery-bg-canvas')),
      matching: find.byType(ColoredBox),
    ),
  );
  expect(
    canvas.color,
    dark ? GalleryCanvasColors.dark : GalleryCanvasColors.light,
  );
  expect(
    Theme.of(tester.element(find.byType(SystemWallpaper))).brightness,
    dark ? Brightness.dark : Brightness.light,
  );
}

Future<void> _capture(
  WidgetTester tester, {
  required _Shot shot,
  required bool dark,
  required String fileName,
}) async {
  await _pumpStage(tester, shot: shot, dark: dark);
  _expectBucket(shot.preset);
  _expectCanvasColor(tester, dark);

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('page-capture')),
  );
  final view = shot.view;
  expect(boundary.size.width, view.width);
  expect(boundary.size.height, view.height);
  expect(
    view.width,
    greaterThanOrEqualTo(shot.preset == LayoutPreset.wide ? 1200 : 0),
  );

  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    expect(image.width, view.width.round());
    expect(image.height, view.height.round());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(_screenshotPath(fileName));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  });
}

String _screenshotPath(String fileName) {
  final current = Directory.current.path.replaceAll('\\', '/');
  final root = current.endsWith('/example')
      ? Directory.current.parent
      : Directory.current;
  return '${root.path}/docs/screenshots/$fileName';
}
