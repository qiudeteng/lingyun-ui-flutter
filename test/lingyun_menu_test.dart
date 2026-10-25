import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LingyunMenuPlacement', () {
    test('prefers below the anchor, aligned to its leading edge', () {
      final placed = LingyunMenuPlacement.resolve(
        bounds: const Size(390, 844),
        safe: const EdgeInsets.only(top: 47, bottom: 34),
        anchor: const Rect.fromLTWH(40, 200, 80, 34),
        menu: const Size(250, 180),
        direction: TextDirection.ltr,
      );
      expect(placed.above, isFalse);
      expect(placed.rect, const Rect.fromLTWH(40, 254, 250, 180));
    });

    test('flips above when the bubble would leave the safe area', () {
      final placed = LingyunMenuPlacement.resolve(
        bounds: const Size(390, 844),
        safe: const EdgeInsets.only(top: 47, bottom: 34),
        anchor: const Rect.fromLTWH(40, 700, 80, 34),
        menu: const Size(250, 180),
        direction: TextDirection.ltr,
      );
      expect(placed.above, isTrue);
      expect(placed.rect.top, 500);
      expect(placed.rect.left, 40);
      expect(placed.rect.size, const Size(250, 180));
    });

    test('rtl aligns the trailing edge and clamps into the margin', () {
      final placed = LingyunMenuPlacement.resolve(
        bounds: const Size(390, 844),
        safe: const EdgeInsets.only(top: 47, bottom: 34),
        anchor: const Rect.fromLTWH(40, 200, 80, 34),
        menu: const Size(250, 180),
        direction: TextDirection.rtl,
      );
      expect(placed.rect.left, 20);
      expect(placed.rect.width, 250);
    });
  });

  test('menu sources stay on cupertino_ui and Liquid Glass', () {
    final library = File('lib/src/widgets/lingyun_menu.dart')
        .readAsStringSync();
    final gallery = File('example/lib/pages/menus_page.dart')
        .readAsStringSync();
    expect(library.contains('LiquidGlassStyle.regularLarge'), isTrue);
    expect(library.contains('MaterialTier'), isFalse);
    expect(library.contains('CupertinoContextMenu'), isFalse);
    expect(library.contains('CupertinoActionSheet'), isFalse);
    expect(library.contains('showCupertinoModalPopup'), isFalse);
    expect(library.contains('522.35'), isFalse);
    expect(library.contains('SpringDescription'), isFalse);
    for (final source in [library, gallery]) {
      final imports = source
          .split('\n')
          .where((line) => line.startsWith('import '))
          .toList();
      expect(
        imports.any(
          (line) =>
              line.contains('package:flutter/cupertino.dart') ||
              line.contains('package:flutter/material.dart'),
        ),
        isFalse,
      );
      expect(source.contains('CompatibilityBridge'), isFalse);
    }
    expect(gallery.contains('菜单'), isTrue);
    expect(gallery.contains('打开菜单'), isTrue);
    expect(gallery.contains('浅色'), isTrue);
    expect(gallery.contains('深色'), isTrue);
    expect(gallery.contains('Regular Large'), isTrue);
  });

  group('LingyunMenu platter', () {
    testWidgets('resting bubble is Regular Large, not a Materials tier', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const LingyunMenu(sections: _sections)));
      expect(find.text('拷贝'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
      expect(find.byKey(const Key('lingyun-menu-check-1')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-menu-chevron-2')), findsOneWidget);
      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.style, LiquidGlassStyle.regularLarge);
      expect(surface.material, isNull);
      expect(surface.tokens, isNull);
      final destructive = tester.widget<Text>(find.text('删除'));
      expect(destructive.style?.color, LingyunColors.light.system.red);
      final disabled = tester.widget<Text>(find.text('转发'));
      expect(
        disabled.style?.color,
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
    });

    testWidgets('pinned press flexes to the glass-button scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const LingyunMenu(forcePressedIndex: 0, sections: _sections)),
      );
      final row = find.byKey(const Key('lingyun-menu-action-0'));
      final scale = tester.widget<AnimatedScale>(
        find.descendant(of: row, matching: find.byType(AnimatedScale)),
      );
      expect(scale.scale, 0.97);
      expect(find.byKey(const Key('lingyun-menu-row-pressed')), findsOneWidget);
    });

    testWidgets('reduce motion keeps the pressed row at scale 1', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LingyunMenu(forcePressedIndex: 0, sections: _sections),
          reduceMotion: true,
        ),
      );
      final row = find.byKey(const Key('lingyun-menu-action-0'));
      final scale = tester.widget<AnimatedScale>(
        find.descendant(of: row, matching: find.byType(AnimatedScale)),
      );
      expect(scale.scale, 1);
      expect(find.byKey(const Key('lingyun-menu-row-pressed')), findsOneWidget);
    });
  });

  group('showLingyunMenu gestures', () {
    testWidgets('弹出 grows the bubble, 收起 shrinks it', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      LingyunMenuResult? result;
      var closed = false;
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassButton(
              key: const Key('open-menu'),
              onPressed: () {},
              child: Builder(
                builder: (context) {
                  return GestureDetector(
                    key: const Key('open-menu-hit'),
                    onTap: () async {
                      result = await showLingyunMenu(
                        context,
                        anchor: lingyunMenuAnchorOf(context),
                        backLabel: '返回',
                        barrierLabel: '关闭菜单',
                        sections: _sections,
                      );
                      closed = true;
                    },
                    child: const Text('打开'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('open-menu-hit')));
      await _untilPanel(tester);
      final opening = tester.getSize(
        find.byKey(const Key('lingyun-menu-panel')),
      );
      await tester.pump(const Duration(milliseconds: 32));
      final growing = tester.getSize(
        find.byKey(const Key('lingyun-menu-panel')),
      );
      expect(growing.height, greaterThan(opening.height + 4));
      await tester.pumpAndSettle();
      final open = tester.getSize(find.byKey(const Key('lingyun-menu-panel')));
      expect(open.height, greaterThan(opening.height + 20));
      expect(
        find.descendant(
          of: find.byKey(const Key('lingyun-menu-panel')),
          matching: find.text('拷贝'),
        ),
        findsOneWidget,
      );

      final row = find.byKey(const Key('lingyun-menu-action-0'));
      final gesture = await tester.startGesture(tester.getCenter(row));
      await tester.pump();
      expect(find.byKey(const Key('lingyun-menu-row-pressed')), findsWidgets);
      final pressed = tester.widget<AnimatedScale>(
        find.descendant(of: row, matching: find.byType(AnimatedScale)),
      );
      expect(pressed.scale, 0.97);
      await gesture.cancel();
      await tester.pump();

      expect(
        tester
            .getRect(find.byKey(const Key('lingyun-menu-panel')))
            .contains(const Offset(8, 8)),
        isFalse,
      );
      await tester.tapAt(const Offset(8, 8));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      final closing = tester.getSize(
        find.byKey(const Key('lingyun-menu-panel')),
      );
      expect(closing.height, lessThan(open.height - 4));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lingyun-menu-panel')), findsNothing);
      expect(closed, isTrue);
      expect(result, isNull);
    });

    testWidgets('reduce motion snaps open and does not flex a row', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassButton(
              key: const Key('open-menu'),
              onPressed: () {},
              child: Builder(
                builder: (context) {
                  return GestureDetector(
                    key: const Key('open-menu-hit'),
                    onTap: () {
                      showLingyunMenu(
                        context,
                        anchor: lingyunMenuAnchorOf(context),
                        sections: _sections,
                      );
                    },
                    child: const Text('打开'),
                  );
                },
              ),
            ),
          ),
          reduceMotion: true,
        ),
      );
      await tester.tap(find.byKey(const Key('open-menu-hit')));
      await _untilPanel(tester);
      final snapped = tester.getSize(
        find.byKey(const Key('lingyun-menu-panel')),
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('lingyun-menu-panel')),
          matching: find.text('拷贝'),
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        tester.getSize(find.byKey(const Key('lingyun-menu-panel'))),
        snapped,
      );

      final row = find.byKey(const Key('lingyun-menu-action-0'));
      final gesture = await tester.startGesture(tester.getCenter(row));
      await tester.pump();
      final scale = tester.widget<AnimatedScale>(
        find.descendant(of: row, matching: find.byType(AnimatedScale)),
      );
      expect(scale.scale, 1);
      expect(find.byKey(const Key('lingyun-menu-row-pressed')), findsWidgets);
      await gesture.cancel();
    });

    testWidgets('submenu returns to the parent, a leaf returns its path', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      LingyunMenuResult? result;
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassButton(
              key: const Key('open-menu'),
              onPressed: () {},
              child: Builder(
                builder: (context) {
                  return GestureDetector(
                    key: const Key('open-menu-hit'),
                    onTap: () async {
                      result = await showLingyunMenu(
                        context,
                        anchor: lingyunMenuAnchorOf(context),
                        backLabel: '返回',
                        sections: _sections,
                      );
                    },
                    child: const Text('打开'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('open-menu-hit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lingyun-menu-action-2')));
      await tester.pumpAndSettle();
      expect(find.text('拷贝链接'), findsWidgets);
      expect(find.byKey(const Key('lingyun-menu-back')), findsOneWidget);
      await tester.tap(find.byKey(const Key('lingyun-menu-back')));
      await tester.pumpAndSettle();
      expect(find.text('更多'), findsWidgets);
      await tester.tap(find.byKey(const Key('lingyun-menu-action-4')));
      await tester.pumpAndSettle();
      expect(result, const LingyunMenuResult([4]));
    });
  });
}

const _sections = <LingyunMenuSection>[
  LingyunMenuSection(
    actions: [
      LingyunMenuAction(label: '拷贝'),
      LingyunMenuAction(label: '名称', selected: true),
      LingyunMenuAction(
        label: '更多',
        children: [LingyunMenuAction(label: '拷贝链接')],
      ),
    ],
  ),
  LingyunMenuSection(
    actions: [
      LingyunMenuAction(label: '转发', enabled: false),
      LingyunMenuAction.destructive(label: '删除'),
    ],
  ),
];

Future<void> _untilPanel(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    if (find.byKey(const Key('lingyun-menu-panel')).evaluate().isNotEmpty) {
      return;
    }
    await tester.pump();
  }
  fail('menu panel did not appear');
}

Widget _host(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: Brightness.light,
      extensions: const [LiquidGlassTheme.light],
    ),
    home: LingyunAdaptivity(
      reduceMotion: reduceMotion,
      child: LingyunTheme(brightness: Brightness.light, child: child),
    ),
  );
}
