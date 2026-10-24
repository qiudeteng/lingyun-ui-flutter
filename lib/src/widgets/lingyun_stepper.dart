import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import '../tokens/control_layer_style.dart';
import '../tokens/control_metrics.dart';
import '../tokens/lingyun_colors.dart';
import 'control_brightness.dart';
import 'control_layer_view.dart';

/// Which end of a [LingyunStepper] is pressed.
enum LingyunStepperSide {
  /// Leading minus.
  decrement,

  /// Trailing plus.
  increment,
}

/// iOS 27 stepper. 92×32, minus and plus.
///
/// Sketch publishes no Stepper layer style and no knob for it. This
/// control does not invent one. The plate reuses the unfilled track
/// (idle, clicked on the held side, disabled when [onChanged] is null).
/// The hairline is [LingyunSeparatorColors.nonOpaque]. The glyphs use
/// label primary, or tertiary when that side cannot move.
///
/// Not a Materials tier and not Liquid Glass. No knob is drawn.
class LingyunStepper extends StatefulWidget {
  const LingyunStepper({
    super.key,
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.brightness,
    this.forcePressed,
    this.decrementLabel,
    this.incrementLabel,
  });

  final int value;

  /// Called with the next value. Null disables both sides.
  final ValueChanged<int>? onChanged;

  /// Lowest value. The minus side stops here.
  final int? min;

  /// Highest value. The plus side stops here.
  final int? max;

  /// Amount added or removed. Must be positive.
  final int step;

  /// Overrides the ambient brightness. The gallery passes the theme.
  final Brightness? brightness;

  /// Pins the clicked plate on one side. Ignored when that side is stopped.
  final LingyunStepperSide? forcePressed;

  /// Accessibility name for minus. The gallery passes 减少.
  final String? decrementLabel;

  /// Accessibility name for plus. The gallery passes 增加.
  final String? incrementLabel;

  bool get enabled => onChanged != null;

  @override
  State<LingyunStepper> createState() => _LingyunStepperState();
}

class _LingyunStepperState extends State<LingyunStepper> {
  LingyunStepperSide? _held;

  bool get _canDecrement =>
      widget.enabled && (widget.min == null || widget.value > widget.min!);

  bool get _canIncrement =>
      widget.enabled && (widget.max == null || widget.value < widget.max!);

  bool _allows(LingyunStepperSide side) {
    return side == LingyunStepperSide.decrement ? _canDecrement : _canIncrement;
  }

  LingyunStepperSide? get _visualPress {
    if (_held != null && _allows(_held!)) return _held;
    final forced = widget.forcePressed;
    if (forced != null && _allows(forced)) return forced;
    return null;
  }

  void _setHeld(LingyunStepperSide? side) {
    if (_held == side) return;
    setState(() => _held = side);
  }

  void _commit(LingyunStepperSide side) {
    final onChanged = widget.onChanged;
    if (onChanged == null || !_allows(side)) return;
    if (side == LingyunStepperSide.decrement) {
      final next = widget.value - widget.step;
      onChanged(widget.min == null ? next : math.max(widget.min!, next));
    } else {
      final next = widget.value + widget.step;
      onChanged(widget.max == null ? next : math.min(widget.max!, next));
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.step > 0, 'LingyunStepper.step must be positive.');
    final brightness = controlBrightnessOf(context, widget.brightness);
    final catalog = ControlLayerCatalog.forBrightness(brightness);
    final colors = LingyunColors.forBrightness(brightness);
    final base = catalog.track(
      ControlTrackFill.unfilled,
      widget.enabled ? ControlTrackState.idle : ControlTrackState.disabled,
    )!;
    final clicked = catalog.track(
      ControlTrackFill.unfilled,
      ControlTrackState.clicked,
    )!;
    final pressed = _visualPress;
    final width = ControlMetrics.stepperWidth;
    final height = ControlMetrics.stepperHeight;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ControlLayerView(
            style: base,
            width: width,
            height: height,
            borderRadius: ControlMetrics.stadium(height),
          ),
          if (pressed != null)
            ClipRect(
              clipper: _HalfClip(pressed),
              child: ControlLayerView(
                style: clicked,
                width: width,
                height: height,
                borderRadius: ControlMetrics.stadium(height),
              ),
            ),
          Positioned(
            left: width / 2 - 0.5,
            top: 8,
            bottom: 8,
            width: 1,
            child: ColoredBox(color: colors.separators.nonOpaque),
          ),
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Side(
                    side: LingyunStepperSide.decrement,
                    enabled: _canDecrement,
                    color: _canDecrement
                        ? colors.labels.primary
                        : colors.labels.tertiary,
                    label: widget.decrementLabel,
                    onDown: () => _setHeld(LingyunStepperSide.decrement),
                    onUp: () {
                      _setHeld(null);
                      _commit(LingyunStepperSide.decrement);
                    },
                    onCancel: () => _setHeld(null),
                  ),
                ),
                Expanded(
                  child: _Side(
                    side: LingyunStepperSide.increment,
                    enabled: _canIncrement,
                    color: _canIncrement
                        ? colors.labels.primary
                        : colors.labels.tertiary,
                    label: widget.incrementLabel,
                    onDown: () => _setHeld(LingyunStepperSide.increment),
                    onUp: () {
                      _setHeld(null);
                      _commit(LingyunStepperSide.increment);
                    },
                    onCancel: () => _setHeld(null),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.side,
    required this.enabled,
    required this.color,
    required this.label,
    required this.onDown,
    required this.onUp,
    required this.onCancel,
  });

  final LingyunStepperSide side;
  final bool enabled;
  final Color color;
  final String? label;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => onDown() : null,
        onTapUp: enabled ? (_) => onUp() : null,
        onTapCancel: onCancel,
        child: CustomPaint(
          painter: _StepperGlyphPainter(
            plus: side == LingyunStepperSide.increment,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _HalfClip extends CustomClipper<Rect> {
  const _HalfClip(this.side);

  final LingyunStepperSide side;

  @override
  Rect getClip(Size size) {
    if (side == LingyunStepperSide.decrement) {
      return Rect.fromLTWH(0, 0, size.width / 2, size.height);
    }
    return Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(covariant _HalfClip oldClipper) {
    return oldClipper.side != side;
  }
}

class _StepperGlyphPainter extends CustomPainter {
  const _StepperGlyphPainter({required this.plus, required this.color});

  final bool plus;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final center = size.center(Offset.zero);
    const arm = 6.5;
    canvas.drawLine(
      center - const Offset(arm, 0),
      center + const Offset(arm, 0),
      paint,
    );
    if (!plus) return;
    canvas.drawLine(
      center - const Offset(0, arm),
      center + const Offset(0, arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StepperGlyphPainter oldDelegate) {
    return oldDelegate.plus != plus || oldDelegate.color != color;
  }
}
