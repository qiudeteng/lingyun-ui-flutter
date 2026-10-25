import 'dart:io';
import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
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

    test('dialog spring matches the critically damped CASpringAnimation', () {
      expect(LingyunAlert.springMass, 1);
      expect(LingyunAlert.springStiffness, 522.35);
      expect(
        LingyunAlert.springDamping,
        closeTo(2 * math.sqrt(LingyunAlert.springStiffness), 1e-6),
      );
      expect(LingyunAlert.springDamping, 45.7099552);
      expect(LingyunAlert.springVelocityTolerance, 0.03);
      expect(
        LingyunAlert.springRestDuration,
        const Duration(milliseconds: 404),
      );
      expect(
        LingyunAlert.cupertinoTransitionDuration,
        const Duration(milliseconds: 250),
      );
      expect(LingyunAlert.enterScaleBegin, 1.3);
      expect(LingyunAlert.enterScaleEnd, 1.0);

      final forward = _alertSpring(forward: true);
      expect(forward.x(0), closeTo(0, 0.001));
      expect(
        forward.x(LingyunAlert.springRestDuration.inMilliseconds / 1000.0),
        closeTo(0.999, 0.001),
      );
      // Published route samples (50ms steps). Scale is the spring mapped
      // from 1.3 to 1.0. Opacity is the spring position.
      const scales = <double>[1.3, 1.205, 1.100, 1.043, 1.017, 1.006, 1.002];
      const opacities = <double>[
        0.316,
        0.665,
        0.856,
        0.942,
        0.977,
        0.991,
        0.997,
      ];
      for (var step = 0; step < scales.length; step++) {
        final t = step * 0.05;
        final x = forward.x(t);
        final scale =
            LingyunAlert.enterScaleBegin +
            (LingyunAlert.enterScaleEnd - LingyunAlert.enterScaleBegin) * x;
        expect(scale, moreOrLessEquals(scales[step], epsilon: 0.001));
        if (step > 0) {
          expect(x, moreOrLessEquals(opacities[step - 1], epsilon: 0.001));
        }
      }
      final arrived = forward.x(0.35);
      expect(arrived, moreOrLessEquals(0.997, epsilon: 0.001));

      // Exit starts at the value enter reached, not at a fresh 1.0.
      final reverse = SpringSimulation(
        SpringDescription(
          mass: LingyunAlert.springMass,
          stiffness: LingyunAlert.springStiffness,
          damping: LingyunAlert.springDamping,
        ),
        arrived,
        0,
        0,
        tolerance: Tolerance(velocity: LingyunAlert.springVelocityTolerance),
        snapToEnd: true,
      );
      const exitOpacities = <double>[0.681, 0.333, 0.143, 0.057, 0.022];
      for (var step = 0; step < exitOpacities.length; step++) {
        expect(
          reverse.x((step + 1) * 0.05),
          moreOrLessEquals(exitOpacities[step], epsilon: 0.001),
        );
      }
    });

    test('pressed fill is the system dialog plate, not a kit blue', () {
      expect(
        LingyunAlert.actionIdleFill(Brightness.light).toARGB32(),
        const Color(0xCCF2F2F2).toARGB32(),
      );
      expect(
        LingyunAlert.actionIdleFill(Brightness.dark).toARGB32(),
        const Color(0xCC2D2D2D).toARGB32(),
      );
      expect(
        LingyunAlert.actionPressedFill(Brightness.light).toARGB32(),
        const Color(0xFFE1E1E1).toARGB32(),
      );
      expect(
        LingyunAlert.actionPressedFill(Brightness.dark).toARGB32(),
        const Color(0xFF404040).toARGB32(),
      );
      expect(
        LingyunAlert.actionPressedFill(Brightness.light).toARGB32(),
        isNot(LingyunAlert.actionBlue(Brightness.light).toARGB32()),
      );
    });

    testWidgets('enter spring scales and fades; exit fades without scale', (
      tester,
    ) async {
      await _pumpAlertOpener(tester);
      await tester.tap(find.text('Open'));

      const scales = <double>[1.3, 1.205, 1.100, 1.043, 1.017, 1.006, 1.002];
      const opacities = <double>[
        0.316,
        0.665,
        0.856,
        0.942,
        0.977,
        0.991,
        0.997,
      ];

      await tester.pump();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(_alertScale(tester), moreOrLessEquals(scales[0], epsilon: 0.001));

      for (var step = 1; step < scales.length; step++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          _alertScale(tester),
          moreOrLessEquals(scales[step], epsilon: 0.001),
        );
        expect(
          _alertOpacity(tester),
          moreOrLessEquals(opacities[step - 1], epsilon: 0.001),
        );
      }
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        _alertOpacity(tester),
        moreOrLessEquals(opacities.last, epsilon: 0.001),
      );

      await tester.tap(find.text('删除'));
      await tester.pump();
      expect(
        find.ancestor(
          of: find.byType(CupertinoAlertDialog),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );
      expect(_alertOpacity(tester), moreOrLessEquals(0.997, epsilon: 0.001));

      const exitOpacities = <double>[0.681, 0.333, 0.143, 0.057, 0.022];
      for (final opacity in exitOpacities) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          find.ancestor(
            of: find.byType(CupertinoAlertDialog),
            matching: find.byType(ScaleTransition),
          ),
          findsNothing,
        );
        expect(
          _alertOpacity(tester),
          moreOrLessEquals(opacity, epsilon: 0.001),
        );
      }
    });

    testWidgets('pointer down paints the pressed plate before release', (
      tester,
    ) async {
      await _pumpAlertOpener(tester);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        _actionFill(tester, '确认').toARGB32(),
        LingyunAlert.actionIdleFill(Brightness.light).toARGB32(),
      );

      final pointer = await tester.startGesture(
        tester.getCenter(find.text('确认')),
      );
      await tester.pump();
      expect(
        _actionFill(tester, '确认').toARGB32(),
        LingyunAlert.actionPressedFill(Brightness.light).toARGB32(),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(
        _actionFill(tester, '确认').toARGB32(),
        LingyunAlert.actionPressedFill(Brightness.light).toARGB32(),
      );

      await pointer.up();
    });

    testWidgets('dark pointer down uses the dark pressed plate', (
      tester,
    ) async {
      await _pumpAlertOpener(tester, brightness: Brightness.dark);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        _actionFill(tester, '确认').toARGB32(),
        LingyunAlert.actionIdleFill(Brightness.dark).toARGB32(),
      );
      final pointer = await tester.startGesture(
        tester.getCenter(find.text('确认')),
      );
      await tester.pump();
      expect(
        _actionFill(tester, '确认').toARGB32(),
        LingyunAlert.actionPressedFill(Brightness.dark).toARGB32(),
      );
      await pointer.up();
    });

    testWidgets('reduce motion still presses, and skips the spring', (
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
      expect(
        _actionFill(tester, '好').toARGB32(),
        LingyunAlert.actionIdleFill(Brightness.light).toARGB32(),
      );
      final pointer = await tester.startGesture(
        tester.getCenter(find.text('好')),
      );
      await tester.pump();
      expect(
        _actionFill(tester, '好').toARGB32(),
        LingyunAlert.actionPressedFill(Brightness.light).toARGB32(),
      );
      await pointer.up();
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

SpringSimulation _alertSpring({required bool forward}) {
  return SpringSimulation(
    SpringDescription(
      mass: LingyunAlert.springMass,
      stiffness: LingyunAlert.springStiffness,
      damping: LingyunAlert.springDamping,
    ),
    forward ? 0.0 : 1.0,
    forward ? 1.0 : 0.0,
    0,
    tolerance: Tolerance(velocity: LingyunAlert.springVelocityTolerance),
    snapToEnd: true,
  );
}

Future<void> _pumpAlertOpener(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
}) {
  return tester.pumpWidget(
    CupertinoApp(
      theme: CupertinoThemeData(brightness: brightness),
      home: Builder(
        builder: (context) {
          return CupertinoButton(
            onPressed: () => showLingyunAlert(
              context,
              title: '删除照片',
              message: '此操作无法撤销。',
              actions: const [
                LingyunAlertAction.confirm(label: '确认'),
                LingyunAlertAction.destructive(label: '删除'),
                LingyunAlertAction.cancel(label: '取消'),
              ],
            ),
            child: const Text('Open'),
          );
        },
      ),
    ),
  );
}

double _alertScale(WidgetTester tester) {
  final scale = tester.widget<ScaleTransition>(
    find
        .ancestor(
          of: find.byType(CupertinoAlertDialog),
          matching: find.byType(ScaleTransition),
        )
        .first,
  );
  return scale.scale.value;
}

double _alertOpacity(WidgetTester tester) {
  final fade = tester.widget<FadeTransition>(
    find
        .ancestor(
          of: find.byType(CupertinoAlertDialog),
          matching: find.byType(FadeTransition),
        )
        .first,
  );
  return fade.opacity.value;
}

Color _actionFill(WidgetTester tester, String label) {
  final plates = tester.widgetList<Container>(
    find.ancestor(of: find.text(label), matching: find.byType(Container)),
  );
  for (final plate in plates) {
    final decoration = plate.decoration;
    if (decoration is BoxDecoration && decoration.color != null) {
      return decoration.color!;
    }
  }
  fail('no action plate for $label');
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
