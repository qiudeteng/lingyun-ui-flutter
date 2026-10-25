import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LingyunAlert.arrangedIndices', () {
    test('two actions put cancel first even when it was passed second', () {
      final actions = <LingyunAlertAction>[
        const LingyunAlertAction.confirm(label: '确认'),
        const LingyunAlertAction.cancel(label: '取消'),
      ];
      expect(LingyunAlert.arrangedIndices(actions), [1, 0]);
    });

    test('cancel already leading stays leading', () {
      final actions = <LingyunAlertAction>[
        const LingyunAlertAction.cancel(label: '取消'),
        const LingyunAlertAction.destructive(label: '删除'),
      ];
      expect(LingyunAlert.arrangedIndices(actions), [0, 1]);
    });

    test('no cancel keeps caller order', () {
      final actions = <LingyunAlertAction>[
        const LingyunAlertAction.confirm(label: '保留'),
        const LingyunAlertAction.destructive(label: '删除'),
      ];
      expect(LingyunAlert.arrangedIndices(actions), [0, 1]);
    });

    test('three or more place cancel last', () {
      final actions = <LingyunAlertAction>[
        const LingyunAlertAction.cancel(label: '取消'),
        const LingyunAlertAction.confirm(label: '存储'),
        const LingyunAlertAction.destructive(label: '删除'),
      ];
      expect(LingyunAlert.arrangedIndices(actions), [1, 2, 0]);
    });

    test('a single action is unchanged', () {
      expect(
        LingyunAlert.arrangedIndices(const [
          LingyunAlertAction.confirm(label: '好'),
        ]),
        [0],
      );
    });
  });

  group('LingyunAlertAction', () {
    test('styles map to Cupertino default and destructive flags', () {
      const cancel = LingyunAlertAction.cancel(label: '取消');
      const confirm = LingyunAlertAction.confirm(label: '确认');
      const destructive = LingyunAlertAction.destructive(label: '删除');
      expect(cancel.isDefaultAction, isFalse);
      expect(cancel.isDestructiveAction, isFalse);
      expect(confirm.isDefaultAction, isTrue);
      expect(confirm.isDestructiveAction, isFalse);
      expect(destructive.isDefaultAction, isFalse);
      expect(destructive.isDestructiveAction, isTrue);
    });
  });

  test(
    'alerts source uses cupertino_ui and not the in-framework design libraries',
    () {
      final library = File('lib/src/widgets/lingyun_alert.dart')
          .readAsStringSync();
      final gallery = File('example/lib/pages/alerts_page.dart')
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
    },
  );

  group('LingyunAlertDialog', () {
    testWidgets('title + message, cancel leading, confirm bold', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LingyunAlertDialog(
            title: '短标题最好',
            message: '信息应简短完整。',
            actions: [
              LingyunAlertAction.confirm(label: '确认'),
              LingyunAlertAction.cancel(label: '取消'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('短标题最好'), findsOneWidget);
      expect(find.text('信息应简短完整。'), findsOneWidget);
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(CupertinoDialogAction), findsNWidgets(2));
      expect(find.byType(GlassButton), findsNothing);
      expect(find.byType(GlassSurface), findsNothing);

      final cancel = tester.getRect(find.text('取消'));
      final confirm = tester.getRect(find.text('确认'));
      expect(cancel.left, lessThan(confirm.left));

      final confirmStyle = DefaultTextStyle.of(tester.element(find.text('确认')))
          .style;
      final cancelStyle = DefaultTextStyle.of(tester.element(find.text('取消')))
          .style;
      expect(confirmStyle.fontWeight, FontWeight.w600);
      expect(cancelStyle.fontWeight, isNot(FontWeight.w600));
      expect(
        confirmStyle.color!.toARGB32(),
        LingyunAlert.actionBlue(Brightness.light).toARGB32(),
      );
      expect(cancelStyle.color!.toARGB32(), confirmStyle.color!.toARGB32());
      expect(
        confirmStyle.color!.toARGB32(),
        isNot(const Color(0xFF007AFF).toARGB32()),
      );
      expect(confirmStyle.fontFamily, LingyunAlert.systemFontFamily);

      final titleStyle = DefaultTextStyle.of(tester.element(find.text('短标题最好')))
          .style;
      final messageStyle = DefaultTextStyle.of(
        tester.element(find.text('信息应简短完整。')),
      ).style;
      expect(titleStyle.fontSize, 17);
      expect(messageStyle.fontSize, 13);
    });

    testWidgets('destructive action is system red and not a glass red', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LingyunAlertDialog(
            title: '删除照片',
            message: '此操作无法撤销。',
            actions: [
              LingyunAlertAction.destructive(label: '删除'),
              LingyunAlertAction.cancel(label: '取消'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cancel = tester.getRect(find.text('取消'));
      final delete = tester.getRect(find.text('删除'));
      expect(cancel.left, lessThan(delete.left));

      final context = tester.element(find.text('删除'));
      final style = DefaultTextStyle.of(context).style;
      expect(style.color!.toARGB32(), const Color(0xFFFF3B30).toARGB32());
      expect(
        style.color!.toARGB32(),
        isNot(const Color(0xFFFF383C).toARGB32()),
      );
      expect(style.fontWeight, isNot(FontWeight.w600));
    });

    testWidgets('dark destructive red resolves the dark system red', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LingyunAlertDialog(
            title: '删除照片',
            message: '此操作无法撤销。',
            actions: [LingyunAlertAction.destructive(label: '删除')],
          ),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('删除'));
      final style = DefaultTextStyle.of(context).style;
      expect(style.color!.toARGB32(), const Color(0xFFFF453A).toARGB32());
      expect(find.byType(CupertinoDialogAction), findsOneWidget);
    });

    testWidgets('message only omits the title', (tester) async {
      await tester.pumpWidget(
        _host(
          const LingyunAlertDialog(
            message: '链接已复制。',
            actions: [LingyunAlertAction.confirm(label: '好')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('链接已复制。'), findsOneWidget);
      expect(find.text('短标题最好'), findsNothing);
      expect(find.byType(CupertinoDialogAction), findsOneWidget);
      final ok = DefaultTextStyle.of(tester.element(find.text('好'))).style;
      expect(ok.fontWeight, FontWeight.w600);
    });

    testWidgets('RTL keeps cancel on the leading side', (tester) async {
      await tester.pumpWidget(
        _host(
          const LingyunAlertDialog(
            title: '短标题最好',
            message: '信息应简短完整。',
            actions: [
              LingyunAlertAction.confirm(label: '确认'),
              LingyunAlertAction.cancel(label: '取消'),
            ],
          ),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      final cancel = tester.getRect(find.text('取消'));
      final confirm = tester.getRect(find.text('确认'));
      expect(cancel.left, greaterThan(confirm.left));
    });
  });

  group('showLingyunAlert', () {
    testWidgets('returns the caller index and uses the system barrier', (
      tester,
    ) async {
      int? result;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () async {
                  result = await showLingyunAlert(
                    context,
                    title: '删除照片',
                    message: '此操作无法撤销。',
                    actions: [
                      const LingyunAlertAction.destructive(label: '删除'),
                      const LingyunAlertAction.cancel(label: '取消'),
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

      expect(
        tester.getRect(find.text('取消')).left,
        lessThan(tester.getRect(find.text('删除')).left),
      );
      _expectSystemBarrier(tester, dark: false);

      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      expect(result, 0);
    });

    testWidgets('dark route uses the dark system barrier', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () => showLingyunAlert(
                  context,
                  message: '链接已复制。',
                  actions: const [LingyunAlertAction.confirm(label: '好')],
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      _expectSystemBarrier(tester, dark: true);
      expect(find.text('链接已复制。'), findsOneWidget);
    });

    testWidgets('barrier dismiss returns null', (tester) async {
      int? result = -1;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () async {
                  result = await showLingyunAlert(
                    context,
                    title: '已保存',
                    actions: const [LingyunAlertAction.confirm(label: '好')],
                    barrierDismissible: true,
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
    });

    testWidgets('dark confirm uses the kit system blue', (tester) async {
      await tester.pumpWidget(
        _host(
          const LingyunAlertDialog(
            title: '已保存',
            actions: [LingyunAlertAction.confirm(label: '好')],
          ),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();

      final style = DefaultTextStyle.of(tester.element(find.text('好'))).style;
      expect(
        style.color!.toARGB32(),
        LingyunAlert.actionBlue(Brightness.dark).toARGB32(),
      );
      expect(style.color!.toARGB32(), const Color(0xFF0091FF).toARGB32());
      expect(
        style.color!.toARGB32(),
        isNot(const Color(0xFF0A84FF).toARGB32()),
      );
    });

    testWidgets('system route is mid scale-fade before it rests', (
      tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () => showLingyunAlert(
                  context,
                  title: '已保存',
                  actions: const [LingyunAlertAction.confirm(label: '好')],
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      final scale = tester.widget<ScaleTransition>(
        find
            .ancestor(
              of: find.byType(CupertinoAlertDialog),
              matching: find.byType(ScaleTransition),
            )
            .first,
      );
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byType(CupertinoAlertDialog),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(scale.scale.value, greaterThan(1));
      expect(fade.opacity.value, lessThan(1));

      await tester.pumpAndSettle();
      final restedScale = tester.widget<ScaleTransition>(
        find
            .ancestor(
              of: find.byType(CupertinoAlertDialog),
              matching: find.byType(ScaleTransition),
            )
            .first,
      );
      final restedFade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byType(CupertinoAlertDialog),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(restedScale.scale.value, closeTo(1, 0.01));
      expect(restedFade.opacity.value, closeTo(1, 0.01));
    });

    testWidgets('reduce motion shows the dialog without the scale fade', (
      tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                onPressed: () => showLingyunAlert(
                  context,
                  title: '已保存',
                  actions: const [LingyunAlertAction.confirm(label: '好')],
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.text('已保存'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(CupertinoAlertDialog),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );
    });

    testWidgets('LingyunAdaptivity.reduceMotion skips the scale fade', (
      tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: LingyunAdaptivity(
            reduceMotion: true,
            child: Builder(
              builder: (context) {
                return CupertinoButton(
                  onPressed: () => showLingyunAlert(
                    context,
                    message: '链接已复制。',
                    actions: const [LingyunAlertAction.confirm(label: '好')],
                  ),
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      expect(find.text('链接已复制。'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(CupertinoAlertDialog),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );
    });
  });

  group('desktop type', () {
    test('action blue is the kit system blue', () {
      expect(
        LingyunAlert.actionBlue(Brightness.light),
        LingyunColors.light.system.blue,
      );
      expect(
        LingyunAlert.actionBlue(Brightness.dark),
        LingyunColors.dark.system.blue,
      );
      expect(
        LingyunAlert.actionBlue(Brightness.light).toARGB32(),
        const Color(0xFF0088FF).toARGB32(),
      );
      expect(
        LingyunAlert.actionBlue(Brightness.dark).toARGB32(),
        const Color(0xFF0091FF).toARGB32(),
      );
    });

    testWidgets('non-Apple adopts an ambient family and keeps system size', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        await tester.pumpWidget(
          _host(
            const DefaultTextStyle(
              style: TextStyle(fontFamily: 'Roboto', fontSize: 14),
              child: LingyunAlertDialog(
                title: '短标题最好',
                message: '信息应简短完整。',
                actions: [
                  LingyunAlertAction.confirm(label: '确认'),
                  LingyunAlertAction.cancel(label: '取消'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final title = tester.widget<Text>(find.text('短标题最好'));
        final parent = DefaultTextStyle.of(tester.element(find.text('短标题最好')))
            .style;
        final painted = parent.merge(title.style);
        expect(parent.fontFamily, LingyunAlert.systemFontFamily);
        expect(parent.fontSize, 17);
        expect(painted.fontFamily, 'Roboto');
        expect(painted.fontSize, 17);
        expect(painted.fontWeight, FontWeight.w600);
        expect(painted.fontFamilyFallback, LingyunAlert.desktopCjkFallback);

        final confirm = DefaultTextStyle.of(tester.element(find.text('确认')))
            .style;
        expect(confirm.fontFamily, 'Roboto');
        expect(confirm.fontWeight, FontWeight.w600);
        expect(
          confirm.color!.toARGB32(),
          LingyunAlert.actionBlue(Brightness.light).toARGB32(),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('Apple keeps the system font proxy', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(
          _host(
            const DefaultTextStyle(
              style: TextStyle(fontFamily: 'Roboto', fontSize: 14),
              child: LingyunAlertDialog(
                title: '短标题最好',
                actions: [LingyunAlertAction.confirm(label: '好')],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final title = tester.widget<Text>(find.text('短标题最好'));
        expect(title.style, isNull);
        final parent = DefaultTextStyle.of(tester.element(find.text('短标题最好')))
            .style;
        expect(parent.fontFamily, LingyunAlert.systemFontFamily);
        final action = DefaultTextStyle.of(tester.element(find.text('好')))
            .style;
        expect(action.fontFamily, LingyunAlert.systemFontFamily);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}

void _expectSystemBarrier(WidgetTester tester, {required bool dark}) {
  final dynamicColors = tester
      .widgetList<ModalBarrier>(find.byType(ModalBarrier))
      .map((barrier) => barrier.color)
      .whereType<CupertinoDynamicColor>();
  expect(dynamicColors, hasLength(1));
  final barrier = dynamicColors.single;
  final system = kCupertinoModalBarrierColor as CupertinoDynamicColor;
  expect(barrier.color.toARGB32(), system.color.toARGB32());
  expect(barrier.darkColor.toARGB32(), system.darkColor.toARGB32());
  final effective = dark ? system.darkColor : system.color;
  expect(barrier.toARGB32(), effective.toARGB32());
  expect(effective.a, greaterThan(0.15));
  expect(effective.a, lessThan(0.55));
}

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return CupertinoApp(
    theme: CupertinoThemeData(brightness: brightness),
    locale: textDirection == TextDirection.rtl
        ? const Locale('ar')
        : const Locale('en', 'US'),
    home: Directionality(
      textDirection: textDirection,
      child: Center(child: SizedBox(width: 420, height: 420, child: child)),
    ),
  );
}
