import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/physics.dart';

import '../tokens/liquid_glass_motion.dart';

/// Drives a scalar with the system spring, or snaps it when motion is reduced.
///
/// The simulation is [SpringDescription.withDurationAndBounce], which Flutter
/// documents as the same formula as SwiftUI's duration-and-bounce spring.
/// The bounce argument is omitted, so it stays at that API's default
/// (0, critically damped). Apple has not published a stiffness or bounce for
/// the Liquid Glass selection lens, so this file does not store one and does
/// not add a kit token.
///
/// The duration argument is the existing [LiquidGlassMotion.quick]
/// approximation already used by glass buttons and the tab lens. It is not
/// a new number and not a published Apple spring.
///
/// Reduce Motion ([LiquidGlassMotion.reduceMotionOf], including
/// [MediaQuery.disableAnimations]) skips the simulation. WWDC25 "Meet Liquid
/// Glass" turns elasticity off in that mode; the value lands on the target
/// immediately. That matches the segmented-control acceptance note that a
/// jump, with no lens flight, is an acceptable fallback.
class LiquidGlassSpringValue extends StatefulWidget {
  const LiquidGlassSpringValue({
    super.key,
    required this.value,
    required this.builder,
  });

  /// Rest position. Changes spring toward the new value.
  final double value;

  final Widget Function(BuildContext context, double value) builder;

  @override
  State<LiquidGlassSpringValue> createState() => _LiquidGlassSpringValueState();
}

class _LiquidGlassSpringValueState extends State<LiquidGlassSpringValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: widget.value,
    );
  }

  @override
  void didUpdateWidget(LiquidGlassSpringValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    _go(widget.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LiquidGlassMotion.reduceMotionOf(context) &&
        _controller.value != widget.value) {
      _controller.stop();
      _controller.value = widget.value;
    }
  }

  void _go(double target) {
    if (LiquidGlassMotion.reduceMotionOf(context)) {
      _controller.stop();
      _controller.value = target;
      return;
    }
    _controller.animateWith(
      SpringSimulation(
        SpringDescription.withDurationAndBounce(
          duration: LiquidGlassMotion.defaults.quick,
        ),
        _controller.value,
        target,
        _controller.velocity,
        snapToEnd: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(context, _controller.value),
    );
  }
}
