import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  group('ControlLayerCatalog', () {
    test('filled tracks use system blue and a clicked veil', () {
      final light = ControlLayerCatalog.light;
      final dark = ControlLayerCatalog.dark;

      expect(
        light.track(ControlTrackFill.filled, ControlTrackState.idle)!.fills,
        [LingyunColors.light.system.blue],
      );
      expect(
        dark.track(ControlTrackFill.filled, ControlTrackState.idle)!.fills,
        [LingyunColors.dark.system.blue],
      );
      expect(
        light.track(ControlTrackFill.filled, ControlTrackState.clicked)!.fills,
        [const Color(0xFF0088FF), const Color(0x14000000)],
      );
      expect(
        dark.track(ControlTrackFill.filled, ControlTrackState.clicked)!.fills,
        [const Color(0xFF0091FF), const Color(0x14FFFFFF)],
      );
      expect(
        light.track(ControlTrackFill.filled, ControlTrackState.disabled),
        isNull,
      );
      expect(
        dark.track(ControlTrackFill.filled, ControlTrackState.disabled),
        isNull,
      );
    });

    test('unfilled tracks are the Sketch alphas, disabled matches idle', () {
      final light = ControlLayerCatalog.light;
      expect(
        light.track(ControlTrackFill.unfilled, ControlTrackState.idle)!.fills,
        [const Color(0x1A000000)],
      );
      expect(
        light
            .track(ControlTrackFill.unfilled, ControlTrackState.clicked)!
            .fills,
        [const Color(0x30000000)],
      );
      expect(
        light
            .track(ControlTrackFill.unfilled, ControlTrackState.disabled)!
            .fills,
        light.track(ControlTrackFill.unfilled, ControlTrackState.idle)!.fills,
      );

      final dark = ControlLayerCatalog.dark;
      expect(
        dark.track(ControlTrackFill.unfilled, ControlTrackState.idle)!.fills,
        [const Color(0x1AFFFFFF)],
      );
      expect(
        dark.track(ControlTrackFill.unfilled, ControlTrackState.clicked)!.fills,
        [const Color(0x30FFFFFF)],
      );
      expect(
        dark
            .track(ControlTrackFill.unfilled, ControlTrackState.disabled)!
            .fills,
        dark.track(ControlTrackFill.unfilled, ControlTrackState.idle)!.fills,
      );
    });

    test('tracks publish no blur, border, shadow, or radius', () {
      for (final catalog in [
        ControlLayerCatalog.light,
        ControlLayerCatalog.dark,
      ]) {
        for (final fill in ControlTrackFill.values) {
          for (final state in ControlTrackState.values) {
            final style = catalog.track(fill, state);
            if (style == null) continue;
            expect(style.gaussianRadius, isNull, reason: style.sketchName);
            expect(style.blurSaturation, isNull, reason: style.sketchName);
            expect(style.borders, isEmpty, reason: style.sketchName);
            expect(style.shadows, isEmpty, reason: style.sketchName);
          }
        }
      }
    });

    test('light idle knob is white with the Sketch shadow', () {
      final idle = ControlLayerCatalog.light.knob(ControlKnobLayer.idle)!;
      expect(idle.fills, [const Color(0xFFFFFFFF)]);
      expect(idle.gaussianRadius, isNull);
      expect(idle.borders, isEmpty);
      expect(idle.shadows, hasLength(1));
      expect(idle.shadows.single.color, const Color(0x0D000000));
      expect(idle.shadows.single.blurRadius, 36);
      expect(idle.shadows.single.offset, const Offset(0, 3));
      expect(idle.shadows.single.spread, 0);
    });

    test('dark idle knob is absent', () {
      expect(ControlLayerCatalog.dark.knob(ControlKnobLayer.idle), isNull);
      expect(ControlLayerCatalog.dark.knobIdle, isNull);
    });

    test('clicked glow matches Sketch borders', () {
      final light = ControlLayerCatalog.light.knobClickedGlow;
      expect(light.fills, isEmpty);
      expect(light.gaussianRadius, isNull);
      expect(light.borders, [
        const ControlBorder(
          color: Color(0xFFD9D9D9),
          thickness: 1,
          position: ControlBorderPosition.outside,
          blend: ControlBlendMode.plusDarker,
        ),
        const ControlBorder(
          color: Color(0x73FFFFFF),
          thickness: 0.5,
          position: ControlBorderPosition.outside,
          blend: ControlBlendMode.normal,
        ),
      ]);

      final dark = ControlLayerCatalog.dark.knobClickedGlow;
      expect(dark.fills, isEmpty);
      expect(dark.borders.single.color, const Color(0x33000000));
      expect(dark.borders.single.thickness, 1);
      expect(dark.borders.single.position, ControlBorderPosition.outside);
      expect(dark.borders.single.blend, ControlBlendMode.plusDarker);
    });

    test('clicked shadow stores gaussian radius 3 and saturation 0', () {
      for (final style in [
        ControlLayerCatalog.light.knobClickedShadow,
        ControlLayerCatalog.dark.knobClickedShadow,
      ]) {
        expect(style.fills, isEmpty, reason: style.sketchName);
        expect(style.shadows, isEmpty, reason: style.sketchName);
        expect(style.gaussianRadius, 3, reason: style.sketchName);
        expect(style.blurSaturation, 0, reason: style.sketchName);
        expect(style.borders.single.color, const Color(0xFF000000));
        expect(style.borders.single.thickness, 1);
        expect(style.borders.single.position, ControlBorderPosition.inside);
        expect(style.borders.single.blend, ControlBlendMode.normal);
      }
    });

    test('sketch names keep the Controls path', () {
      expect(
        ControlLayerCatalog.light.trackFilledIdle.sketchName,
        'Controls/Light/Tracks/Active, Filled, 01 - Idle',
      );
      expect(
        ControlLayerCatalog.dark.knobClickedShadow.sketchName,
        'Controls/Dark/Knobs - Toggle/03 - Clicked - Shadow',
      );
    });
  });

  testWidgets('track and knob plates build without a glass style', (
    tester,
  ) async {
    final track = ControlLayerCatalog.light.track(
      ControlTrackFill.filled,
      ControlTrackState.idle,
    )!;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            ControlLayerView(
              key: const Key('track-plate'),
              style: track,
              height: 28,
            ),
            const ControlKnobStack(
              key: Key('knob-plate'),
              brightness: Brightness.light,
              width: 48,
              height: 32,
              clicked: true,
            ),
          ],
        ),
      ),
    );
    expect(find.byKey(const Key('track-plate')), findsOneWidget);
    expect(find.byKey(const Key('knob-plate')), findsOneWidget);
    expect(find.byType(ControlLayerView), findsWidgets);
  });
}
