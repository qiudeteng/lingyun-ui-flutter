import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('ControlMetrics', () {
    test('symbol bodies match the accepted knob and track gallery', () {
      expect(ControlMetrics.knobDiameter, 24);
      expect(ControlMetrics.toggleTrackWidth, 64);
      expect(ControlMetrics.toggleTrackHeight, 28);
      expect(ControlMetrics.toggleKnobInset, 2);
      expect(ControlMetrics.sliderTrackHeight, 6);
      expect(ControlMetrics.stepperWidth, 92);
      expect(ControlMetrics.stepperHeight, 32);
      expect(ControlMetrics.stadium(28), BorderRadius.circular(14));
    });
  });

  group('LingyunToggle', () {
    testWidgets('off idle uses the unfilled track and a leading knob', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LingyunToggle(
            value: false,
            onChanged: _keepBool,
            brightness: Brightness.light,
          ),
        ),
      );

      final track = _onlyTrack(tester, LingyunToggle);
      expect(track.style, same(ControlLayerCatalog.light.trackUnfilledIdle));
      expect(track.width, 64);
      expect(track.height, 28);
      expect(track.borderRadius, BorderRadius.circular(14));

      final knob = _onlyKnob(tester);
      expect(knob.clicked, isFalse);
      expect(knob.width, 24);
      expect(knob.height, 24);
      expect(knob.borderRadius, BorderRadius.circular(12));
      expect(_knobLeft(tester, LingyunToggle), 2);
      expect(_stackClip(tester, LingyunToggle), Clip.none);
    });

    testWidgets('on idle parks the knob on the trailing side', (tester) async {
      await tester.pumpWidget(
        _host(
          const LingyunToggle(
            value: true,
            onChanged: _keepBool,
            brightness: Brightness.light,
          ),
        ),
      );

      expect(
        _onlyTrack(tester, LingyunToggle).style,
        same(ControlLayerCatalog.light.trackFilledIdle),
      );
      expect(_knobLeft(tester, LingyunToggle), 64 - 2 - 24);
    });

    testWidgets('pressed uses the clicked track and knob', (tester) async {
      await tester.pumpWidget(
        _host(
          const LingyunToggle(
            value: false,
            onChanged: _keepBool,
            forcePressed: true,
            brightness: Brightness.light,
          ),
        ),
      );

      expect(
        _onlyTrack(tester, LingyunToggle).style,
        same(ControlLayerCatalog.light.trackUnfilledClicked),
      );
      expect(_onlyKnob(tester).clicked, isTrue);
    });

    testWidgets('disabled on keeps the unfilled disabled track', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const LingyunToggle(value: true, brightness: Brightness.light)),
      );
      await tester.tap(find.byType(LingyunToggle));
      await tester.pump();

      expect(
        _onlyTrack(tester, LingyunToggle).style,
        same(ControlLayerCatalog.light.trackUnfilledDisabled),
      );
      expect(_knobLeft(tester, LingyunToggle), 64 - 2 - 24);
      expect(_onlyKnob(tester).clicked, isFalse);
    });

    testWidgets('dark idle draws no knob, pressed still draws the rings', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LingyunToggle(
            value: true,
            onChanged: _keepBool,
            brightness: Brightness.dark,
          ),
        ),
      );
      expect(find.byType(ControlKnobStack), findsNothing);
      expect(
        _onlyTrack(tester, LingyunToggle).style,
        same(ControlLayerCatalog.dark.trackFilledIdle),
      );

      await tester.pumpWidget(
        _host(
          const LingyunToggle(
            value: false,
            onChanged: _keepBool,
            forcePressed: true,
            brightness: Brightness.dark,
          ),
        ),
      );
      expect(_onlyKnob(tester).clicked, isTrue);
      expect(_onlyKnob(tester).brightness, Brightness.dark);
    });

    testWidgets('tap reports the next value', (tester) async {
      bool? next;
      await tester.pumpWidget(
        _host(
          LingyunToggle(
            value: true,
            brightness: Brightness.light,
            onChanged: (value) => next = value,
          ),
        ),
      );
      await tester.tap(find.byType(LingyunToggle));
      expect(next, isFalse);
    });
  });

  group('LingyunSlider', () {
    testWidgets('mid idle splits filled and unfilled at the knob center', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 280,
            child: LingyunSlider(
              value: 0.5,
              onChanged: _keepDouble,
              brightness: Brightness.light,
            ),
          ),
        ),
      );

      final tracks = _tracks(tester, LingyunSlider);
      expect(tracks, hasLength(2));
      expect(
        tracks[0].style,
        same(ControlLayerCatalog.light.trackUnfilledIdle),
      );
      expect(tracks[1].style, same(ControlLayerCatalog.light.trackFilledIdle));
      expect(tracks[0].height, 6);
      expect(tracks[0].borderRadius, BorderRadius.circular(3));
      expect(_knobLeft(tester, LingyunSlider), closeTo(128, 0.01));
      expect(_onlyKnob(tester).clicked, isFalse);
      expect(_stackClip(tester, LingyunSlider), Clip.none);
    });

    testWidgets('pressed uses clicked styles', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 280,
            child: LingyunSlider(
              value: 0.5,
              onChanged: _keepDouble,
              forcePressed: true,
              brightness: Brightness.light,
            ),
          ),
        ),
      );

      final tracks = _tracks(tester, LingyunSlider);
      expect(
        tracks[0].style,
        same(ControlLayerCatalog.light.trackUnfilledClicked),
      );
      expect(
        tracks[1].style,
        same(ControlLayerCatalog.light.trackFilledClicked),
      );
      expect(_onlyKnob(tester).clicked, isTrue);
      expect(
        find.descendant(
          of: find.byType(LingyunSlider),
          matching: find.byType(ColorFiltered),
        ),
        findsNothing,
      );
    });

    testWidgets(
      'dark pressed stacks a visible clicked ring and idle does not',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(280, 80));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: RepaintBoundary(
              key: Key('dark-slider-shot'),
              child: ColoredBox(
                color: Color(0xFF000000),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    child: LingyunSlider(
                      value: 0.5,
                      onChanged: _keepDouble,
                      forcePressed: true,
                      brightness: Brightness.dark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final knob = _onlyKnob(tester);
        expect(knob.clicked, isTrue);
        expect(knob.brightness, Brightness.dark);
        expect(knob.showRingOnBlack, isTrue);
        expect(
          tester.getSize(find.byType(ControlKnobStack)),
          const Size(24, 24),
        );
        expect(
          find.descendant(
            of: find.byType(ControlKnobStack),
            matching: find.byType(ColorFiltered),
          ),
          findsOneWidget,
        );
        final ringSpan = await _nonBlackSpan(
          tester,
          find.byKey(const Key('dark-slider-shot')),
        );
        expect(ringSpan, greaterThanOrEqualTo(20));

        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 200,
              child: LingyunSlider(
                value: 0.5,
                onChanged: _keepDouble,
                brightness: Brightness.dark,
              ),
            ),
          ),
        );
        expect(find.byType(ControlKnobStack), findsNothing);
      },
    );

    testWidgets('disabled drops the filled portion', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 280,
            child: LingyunSlider(value: 0.5, brightness: Brightness.light),
          ),
        ),
      );
      await tester.drag(find.byType(LingyunSlider), const Offset(40, 0));
      await tester.pump();
      final tracks = _tracks(tester, LingyunSlider);
      expect(tracks, hasLength(1));
      expect(
        tracks.single.style,
        same(ControlLayerCatalog.light.trackUnfilledDisabled),
      );
    });

    testWidgets('dark idle has no knob and drag reports a higher value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 280,
            child: LingyunSlider(
              value: 0.5,
              onChanged: _keepDouble,
              brightness: Brightness.dark,
            ),
          ),
        ),
      );
      expect(find.byType(ControlKnobStack), findsNothing);
      expect(
        _tracks(tester, LingyunSlider)[1].style,
        same(ControlLayerCatalog.dark.trackFilledIdle),
      );

      double? next;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: LingyunSlider(
              value: 0.5,
              brightness: Brightness.light,
              onChanged: (value) => next = value,
            ),
          ),
        ),
      );
      await tester.drag(find.byType(LingyunSlider), const Offset(80, 0));
      expect(next, isNotNull);
      expect(next!, greaterThan(0.5));
    });
  });

  group('LingyunStepper', () {
    testWidgets('idle reuses the unfilled track and draws no knob', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LingyunStepper(
            value: 3,
            onChanged: _keepInt,
            brightness: Brightness.light,
          ),
        ),
      );

      expect(find.byType(ControlKnobStack), findsNothing);
      final track = _onlyTrack(tester, LingyunStepper);
      expect(track.style, same(ControlLayerCatalog.light.trackUnfilledIdle));
      expect(track.width, 92);
      expect(track.height, 32);
      expect(track.borderRadius, BorderRadius.circular(16));
      expect(
        tester
            .widget<ColoredBox>(
              find.descendant(
                of: find.byType(LingyunStepper),
                matching: find.byType(ColoredBox),
              ),
            )
            .color,
        LingyunColors.light.separators.nonOpaque,
      );
    });

    testWidgets('pressed side uses the clicked unfilled track', (tester) async {
      await tester.pumpWidget(
        _host(
          const LingyunStepper(
            value: 3,
            onChanged: _keepInt,
            forcePressed: LingyunStepperSide.decrement,
            brightness: Brightness.light,
          ),
        ),
      );

      final tracks = _tracks(tester, LingyunStepper);
      expect(tracks, hasLength(2));
      expect(
        tracks[0].style,
        same(ControlLayerCatalog.light.trackUnfilledIdle),
      );
      expect(
        tracks[1].style,
        same(ControlLayerCatalog.light.trackUnfilledClicked),
      );
      expect(find.byType(ControlKnobStack), findsNothing);
    });

    testWidgets('disabled uses the unfilled disabled track', (tester) async {
      await tester.pumpWidget(
        _host(const LingyunStepper(value: 3, brightness: Brightness.light)),
      );
      await tester.tap(find.byType(LingyunStepper));
      await tester.pump();
      expect(
        _onlyTrack(tester, LingyunStepper).style,
        same(ControlLayerCatalog.light.trackUnfilledDisabled),
      );
    });

    testWidgets('plus and minus step, and the ends stop', (tester) async {
      var value = 1;
      Future<void> pump() {
        return tester.pumpWidget(
          _host(
            LingyunStepper(
              value: value,
              min: 0,
              max: 2,
              brightness: Brightness.light,
              onChanged: (next) => value = next,
            ),
          ),
        );
      }

      await pump();
      await tester.tapAt(_side(tester, trailing: true));
      expect(value, 2);
      await pump();
      await tester.tapAt(_side(tester, trailing: true));
      expect(value, 2);

      await tester.tapAt(_side(tester, trailing: false));
      expect(value, 1);
      await pump();
      value = 0;
      await pump();
      await tester.tapAt(_side(tester, trailing: false));
      expect(value, 0);
    });
  });

  test('control sources use the catalog and not raw framework design libs', () {
    const paths = [
      'lib/src/widgets/lingyun_toggle.dart',
      'lib/src/widgets/lingyun_slider.dart',
      'lib/src/widgets/lingyun_stepper.dart',
      'lib/src/tokens/control_metrics.dart',
      'example/lib/pages/form_controls_page.dart',
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
      expect(source.contains('Color(0x'), isFalse, reason: path);
      expect(source.contains('LiquidGlassStyle'), isFalse, reason: path);
      expect(source.contains('MaterialTier'), isFalse, reason: path);
    }
  });
}

void _keepBool(bool _) {}

void _keepDouble(double _) {}

void _keepInt(int _) {}

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

ControlLayerView _onlyTrack(WidgetTester tester, Type host) {
  return _tracks(tester, host).single;
}

List<ControlLayerView> _tracks(WidgetTester tester, Type host) {
  final insideKnob = tester
      .widgetList<ControlLayerView>(
        find.descendant(
          of: find.byType(ControlKnobStack),
          matching: find.byType(ControlLayerView),
        ),
      )
      .toSet();
  return tester
      .widgetList<ControlLayerView>(
        find.descendant(
          of: find.byType(host),
          matching: find.byType(ControlLayerView),
        ),
      )
      .where((view) => !insideKnob.contains(view))
      .toList();
}

ControlKnobStack _onlyKnob(WidgetTester tester) {
  return tester.widget<ControlKnobStack>(find.byType(ControlKnobStack));
}

double _knobLeft(WidgetTester tester, Type host) {
  final root = tester.getTopLeft(
    find.descendant(of: find.byType(host), matching: find.byType(Stack)).first,
  );
  final knob = tester.getTopLeft(
    find.descendant(
      of: find.byType(host),
      matching: find.byType(ControlKnobStack),
    ),
  );
  return knob.dx - root.dx;
}

/// Tallest column of pixels that are not the black canvas.
///
/// The dark pressed ring is hollow, so the center column is only the
/// 6pt track. The circumference has to clear about 24pt.
Future<int> _nonBlackSpan(WidgetTester tester, Finder shot) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(shot);
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return (image.width, image.height, data!.buffer.asUint8List());
  });
  final width = bytes!.$1;
  final height = bytes.$2;
  final pixels = bytes.$3;
  var best = 0;
  for (var x = 0; x < width; x++) {
    var first = -1;
    var last = -1;
    for (var y = 0; y < height; y++) {
      final i = (y * width + x) * 4;
      final sum = pixels[i] + pixels[i + 1] + pixels[i + 2];
      if (sum <= 18 * 3) continue;
      first = first < 0 ? y : first;
      last = y;
    }
    if (first >= 0) {
      final span = last - first + 1;
      if (span > best) best = span;
    }
  }
  return best;
}

Clip _stackClip(WidgetTester tester, Type host) {
  return tester
      .widget<Stack>(
        find
            .descendant(of: find.byType(host), matching: find.byType(Stack))
            .first,
      )
      .clipBehavior;
}

Offset _side(WidgetTester tester, {required bool trailing}) {
  final rect = tester.getRect(find.byType(LingyunStepper));
  final dx = trailing ? rect.right - 12 : rect.left + 12;
  return Offset(dx, rect.center.dy);
}
