import 'package:cupertino_ui/cupertino_ui.dart';

import '../tokens/control_layer_style.dart';
import '../tokens/control_metrics.dart';
import 'control_brightness.dart';
import 'control_layer_view.dart';

/// iOS 27 slider. The bar and knob come from [ControlLayerCatalog].
///
/// Not a Materials tier and not Liquid Glass. The track is 6pt tall.
/// A 24pt circle rides it. The filled portion runs from the leading edge
/// to the knob center. The rest is the unfilled track.
///
/// Pressed (drag, or [forcePressed]) uses the clicked track styles and
/// the clicked knob stack: shadow under, glow on top, even when the dark
/// idle knob is null. Those borders are black, so on a black canvas the
/// same alpha is shown in white and the disk stays empty. Disabled is
/// `onChanged == null`. The kit has no filled-disabled track, so the bar
/// is entirely unfilled-disabled and the blue portion is omitted. Dark
/// idle draws no knob.
///
/// The stack does not clip. Leave room for the blur-36 shadow.
class LingyunSlider extends StatefulWidget {
  const LingyunSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.brightness,
    this.forcePressed = false,
    this.semanticLabel,
  });

  /// Current position, between [min] and [max].
  final double value;

  /// Called while the knob moves. Null disables the control.
  final ValueChanged<double>? onChanged;

  /// Called with the value when a tap or drag ends.
  final ValueChanged<double>? onChangeEnd;

  final double min;
  final double max;

  /// Overrides the ambient brightness. The gallery passes the theme.
  final Brightness? brightness;

  /// Pins the clicked track and knob. Disabled controls ignore this.
  final bool forcePressed;

  /// Accessibility name. The gallery passes Simplified Chinese.
  final String? semanticLabel;

  bool get enabled => onChanged != null;

  @override
  State<LingyunSlider> createState() => _LingyunSliderState();
}

class _LingyunSliderState extends State<LingyunSlider> {
  bool _pressed = false;
  double? _last;

  bool get _clicked => widget.enabled && (_pressed || widget.forcePressed);

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  double _valueFor(double dx, double width) {
    final span = widget.max - widget.min;
    final travel = width - ControlMetrics.knobDiameter;
    if (span == 0 || travel <= 0) return widget.min;
    final t = ((dx - ControlMetrics.knobDiameter / 2) / travel).clamp(0.0, 1.0);
    return widget.min + t * span;
  }

  void _emit(double dx, double width) {
    if (!widget.enabled) return;
    final next = _valueFor(dx, width);
    _last = next;
    widget.onChanged!(next);
  }

  void _end() {
    final next = _last;
    _last = null;
    _setPressed(false);
    if (next != null) widget.onChangeEnd?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = controlBrightnessOf(context, widget.brightness);
    final catalog = ControlLayerCatalog.forBrightness(brightness);
    final state = _clicked ? ControlTrackState.clicked : ControlTrackState.idle;
    final unfilled = widget.enabled
        ? catalog.track(ControlTrackFill.unfilled, state)!
        : catalog.track(ControlTrackFill.unfilled, ControlTrackState.disabled)!;
    // Filled + disabled is null in the kit. Skip the blue portion.
    final filled = widget.enabled
        ? catalog.track(ControlTrackFill.filled, state)!
        : null;
    final drawKnob = _clicked || catalog.knobIdle != null;

    return Semantics(
      container: true,
      slider: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      value: widget.value.toString(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final width = maxWidth.isFinite
              ? maxWidth
              : ControlMetrics.unboundedSliderWidth;
          final span = widget.max - widget.min;
          final t = span == 0
              ? 0.0
              : ((widget.value - widget.min) / span).clamp(0.0, 1.0);
          final knobLeft = t * (width - ControlMetrics.knobDiameter);
          final fillWidth = knobLeft + ControlMetrics.knobDiameter / 2;
          final trackTop =
              (ControlMetrics.knobDiameter - ControlMetrics.sliderTrackHeight) /
              2;
          final trackRadius = ControlMetrics.stadium(
            ControlMetrics.sliderTrackHeight,
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: widget.enabled
                ? (details) {
                    _setPressed(true);
                    _emit(details.localPosition.dx, width);
                  }
                : null,
            onTapUp: widget.enabled ? (_) => _end() : null,
            onTapCancel: () => _setPressed(false),
            onHorizontalDragStart: widget.enabled
                ? (details) {
                    _setPressed(true);
                    _emit(details.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragUpdate: widget.enabled
                ? (details) => _emit(details.localPosition.dx, width)
                : null,
            onHorizontalDragEnd: widget.enabled ? (_) => _end() : null,
            onHorizontalDragCancel: () => _setPressed(false),
            child: SizedBox(
              width: width,
              height: ControlMetrics.knobDiameter,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    width: width,
                    top: trackTop,
                    height: ControlMetrics.sliderTrackHeight,
                    child: Stack(
                      children: [
                        ControlLayerView(
                          style: unfilled,
                          width: width,
                          height: ControlMetrics.sliderTrackHeight,
                          borderRadius: trackRadius,
                        ),
                        if (filled != null)
                          ClipRect(
                            clipper: _LeftWidthClip(fillWidth),
                            child: ControlLayerView(
                              style: filled,
                              width: width,
                              height: ControlMetrics.sliderTrackHeight,
                              borderRadius: trackRadius,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (drawKnob)
                    Positioned(
                      left: knobLeft,
                      top: 0,
                      child: ControlKnobStack(
                        brightness: brightness,
                        width: ControlMetrics.knobDiameter,
                        height: ControlMetrics.knobDiameter,
                        clicked: _clicked,
                        showRingOnBlack: true,
                        borderRadius: ControlMetrics.stadium(
                          ControlMetrics.knobDiameter,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Keeps the leading cap of the pill and cuts a straight edge at the knob
/// center. The layer style itself has no radius.
class _LeftWidthClip extends CustomClipper<Rect> {
  const _LeftWidthClip(this.width);

  final double width;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, width, size.height);

  @override
  bool shouldReclip(covariant _LeftWidthClip oldClipper) {
    return oldClipper.width != width;
  }
}
