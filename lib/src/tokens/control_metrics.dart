import 'package:cupertino_ui/cupertino_ui.dart';

/// Symbol-body sizes for Toggle, Slider, and Stepper.
///
/// These are not Control layer-style fields. Sketch layer styles under
/// `Controls/` have no corner radius. The numbers are the artboard bodies
/// measured for the accepted knob/track gallery (`docs/CONTROLS.md`):
///
/// * Toggle artboard 64×28. The idle thumb fill is 24pt, inset 2.
/// * Slider bar inside the slider symbol is 6pt tall. The knob is 24pt.
/// * Stepper artboard 92×32. It has no knob and no track style of its own.
///
/// [stadium] is the caller shape (a pill). It is not a new token.
@immutable
class ControlMetrics {
  const ControlMetrics._();

  /// Shared knob diameter. Toggle and slider symbols are 24pt tall.
  static const double knobDiameter = 24;

  /// Toggle track. Sketch artboard `Toggles/*/1 - Idle` is 64×28.
  static const double toggleTrackWidth = 64;

  /// Toggle track height.
  static const double toggleTrackHeight = 28;

  /// Gap between the toggle thumb and the pill. Centers a 24pt knob.
  static const double toggleKnobInset = (toggleTrackHeight - knobDiameter) / 2;

  /// Slider bar height. The 370×22 symbol also includes tick padding,
  /// which the control does not draw.
  static const double sliderTrackHeight = 6;

  /// Width used only when the incoming max width is unbounded.
  ///
  /// Not a Sketch token. A [Row] gives a non-flex child infinite width;
  /// this keeps that case from failing.
  static const double unboundedSliderWidth = 280;

  /// Stepper artboard. No knob. The plate reuses the unfilled track style.
  static const double stepperWidth = 92;

  /// Stepper artboard height.
  static const double stepperHeight = 32;

  /// Pill shape for a track or knob. Caller geometry, not a layer style.
  static BorderRadius stadium(double extent) {
    return BorderRadius.circular(extent / 2);
  }
}
