import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LingyunActionSheet.arrange', () {
    test('first cancel is separated and the rest keep caller order', () {
      final actions = <LingyunActionSheetAction>[
        const LingyunActionSheetAction.cancel(label: '取消'),
        const LingyunActionSheetAction.regular(label: '拷贝'),
        const LingyunActionSheetAction.confirm(label: '存储'),
        const LingyunActionSheetAction.destructive(label: '删除'),
      ];
      final arranged = LingyunActionSheet.arrange(actions);
      expect(arranged.cancelIndex, 0);
      expect(arranged.actionIndices, [1, 2, 3]);
    });

    test('cancel passed last is still the separated slot', () {
      final actions = <LingyunActionSheetAction>[
        const LingyunActionSheetAction.confirm(label: '确认'),
        const LingyunActionSheetAction.cancel(label: '取消'),
      ];
      final arranged = LingyunActionSheet.arrange(actions);
      expect(arranged.cancelIndex, 1);
      expect(arranged.actionIndices, [0]);
    });

    test('no cancel keeps caller order', () {
      final actions = <LingyunActionSheetAction>[
        const LingyunActionSheetAction.regular(label: '保留'),
        const LingyunActionSheetAction.destructive(label: '删除'),
      ];
      final arranged = LingyunActionSheet.arrange(actions);
      expect(arranged.cancelIndex, isNull);
      expect(arranged.actionIndices, [0, 1]);
    });

    test('a second cancel stays in the upper group', () {
      final actions = <LingyunActionSheetAction>[
        const LingyunActionSheetAction.cancel(label: '取消'),
        const LingyunActionSheetAction.regular(label: '拷贝'),
        const LingyunActionSheetAction.cancel(label: '关闭'),
      ];
      final arranged = LingyunActionSheet.arrange(actions);
      expect(arranged.cancelIndex, 0);
      expect(arranged.actionIndices, [1, 2]);
    });
  });

  group('LingyunActionSheetAction', () {
    test('styles map to Cupertino default and destructive flags', () {
      const regular = LingyunActionSheetAction.regular(label: '拷贝');
      const confirm = LingyunActionSheetAction.confirm(label: '存储');
      const destructive = LingyunActionSheetAction.destructive(label: '删除');
      const cancel = LingyunActionSheetAction.cancel(label: '取消');
      expect(regular.isDefaultAction, isFalse);
      expect(regular.isDestructiveAction, isFalse);
      expect(regular.style, LingyunActionSheetActionStyle.regular);
      expect(confirm.isDefaultAction, isTrue);
      expect(confirm.isDestructiveAction, isFalse);
      expect(destructive.isDefaultAction, isFalse);
      expect(destructive.isDestructiveAction, isTrue);
      expect(cancel.isDefaultAction, isFalse);
      expect(cancel.isDestructiveAction, isFalse);
    });
  });

  test(
    'action sheet source uses cupertino_ui and does not invent a spring token',
    () {
      final library = File('lib/src/widgets/lingyun_action_sheet.dart')
          .readAsStringSync();
      final gallery = File('example/lib/pages/action_sheets_page.dart')
          .readAsStringSync();
      for (final source in [library, gallery]) {
        final imports = source
            .split('\n')
            .where((line) => line.startsWith('import '))
            .toList();
        expect(
          imports,
          contains("import 'package:cupertino_ui/cupertino_ui.dart';"),
        );
        expect(
          imports.any(
            (line) =>
                line.contains('package:flutter/cupertino.dart') ||
                line.contains('package:flutter/material.dart'),
          ),
          isFalse,
        );
        expect(source.contains('CompatibilityBridge'), isFalse);
        expect(source.contains('GlassButton('), isFalse);
        expect(source.contains('MaterialTier'), isFalse);
        expect(source.contains('LiquidGlassStyle'), isFalse);
      }
      expect(library.contains('CupertinoModalPopupRoute<int>('), isTrue);
      expect(library.contains('showCupertinoModalPopup'), isTrue);
      expect(library.contains('CupertinoActionSheet('), isTrue);
      expect(library.contains('LiquidGlassMotion.reduceMotionOf'), isTrue);
      expect(library.contains('SpringDescription'), isFalse);
      expect(library.contains('stiffness'), isFalse);
      expect(library.contains('522.35'), isFalse);
      expect(gallery.contains('操作表'), isTrue);
      expect(gallery.contains('减少动态效果'), isTrue);
    },
  );

  group('LingyunActionSheet', () {
    testWidgets(
      'cancel sits below, confirm is bold, destructive is system red',
      (tester) async {
        await _pumpPlate(
          tester,
          const LingyunActionSheet(
            title: '选择操作',
            actions: [
              LingyunActionSheetAction.cancel(label: '取消'),
              LingyunActionSheetAction.regular(label: '拷贝'),
              LingyunActionSheetAction.confirm(label: '存储'),
              LingyunActionSheetAction.destructive(label: '删除'),
            ],
          ),
        );

        expect(find.byType(CupertinoActionSheet), findsOneWidget);
        expect(find.byType(GlassButton), findsNothing);
        expect(find.byType(GlassSurface), findsNothing);
        expect(find.byType(LingyunSheet), findsNothing);

        final copy = tester.getRect(find.text('拷贝'));
        final keep = tester.getRect(find.text('存储'));
        final remove = tester.getRect(find.text('删除'));
        final cancel = tester.getRect(find.text('取消'));
        expect(copy.top, lessThan(keep.top));
        expect(keep.top, lessThan(remove.top));
        expect(remove.top, lessThan(cancel.top));
        expect(cancel.top - remove.bottom, greaterThan(4));

        final copyStyle = DefaultTextStyle.of(tester.element(find.text('拷贝')))
            .style;
        final keepStyle = DefaultTextStyle.of(tester.element(find.text('存储')))
            .style;
        final removeStyle = DefaultTextStyle.of(tester.element(find.text('删除')))
            .style;
        final cancelStyle = DefaultTextStyle.of(tester.element(find.text('取消')))
            .style;
        expect(copyStyle.color!.toARGB32(), const Color(0xFF000000).toARGB32());
        expect(
          copyStyle.color!.toARGB32(),
          isNot(const Color(0xFF007AFF).toARGB32()),
        );
        expect(copyStyle.fontWeight, isNot(FontWeight.w600));
        expect(keepStyle.fontWeight, FontWeight.w600);
        expect(keepStyle.color!.toARGB32(), const Color(0xFF000000).toARGB32());
        expect(
          removeStyle.color!.toARGB32(),
          const Color(0xFFFF3B30).toARGB32(),
        );
        expect(
          removeStyle.color!.toARGB32(),
          isNot(const Color(0xFFFF383C).toARGB32()),
        );
        expect(removeStyle.fontWeight, isNot(FontWeight.w600));
        expect(cancelStyle.fontWeight, isNot(FontWeight.w600));
        expect(
          cancelStyle.color!.toARGB32(),
          const Color(0xFF000000).toARGB32(),
        );
        expect(copyStyle.fontSize, 21);

        final titleStyle = DefaultTextStyle.of(
          tester.element(find.text('选择操作')),
        ).style;
        expect(titleStyle.fontSize, 13);
      },
    );

    testWidgets('title plus message bolds the title only', (tester) async {
      await _pumpPlate(
        tester,
        const LingyunActionSheet(
          title: '短标题最好',
          message: '信息应简短完整。',
          actions: [LingyunActionSheetAction.confirm(label: '确认')],
        ),
      );
      final title = DefaultTextStyle.of(tester.element(find.text('短标题最好')))
          .style;
      final message = DefaultTextStyle.of(tester.element(find.text('信息应简短完整。')))
          .style;
      expect(title.fontWeight, FontWeight.w600);
      expect(message.fontWeight, isNot(FontWeight.w600));
      expect(title.fontSize, 13);
      expect(message.fontSize, 13);
    });

    testWidgets('dark destructive red resolves the dark system red', (
      tester,
    ) async {
      await _pumpPlate(
        tester,
        const LingyunActionSheet(
          title: '删除照片',
          actions: [LingyunActionSheetAction.destructive(label: '删除')],
        ),
        brightness: Brightness.dark,
      );
      final style = DefaultTextStyle.of(tester.element(find.text('删除'))).style;
      expect(style.color!.toARGB32(), const Color(0xFFFF453A).toARGB32());
      final plain = DefaultTextStyle.of(tester.element(find.text('删除')));
      expect(
        plain.style.color!.toARGB32(),
        isNot(const Color(0xFFFFFFFF).toARGB32()),
      );
    });

    testWidgets('press swaps the system fill and release restores it', (
      tester,
    ) async {
      await _pumpPlate(
        tester,
        const LingyunActionSheet(
          actions: [
            LingyunActionSheetAction.regular(label: '打开'),
            LingyunActionSheetAction.cancel(label: '取消'),
          ],
        ),
      );
      final idle = _rowFill(tester, find.text('打开'));
      expect(idle.toARGB32(), const Color(0xC8FCFCFC).toARGB32());

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('打开')),
      );
      await tester.pump();
      final pressed = _rowFill(tester, find.text('打开'));
      expect(pressed.toARGB32(), const Color(0xCAE0E0E0).toARGB32());
      expect(pressed.toARGB32(), isNot(idle.toARGB32()));

      final label = DefaultTextStyle.of(tester.element(find.text('打开'))).style;
      expect(label.color!.toARGB32(), const Color(0xFF000000).toARGB32());

      await gesture.up();
      await tester.pump();
      expect(_rowFill(tester, find.text('打开')).toARGB32(), idle.toARGB32());
    });

    testWidgets('cancel press uses the separated slot fill', (tester) async {
      await _pumpPlate(
        tester,
        const LingyunActionSheet(
          actions: [
            LingyunActionSheetAction.regular(label: '打开'),
            LingyunActionSheetAction.cancel(label: '取消'),
          ],
        ),
      );
      expect(
        _rowFill(tester, find.text('取消')).toARGB32(),
        const Color(0xFFFFFFFF).toARGB32(),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('取消')),
      );
      await tester.pump();
      expect(
        _rowFill(tester, find.text('取消')).toARGB32(),
        const Color(0xFFECECEC).toARGB32(),
      );
      await gesture.up();
    });
  });

  group('showLingyunActionSheet', () {
    testWidgets(
      'enter slides up, exit slides down, barrier is the system scrim',
      (tester) async {
        _useSurface(tester, const Size(800, 800));
        int? result = -1;
        await tester.pumpWidget(
          CupertinoApp(
            home: Builder(
              builder: (context) {
                return CupertinoButton(
                  onPressed: () async {
                    result = await showLingyunActionSheet(
                      context,
                      title: '删除照片',
                      message: '此操作无法撤销。',
                      actions: const [
                        LingyunActionSheetAction.destructive(label: '删除'),
                        LingyunActionSheetAction.cancel(label: '取消'),
                      ],
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pump();
        expect(find.text('删除'), findsOneWidget);
        final entering = tester.getTopLeft(find.text('删除')).dy;
        await tester.pump(const Duration(milliseconds: 80));
        final mid = tester.getTopLeft(find.text('删除')).dy;
        expect(mid, lessThan(entering - 1));
        await tester.pumpAndSettle();
        final settled = tester.getTopLeft(find.text('删除')).dy;
        expect(settled, lessThan(mid));
        expect(settled, lessThan(800));
        expect(
          tester.getTopLeft(find.text('取消')).dy,
          greaterThan(tester.getTopLeft(find.text('删除')).dy),
        );
        _expectResolvedBarrier(tester, dark: false);

        final beforeDismiss = tester.getTopLeft(find.text('删除')).dy;
        await tester.tap(find.text('删除'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        expect(find.text('删除'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('删除')).dy,
          greaterThan(beforeDismiss + 1),
        );
        await tester.pumpAndSettle();
        expect(find.text('删除'), findsNothing);
        expect(result, 0);
      },
    );

    testWidgets('dark route resolves the dark system barrier', (tester) async {
      _useSurface(tester, const Size(800, 800));
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () => showLingyunActionSheet(
                  context,
                  message: '链接已复制。',
                  actions: const [LingyunActionSheetAction.regular(label: '好')],
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      _expectResolvedBarrier(tester, dark: true);
      final style = DefaultTextStyle.of(tester.element(find.text('好'))).style;
      expect(style.color!.toARGB32(), const Color(0xFFFFFFFF).toARGB32());
    });

    testWidgets('barrier dismiss returns null and does not select cancel', (
      tester,
    ) async {
      _useSurface(tester, const Size(800, 800));
      int? result = -1;
      var cancelTapped = false;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () async {
                  result = await showLingyunActionSheet(
                    context,
                    title: '已保存',
                    actions: [
                      LingyunActionSheetAction.cancel(
                        label: '取消',
                        onPressed: () => cancelTapped = true,
                      ),
                    ],
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(cancelTapped, isFalse);
    });

    testWidgets('a locked barrier ignores the outside tap', (tester) async {
      _useSurface(tester, const Size(800, 800));
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () => showLingyunActionSheet(
                  context,
                  title: '已保存',
                  barrierDismissible: false,
                  actions: const [LingyunActionSheetAction.regular(label: '好')],
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.text('好'), findsOneWidget);
    });

    testWidgets('LingyunAdaptivity reduce motion snaps in and out', (
      tester,
    ) async {
      _useSurface(tester, const Size(800, 800));
      int? result = -1;
      await tester.pumpWidget(
        CupertinoApp(
          home: LingyunAdaptivity(
            reduceMotion: true,
            child: Builder(
              builder: (context) {
                return CupertinoButton(
                  onPressed: () async {
                    result = await showLingyunActionSheet(
                      context,
                      title: '删除照片',
                      actions: const [
                        LingyunActionSheetAction.destructive(label: '删除'),
                        LingyunActionSheetAction.cancel(label: '取消'),
                      ],
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      final arrived = tester.getTopLeft(find.text('删除')).dy;
      expect(arrived, lessThan(800));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.getTopLeft(find.text('删除')).dy, arrived);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('删除')),
      );
      await tester.pump();
      expect(
        _rowFill(tester, find.text('删除')).toARGB32(),
        const Color(0xCAE0E0E0).toARGB32(),
      );
      // Releasing on the row confirms it. Reduce Motion pops in one frame.
      await gesture.up();
      await tester.pump();
      expect(find.text('删除'), findsNothing);
      expect(result, 0);
    });

    testWidgets('MediaQuery disableAnimations also snaps', (tester) async {
      _useSurface(tester, const Size(800, 800));
      await tester.pumpWidget(
        CupertinoApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            );
          },
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () => showLingyunActionSheet(
                  context,
                  actions: const [
                    LingyunActionSheetAction.regular(label: '打开'),
                  ],
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      final arrived = tester.getTopLeft(find.text('打开')).dy;
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.getTopLeft(find.text('打开')).dy, arrived);
      expect(arrived, lessThan(800));
    });
  });
}

void _useSurface(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _pumpPlate(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
}) async {
  _useSurface(tester, const Size(420, 640));
  await tester.pumpWidget(
    CupertinoApp(
      theme: CupertinoThemeData(brightness: brightness),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

Color _rowFill(WidgetTester tester, Finder text) {
  Color? found;
  tester.element(text).visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is ColoredBox) {
      found = widget.color;
      return false;
    }
    if (widget is DecoratedBox) {
      final decoration = widget.decoration;
      if (decoration is BoxDecoration && decoration.color != null) {
        found = decoration.color;
        return false;
      }
    }
    return true;
  });
  expect(found, isNotNull);
  return found!;
}

void _expectResolvedBarrier(WidgetTester tester, {required bool dark}) {
  final system = kCupertinoModalBarrierColor as CupertinoDynamicColor;
  final expected = dark ? system.darkColor : system.color;
  final colors = tester
      .widgetList<ModalBarrier>(find.byType(ModalBarrier))
      .map((barrier) => barrier.color)
      .whereType<Color>()
      .toList();
  expect(colors, isNotEmpty);
  expect(
    colors.map((color) => color.toARGB32()),
    contains(expected.toARGB32()),
  );
  expect(expected.a, greaterThan(0.15));
  expect(expected.a, lessThan(0.55));
}
