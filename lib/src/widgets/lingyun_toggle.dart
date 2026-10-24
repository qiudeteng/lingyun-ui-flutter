import 'package:cupertino_ui/cupertino_ui.dart';

import '../tokens/control_layer_style.dart';
import '../tokens/control_metrics.dart';
import 'control_brightness.dart';
import 'control_layer_view.dart';

/// iOS 27 switch. Track and knob come from [ControlLayerCatalog].
///
/// Not a Materials tier and not Liquid Glass. Colors are the Controls
/// layer styles only — this widget does not pick its own fills.
///
/// * Off / on select unfilled / filled tracks.
/// * Pressed (or [forcePressed]) uses the clicked track and the clicked
///   knob stack (shadow under glow).
/// * Disabled is `onChanged == null`. The kit has no filled-disabled
///   track, so the whole pill uses the unfilled disabled track. The knob
///   still sits on the side of [value].
/// * Dark idle has no knob layer. Nothing white is invented. Pressed
///   still draws the clicked rings.
///
/// Shape is a 64×28 pill with a 24pt circle, inset 2. Those sizes are
/// [ControlMetrics], not layer-style fields. The stack does not clip, so
/// the blur-36 shadow can extend past the pill. Leave room around it.
class LingyunToggle extends StatefulWidget {
  const LingyunToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.brightness,
    this.forcePressed = false,
    this.semanticLabel,
  });

  /// On when true. The knob sits on the trailing side.
  final bool value;

  /// Called with the next value. Null disables the control.
  final ValueChanged<bool>? onChanged;

  /// Overrides the ambient brightness. The gallery passes the theme.
  final Brightness? brightness;

  /// Pins the clicked track and knob. Disabled controls ignore this.
  final bool forcePressed;

  /// Accessibility name. The gallery passes Simplified Chinese.
  final String? semanticLabel;

  bool get enabled => onChanged != null;

  @override
  State<LingyunToggle> createState() => _LingyunToggleState();
}

class _LingyunToggleState extends State<LingyunToggle> {
  bool _pressed = false;

  bool get _clicked => widget.enabled && (_pressed || widget.forcePressed);

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _commit() {
    if (!widget.enabled) return;
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = controlBrightnessOf(context, widget.brightness);
    final catalog = ControlLayerCatalog.forBrightness(brightness);
    final style = widget.enabled
        ? catalog.track(
            widget.value ? ControlTrackFill.filled : ControlTrackFill.unfilled,
            _clicked ? ControlTrackState.clicked : ControlTrackState.idle,
          )!
        : catalog.track(ControlTrackFill.unfilled, ControlTrackState.disabled)!;
    final drawKnob = _clicked || catalog.knobIdle != null;
    final knobLeft = widget.value
        ? ControlMetrics.toggleTrackWidth -
              ControlMetrics.toggleKnobInset -
              ControlMetrics.knobDiameter
        : ControlMetrics.toggleKnobInset;

    return Semantics(
      container: true,
      toggled: widget.value,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapCancel: () => _setPressed(false),
        onTapUp: widget.enabled
            ? (_) {
                _commit();
                _setPressed(false);
              }
            : null,
        child: SizedBox(
          width: ControlMetrics.toggleTrackWidth,
          height: ControlMetrics.toggleTrackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ControlLayerView(
                style: style,
                width: ControlMetrics.toggleTrackWidth,
                height: ControlMetrics.toggleTrackHeight,
                borderRadius: ControlMetrics.stadium(
                  ControlMetrics.toggleTrackHeight,
                ),
              ),
              if (drawKnob)
                Positioned(
                  left: knobLeft,
                  top: ControlMetrics.toggleKnobInset,
                  child: ControlKnobStack(
                    brightness: brightness,
                    width: ControlMetrics.knobDiameter,
                    height: ControlMetrics.knobDiameter,
                    clicked: _clicked,
                    borderRadius: ControlMetrics.stadium(
                      ControlMetrics.knobDiameter,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
