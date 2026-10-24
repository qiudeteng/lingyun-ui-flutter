import 'package:cupertino_ui/cupertino_ui.dart';

/// Which shared track fill a form control is asking for.
///
/// Sketch group `Controls/{Light|Dark}/Tracks`.
enum ControlTrackFill {
  /// `Active, Filled`. On-state / value portion.
  filled,

  /// `Active, Unfilled`. The rest of the track.
  unfilled,
}

/// Sketch state suffix on a Controls layer style.
///
/// `01 - Idle`, `03 - Clicked`, `04 - Disabled`. There is no `02`.
enum ControlTrackState {
  /// `01 - Idle`.
  idle,

  /// `03 - Clicked`.
  clicked,

  /// `04 - Disabled`. Published for unfilled tracks only.
  disabled,
}

/// Knob layer inside `Controls/{Light|Dark}/Knobs - Toggle`.
enum ControlKnobLayer {
  /// `01 - Idle`. Published for Light only.
  idle,

  /// `03 - Clicked - Glow`. Borders, no fill.
  clickedGlow,

  /// `03 - Clicked - Shadow`. Inside border plus a layer blur.
  clickedShadow,
}

/// Sketch border blend. `normal` or `plus darker`.
///
/// Flutter has no Plus Darker. The painter does not invent that blend;
/// it records the kit mode and draws the border color with source-over.
/// See `docs/CONTROLS.md`.
enum ControlBlendMode {
  /// Sketch `normal`.
  normal,

  /// Sketch `plus darker`.
  plusDarker,
}

/// Sketch border position.
enum ControlBorderPosition {
  /// Stroke sits inside the shape.
  inside,

  /// Stroke sits outside the shape.
  outside,
}

/// One Sketch border on a Controls layer style.
@immutable
class ControlBorder {
  const ControlBorder({
    required this.color,
    required this.thickness,
    required this.position,
    required this.blend,
  });

  final Color color;

  /// Sketch thickness, in points. `1` or `0.5` on the glow style.
  final double thickness;

  final ControlBorderPosition position;
  final ControlBlendMode blend;

  @override
  bool operator ==(Object other) {
    return other is ControlBorder &&
        other.color == color &&
        other.thickness == thickness &&
        other.position == position &&
        other.blend == blend;
  }

  @override
  int get hashCode => Object.hash(color, thickness, position, blend);
}

/// One Sketch drop shadow. The blur field is a radius, not a sigma.
@immutable
class ControlDropShadow {
  const ControlDropShadow({
    required this.color,
    required this.blurRadius,
    required this.offset,
    this.spread = 0,
  });

  final Color color;

  /// Sketch shadow `blur`, in points. Not an `ImageFilter` sigma.
  final double blurRadius;

  final Offset offset;
  final double spread;

  @override
  bool operator ==(Object other) {
    return other is ControlDropShadow &&
        other.color == color &&
        other.blurRadius == blurRadius &&
        other.offset == offset &&
        other.spread == spread;
  }

  @override
  int get hashCode => Object.hash(color, blurRadius, offset, spread);
}

/// One shared Controls layer style from the iOS 27 Sketch UI Kit.
///
/// These styles are fills, borders, and shadows for form tracks and
/// knobs. They are not [MaterialTier] recipes and not Liquid Glass
/// Clear / Regular / Dock. The kit does not publish a backdrop blur
/// sigma or a corner radius on them.
@immutable
class ControlLayerStyle {
  const ControlLayerStyle({
    required this.sketchName,
    this.fills = const [],
    this.borders = const [],
    this.shadows = const [],
    this.gaussianRadius,
    this.blurSaturation,
  });

  /// Sketch layer-style path, such as
  /// `Controls/Light/Tracks/Active, Filled, 01 - Idle`.
  final String sketchName;

  /// Enabled color fills, bottom to top. Sketch `fills`.
  final List<Color> fills;

  /// Enabled borders, in Sketch order.
  final List<ControlBorder> borders;

  /// Enabled drop shadows. Empty on every style except the light idle knob.
  final List<ControlDropShadow> shadows;

  /// Sketch gaussian **layer** blur radius, in points.
  ///
  /// Set only on Clicked - Shadow (`radius: 3` in the inspector). Tracks
  /// and the idle knob export `blurs: []`. This is not a backdrop sigma.
  /// The DTCG token export omitted the effect; the inspector on the same
  /// share still has it.
  final double? gaussianRadius;

  /// Sketch blur `saturation` beside [gaussianRadius].
  ///
  /// The kit value is 0. This package stores it and does not treat 0 as
  /// “paint grayscale”.
  final double? blurSaturation;

  @override
  bool operator ==(Object other) {
    if (other is! ControlLayerStyle) return false;
    return other.sketchName == sketchName &&
        _listEq(other.fills, fills) &&
        _listEq(other.borders, borders) &&
        _listEq(other.shadows, shadows) &&
        other.gaussianRadius == gaussianRadius &&
        other.blurSaturation == blurSaturation;
  }

  @override
  int get hashCode => Object.hash(
    sketchName,
    Object.hashAll(fills),
    Object.hashAll(borders),
    Object.hashAll(shadows),
    gaussianRadius,
    blurSaturation,
  );
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Light and dark Controls catalogs.
///
/// Source: Sketch share `04c24d8b-38fb-4afb-8836-36617e022f02`, document
/// “Apple iOS 27 UI Kit”, layer styles under `Controls/`. Filled track
/// color is the System Blue variable (`LingyunColors.system.blue`).
/// Fractional alphas are the kit’s 8-bit storage of the Sketch alpha
/// (0.45 → 115, 0.2 → 51, 0.19 → 48, 0.1 → 26, 0.08 → 20, 0.05 → 13).
@immutable
class ControlLayerCatalog {
  const ControlLayerCatalog({
    required this.brightness,
    required this.trackFilledIdle,
    required this.trackFilledClicked,
    required this.trackUnfilledIdle,
    required this.trackUnfilledClicked,
    required this.trackUnfilledDisabled,
    required this.knobClickedGlow,
    required this.knobClickedShadow,
    this.knobIdle,
  });

  final Brightness brightness;

  final ControlLayerStyle trackFilledIdle;
  final ControlLayerStyle trackFilledClicked;
  final ControlLayerStyle trackUnfilledIdle;
  final ControlLayerStyle trackUnfilledClicked;
  final ControlLayerStyle trackUnfilledDisabled;

  /// Null in dark: Sketch has no `Controls/Dark/Knobs - Toggle/01 - Idle`.
  final ControlLayerStyle? knobIdle;

  final ControlLayerStyle knobClickedGlow;
  final ControlLayerStyle knobClickedShadow;

  static const ControlLayerCatalog light = ControlLayerCatalog(
    brightness: Brightness.light,
    trackFilledIdle: ControlLayerStyle(
      sketchName: 'Controls/Light/Tracks/Active, Filled, 01 - Idle',
      fills: [_lightBlue],
    ),
    trackFilledClicked: ControlLayerStyle(
      sketchName: 'Controls/Light/Tracks/Active, Filled, 03 - Clicked',
      fills: [_lightBlue, _black08],
    ),
    trackUnfilledIdle: ControlLayerStyle(
      sketchName: 'Controls/Light/Tracks/Active, Unfilled, 01 - Idle',
      fills: [_black10],
    ),
    trackUnfilledClicked: ControlLayerStyle(
      sketchName: 'Controls/Light/Tracks/Active, Unfilled, 03 - Clicked',
      fills: [_black19],
    ),
    trackUnfilledDisabled: ControlLayerStyle(
      sketchName: 'Controls/Light/Tracks/Active, Unfilled, 04 - Disabled',
      fills: [_black10],
    ),
    knobIdle: ControlLayerStyle(
      sketchName: 'Controls/Light/Knobs - Toggle/01 - Idle',
      fills: [_white],
      shadows: [
        ControlDropShadow(
          color: _black05,
          blurRadius: 36,
          offset: Offset(0, 3),
        ),
      ],
    ),
    knobClickedGlow: ControlLayerStyle(
      sketchName: 'Controls/Light/Knobs - Toggle/03 - Clicked - Glow',
      borders: [
        ControlBorder(
          color: _glowGray,
          thickness: 1,
          position: ControlBorderPosition.outside,
          blend: ControlBlendMode.plusDarker,
        ),
        ControlBorder(
          color: _white45,
          thickness: 0.5,
          position: ControlBorderPosition.outside,
          blend: ControlBlendMode.normal,
        ),
      ],
    ),
    knobClickedShadow: _clickedShadowLight,
  );

  static const ControlLayerCatalog dark = ControlLayerCatalog(
    brightness: Brightness.dark,
    trackFilledIdle: ControlLayerStyle(
      sketchName: 'Controls/Dark/Tracks/Active, Filled, 01 - Idle',
      fills: [_darkBlue],
    ),
    trackFilledClicked: ControlLayerStyle(
      sketchName: 'Controls/Dark/Tracks/Active, Filled, 03 - Clicked',
      fills: [_darkBlue, _white08],
    ),
    trackUnfilledIdle: ControlLayerStyle(
      sketchName: 'Controls/Dark/Tracks/Active, Unfilled, 01 - Idle',
      fills: [_white10],
    ),
    trackUnfilledClicked: ControlLayerStyle(
      sketchName: 'Controls/Dark/Tracks/Active, Unfilled, 03 - Clicked',
      fills: [_white19],
    ),
    trackUnfilledDisabled: ControlLayerStyle(
      sketchName: 'Controls/Dark/Tracks/Active, Unfilled, 04 - Disabled',
      fills: [_white10],
    ),
    knobClickedGlow: ControlLayerStyle(
      sketchName: 'Controls/Dark/Knobs - Toggle/03 - Clicked - Glow',
      borders: [
        ControlBorder(
          color: _black20,
          thickness: 1,
          position: ControlBorderPosition.outside,
          blend: ControlBlendMode.plusDarker,
        ),
      ],
    ),
    knobClickedShadow: _clickedShadowDark,
  );

  static ControlLayerCatalog forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  /// Track style, or null when Sketch does not publish that state.
  ///
  /// Filled + disabled is null in both schemes.
  ControlLayerStyle? track(ControlTrackFill fill, ControlTrackState state) {
    return switch ((fill, state)) {
      (ControlTrackFill.filled, ControlTrackState.idle) => trackFilledIdle,
      (ControlTrackFill.filled, ControlTrackState.clicked) =>
        trackFilledClicked,
      (ControlTrackFill.filled, ControlTrackState.disabled) => null,
      (ControlTrackFill.unfilled, ControlTrackState.idle) => trackUnfilledIdle,
      (ControlTrackFill.unfilled, ControlTrackState.clicked) =>
        trackUnfilledClicked,
      (ControlTrackFill.unfilled, ControlTrackState.disabled) =>
        trackUnfilledDisabled,
    };
  }

  /// Knob layer, or null when Sketch does not publish it (dark idle).
  ControlLayerStyle? knob(ControlKnobLayer layer) {
    return switch (layer) {
      ControlKnobLayer.idle => knobIdle,
      ControlKnobLayer.clickedGlow => knobClickedGlow,
      ControlKnobLayer.clickedShadow => knobClickedShadow,
    };
  }
}

// Sketch alphas stored in 8 bits. See the catalog dartdoc.
/// System Colors / Light / Blue. Same value as `LingyunColors.light.system.blue`.
const Color _lightBlue = Color(0xFF0088FF);

/// System Colors / Dark / Blue. Same value as `LingyunColors.dark.system.blue`.
const Color _darkBlue = Color(0xFF0091FF);

const Color _white = Color(0xFFFFFFFF);
const Color _white45 = Color(0x73FFFFFF);
const Color _white19 = Color(0x30FFFFFF);
const Color _white10 = Color(0x1AFFFFFF);
const Color _white08 = Color(0x14FFFFFF);
const Color _black20 = Color(0x33000000);
const Color _black19 = Color(0x30000000);
const Color _black10 = Color(0x1A000000);
const Color _black08 = Color(0x14000000);
const Color _black05 = Color(0x0D000000);

/// `#D9D9D9`. Light glow’s first border. `fillType` is color; the inspector
/// gradient stops are unused and are not painted.
const Color _glowGray = Color(0xFFD9D9D9);

const ControlLayerStyle _clickedShadowLight = ControlLayerStyle(
  sketchName: 'Controls/Light/Knobs - Toggle/03 - Clicked - Shadow',
  borders: [
    ControlBorder(
      color: Color(0xFF000000),
      thickness: 1,
      position: ControlBorderPosition.inside,
      blend: ControlBlendMode.normal,
    ),
  ],
  gaussianRadius: 3,
  blurSaturation: 0,
);

const ControlLayerStyle _clickedShadowDark = ControlLayerStyle(
  sketchName: 'Controls/Dark/Knobs - Toggle/03 - Clicked - Shadow',
  borders: [
    ControlBorder(
      color: Color(0xFF000000),
      thickness: 1,
      position: ControlBorderPosition.inside,
      blend: ControlBlendMode.normal,
    ),
  ],
  gaussianRadius: 3,
  blurSaturation: 0,
);
