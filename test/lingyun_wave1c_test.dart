import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  bool reduceMotion = false,
}) {
  final glass = brightness == Brightness.dark
      ? LiquidGlassTheme.dark
      : LiquidGlassTheme.light;
  final theme = brightness == Brightness.dark
      ? ThemeData.dark()
      : ThemeData.light();
  return MaterialApp(
    theme: theme.copyWith(extensions: [glass]),
    home: LingyunTheme(
      brightness: brightness,
      child: LingyunAdaptivity(
        reduceMotion: reduceMotion,
        child: Scaffold(
          body: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    ),
  );
}

const _three = <LingyunSegment<int>>[
  LingyunSegment(value: 0, label: '甲'),
  LingyunSegment(value: 1, label: '乙'),
  LingyunSegment(value: 2, label: '丙'),
];

class _LiveSegments extends StatefulWidget {
  const _LiveSegments({this.reduceMotion = false, this.width = 370});

  final bool reduceMotion;
  final double width;

  @override
  State<_LiveSegments> createState() => _LiveSegmentsState();
}

class _LiveSegmentsState extends State<_LiveSegments> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return LingyunAdaptivity(
      reduceMotion: widget.reduceMotion,
      child: SizedBox(
        width: widget.width,
        child: LingyunSegmentedControl<int>(
          segments: _three,
          selected: selected,
          onChanged: (value) => setState(() => selected = value),
        ),
      ),
    );
  }
}

class _LivePages extends StatefulWidget {
  const _LivePages({this.reduceMotion = false});

  final bool reduceMotion;

  @override
  State<_LivePages> createState() => _LivePagesState();
}

class _LivePagesState extends State<_LivePages> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return LingyunAdaptivity(
      reduceMotion: widget.reduceMotion,
      child: Column(
        children: [
          LingyunPageControl(count: 5, currentIndex: index),
          TextButton(
            onPressed: () => setState(() => index = 3),
            child: const Text('跳到第 4 页'),
          ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LingyunSegmentedMetrics', () {
    test('specimen geometry matches the 32 and 50 tracks', () {
      expect(LingyunSegmentedMetrics.small.height, 32);
      expect(LingyunSegmentedMetrics.large.height, 50);
      expect(LingyunSegmentedMetrics.small.lensHeight, 28);
      expect(LingyunSegmentedMetrics.large.lensHeight, 46);
      expect(LingyunSegmentedMetrics.specimenWidth, 370);
      expect(LingyunSegmentedMetrics.lensWidth(370, 2), 179);
      expect(LingyunSegmentedMetrics.lensLeft(370, 2, 0), 4);
      expect(LingyunSegmentedMetrics.lensLeft(370, 2, 1), 187);
      expect(
        LingyunSegmentedMetrics.lensLeft(370, 2, 1) -
            LingyunSegmentedMetrics.lensLeft(370, 2, 0) -
            LingyunSegmentedMetrics.lensWidth(370, 2),
        LingyunSegmentedMetrics.gap,
      );
      expect(LingyunSegmentedMetrics.pressedScale, 0.97);
    });
  });

  group('LingyunSegmentedControl', () {
    testWidgets('lens is Liquid Glass Regular Small on a tertiary fill', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 370,
            child: LingyunSegmentedControl<int>(
              segments: _three,
              selected: 0,
              onChanged: _keep,
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(LingyunSegmentedControl<int>)).height,
        32,
      );
      final lens = tester.getSize(find.byKey(LingyunSegmentedControl.lensKey));
      expect(lens.height, 28);
      expect(
        lens.width,
        closeTo(LingyunSegmentedMetrics.lensWidth(370, 3), 0.1),
      );

      final glass = tester.widget<GlassSurface>(
        find.descendant(
          of: find.byKey(LingyunSegmentedControl.lensKey),
          matching: find.byType(GlassSurface),
        ),
      );
      expect(glass.style, LiquidGlassStyle.regularSmall);
      expect(glass.material, isNull);
      expect(glass.tokens, isNull);

      final track = tester.widget<DecoratedBox>(
        find.byKey(LingyunSegmentedControl.trackKey),
      );
      expect(
        (track.decoration as BoxDecoration).color,
        LingyunColors.light.fills.tertiary,
      );
      expect(
        find.descendant(
          of: find.byKey(LingyunSegmentedControl.trackKey),
          matching: find.byType(GlassSurface),
        ),
        findsNothing,
      );

      expect(
        _labelColor(tester, '甲'),
        LingyunColors.light.liquidGlassLabels.primary,
      );
      expect(
        _labelColor(tester, '乙'),
        LingyunColors.light.liquidGlassLabels.secondary,
      );
    });

    testWidgets('large size is 50 tall and tint recolors only the label', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 370,
            child: LingyunSegmentedControl<int>(
              size: LingyunSegmentedControlSize.large,
              segments: [
                LingyunSegment(value: 0, label: '标准'),
                LingyunSegment(value: 1, label: '强调'),
              ],
              selected: 1,
              tint: Color(0xFFFF383C),
              onChanged: _keep,
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(LingyunSegmentedControl<int>)).height,
        50,
      );
      expect(
        tester.getSize(find.byKey(LingyunSegmentedControl.lensKey)).height,
        46,
      );
      expect(_labelColor(tester, '强调'), const Color(0xFFFF383C));
      expect(
        _labelColor(tester, '标准'),
        LingyunColors.light.liquidGlassLabels.secondary,
      );
      expect(
        tester
            .widget<GlassSurface>(
              find.descendant(
                of: find.byKey(LingyunSegmentedControl.lensKey),
                matching: find.byType(GlassSurface),
              ),
            )
            .style,
        LiquidGlassStyle.regularSmall,
      );
    });

    testWidgets('disabled labels are tertiary and ignore taps', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 370,
            child: LingyunSegmentedControl<int>(
              segments: [
                LingyunSegment(value: 0, label: '开'),
                LingyunSegment(value: 1, label: '关'),
              ],
              selected: 0,
            ),
          ),
        ),
      );

      expect(
        _labelColor(tester, '开'),
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
      expect(
        _labelColor(tester, '关'),
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
      await tester.tap(find.text('关'));
      await tester.pump();
      expect(find.text('关'), findsOneWidget);
      expect(
        _labelColor(tester, '关'),
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
    });

    testWidgets('tap springs the lens instead of cutting to the new segment', (
      tester,
    ) async {
      await tester.pumpWidget(host(const _LiveSegments()));
      await tester.pumpAndSettle();

      final start = _lensLeft(tester);
      expect(start, closeTo(LingyunSegmentedMetrics.lensLeft(370, 3, 0), 0.5));

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('丙')),
      );
      await tester.pump(const Duration(milliseconds: 20));
      expect(_lensLeft(tester), closeTo(start, 0.5));

      await gesture.up();
      // The spring starts during this build. The ticker advances on the
      // following pump, so one pump is still the old position.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final mid = _lensLeft(tester);
      final end = LingyunSegmentedMetrics.lensLeft(370, 3, 2);
      expect(mid, greaterThan(start + 1));
      expect(mid, lessThan(end - 1));

      await tester.pumpAndSettle();
      expect(_lensLeft(tester), closeTo(end, 0.5));
      expect(find.text('丙'), findsOneWidget);
    });

    testWidgets('reduce motion snaps the lens with no flight', (tester) async {
      await tester.pumpWidget(host(const _LiveSegments(reduceMotion: true)));
      await tester.pumpAndSettle();
      final start = _lensLeft(tester);

      await tester.tap(find.text('丙'));
      await tester.pump();
      final end = LingyunSegmentedMetrics.lensLeft(370, 3, 2);
      expect(_lensLeft(tester), closeTo(end, 0.5));
      expect(_lensLeft(tester), isNot(closeTo(start, 0.5)));

      final scale = tester.widget<AnimatedScale>(
        find.byKey(LingyunSegmentedControl.lensKey),
      );
      expect(scale.duration, Duration.zero);
    });

    testWidgets('press flexes the lens on the button duration', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 370,
            child: LingyunSegmentedControl<int>(
              segments: _three,
              selected: 0,
              forcePressed: true,
              onChanged: _keep,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scale = tester.widget<AnimatedScale>(
        find.byKey(LingyunSegmentedControl.lensKey),
      );
      expect(scale.scale, LingyunSegmentedMetrics.pressedScale);
      expect(scale.duration, LiquidGlassMotion.defaults.quick);
      expect(scale.curve, LiquidGlassMotion.defaults.quickCurve);
    });

    testWidgets('dark track uses the dark tertiary fill', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 370,
            child: LingyunSegmentedControl<int>(
              segments: _three,
              selected: 1,
              onChanged: _keep,
            ),
          ),
          brightness: Brightness.dark,
        ),
      );

      final track = tester.widget<DecoratedBox>(
        find.byKey(LingyunSegmentedControl.trackKey),
      );
      expect(
        (track.decoration as BoxDecoration).color,
        LingyunColors.dark.fills.tertiary,
      );
      expect(
        _labelColor(tester, '乙'),
        LingyunColors.dark.liquidGlassLabels.primary,
      );
    });
  });

  group('LingyunPageControl', () {
    testWidgets('indicator-only: current dot, tertiary rest, no tap target', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const LingyunPageControl(
            count: 5,
            currentIndex: 0,
            semanticLabel: '第 1 页，共 5 页',
          ),
        ),
      );

      expect(find.byKey(LingyunPageControl.tapKey), findsNothing);
      expect(find.byType(GlassSurface), findsNothing);
      expect(
        _dotColor(tester, LingyunPageControl.highlightKey),
        LingyunColors.light.liquidGlassLabels.primary,
      );
      expect(
        _dotColor(tester, LingyunPageControl.inactiveDotKey(1)),
        LingyunColors.light.liquidGlassLabels.tertiary,
      );
      expect(
        tester.getSemantics(find.byType(LingyunPageControl)),
        matchesSemantics(label: '第 1 页，共 5 页'),
      );
    });

    testWidgets('tint lowers the other dots and platter is Regular Small', (
      tester,
    ) async {
      const tint = Color(0xFFFF383C);
      await tester.pumpWidget(
        host(
          const LingyunPageControl(
            count: 4,
            currentIndex: 1,
            tint: tint,
            platter: true,
          ),
        ),
      );

      expect(_dotColor(tester, LingyunPageControl.highlightKey), tint);
      expect(
        _dotColor(tester, LingyunPageControl.inactiveDotKey(0)),
        tint.withValues(alpha: 0.35),
      );
      final glass = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(glass.style, LiquidGlassStyle.regularSmall);
      expect(glass.material, isNull);
    });

    testWidgets('index change springs the highlight', (tester) async {
      await tester.pumpWidget(host(const _LivePages()));
      await tester.pumpAndSettle();
      final start = tester
          .getTopLeft(find.byKey(LingyunPageControl.highlightKey))
          .dx;

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('跳到第 4 页')),
      );
      await gesture.up();
      // The spring starts during this build. The ticker advances on the
      // following pump, so one pump is still the old position.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final mid = tester
          .getTopLeft(find.byKey(LingyunPageControl.highlightKey))
          .dx;
      final end = start + LingyunPageControlMetrics.highlightLeft(5, 3);
      expect(mid, greaterThan(start + 1));
      expect(mid, lessThan(end - 1));

      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(LingyunPageControl.highlightKey)).dx,
        closeTo(end, 0.5),
      );
    });

    testWidgets('reduce motion snaps the highlight', (tester) async {
      await tester.pumpWidget(host(const _LivePages(reduceMotion: true)));
      await tester.pumpAndSettle();
      final start = tester
          .getTopLeft(find.byKey(LingyunPageControl.highlightKey))
          .dx;

      await tester.tap(find.text('跳到第 4 页'));
      await tester.pump();
      expect(
        tester.getTopLeft(find.byKey(LingyunPageControl.highlightKey)).dx,
        closeTo(start + LingyunPageControlMetrics.highlightLeft(5, 3), 0.5),
      );
    });

    testWidgets('optional tap jumps to the tapped dot', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        host(
          LingyunPageControl(
            count: 5,
            currentIndex: index,
            onChanged: (value) => index = value,
          ),
        ),
      );
      expect(find.byKey(LingyunPageControl.tapKey), findsOneWidget);

      final box = tester.getRect(find.byKey(LingyunPageControl.tapKey));
      await tester.tapAt(
        Offset(
          box.left + LingyunPageControlMetrics.stride() * 2 + 1,
          box.center.dy,
        ),
      );
      expect(index, 2);
    });
  });

  test(
    'wave 1c sources do not mint a spring token or import legacy libraries',
    () {
      const paths = [
        'lib/src/widgets/lingyun_segmented_control.dart',
        'lib/src/widgets/lingyun_page_control.dart',
        'lib/src/widgets/liquid_glass_spring_value.dart',
        'example/lib/pages/wave1c_page.dart',
      ];
      for (final path in paths) {
        final source = File(path).readAsStringSync();
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
          reason: path,
        );
        expect(source.contains('MaterialTier.'), isFalse, reason: path);
        expect(source.contains('stiffness:'), isFalse, reason: path);
        expect(source.contains('springBounce'), isFalse, reason: path);
      }

      final spring = File('lib/src/widgets/liquid_glass_spring_value.dart')
          .readAsStringSync();
      expect(spring.contains('withDurationAndBounce'), isTrue);
      expect(spring.contains('bounce:'), isFalse);
      expect(spring.contains('LiquidGlassMotion.defaults.quick'), isTrue);

      final page = File('example/lib/pages/wave1c_page.dart')
          .readAsStringSync();
      expect(page.contains('Color(0x'), isFalse);
      expect(page.contains('分段与页面控件'), isTrue);
    },
  );
}

void _keep(int _) {}

double _lensLeft(WidgetTester tester) {
  final control = tester.getTopLeft(find.byType(LingyunSegmentedControl<int>));
  final lens = tester.getTopLeft(find.byKey(LingyunSegmentedControl.lensKey));
  return lens.dx - control.dx;
}

Color _labelColor(WidgetTester tester, String label) {
  final style = tester
      .widget<AnimatedDefaultTextStyle>(
        find
            .ancestor(
              of: find.text(label),
              matching: find.byType(AnimatedDefaultTextStyle),
            )
            .first,
      )
      .style;
  return style.color!;
}

Color _dotColor(WidgetTester tester, Key key) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byKey(key), matching: find.byType(DecoratedBox)),
  );
  return (box.decoration as BoxDecoration).color!;
}
