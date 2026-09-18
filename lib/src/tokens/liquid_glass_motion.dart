import 'package:flutter/material.dart';

import '../adaptivity/lingyun_adaptivity.dart';

/// Motion tokens and reduce-motion helpers.
///
/// Curves are platform-agnostic. They are tuned to feel like Liquid Glass
/// (decelerating, slightly springy) on iPhone / iPad / macOS / web without
/// calling any Apple-only animation APIs.
///
/// **Reduce Motion:** durations collapse to [Duration.zero] when
/// [MediaQuery.disableAnimationsOf] is true or [LingyunAdaptivity.reduceMotion]
/// is set. Prefer [durationOf] / [curveOf] instead of hard-coded
/// `Duration`s in later components.
@immutable
class LiquidGlassMotion {
  const LiquidGlassMotion({
    this.quick = const Duration(milliseconds: 180),
    this.standard = const Duration(milliseconds: 360),
    this.emphasized = const Duration(milliseconds: 520),
    this.quickCurve = const Cubic(0.25, 0.1, 0.25, 1.0),
    this.standardCurve = const Cubic(0.22, 1.0, 0.36, 1.0),
    this.emphasizedCurve = const Cubic(0.2, 0.0, 0.0, 1.0),
  });

  /// Shared defaults used by [GlassSurface] hover and the example gallery.
  static const LiquidGlassMotion defaults = LiquidGlassMotion();

  final Duration quick;
  final Duration standard;
  final Duration emphasized;
  final Curve quickCurve;
  final Curve standardCurve;
  final Curve emphasizedCurve;

  /// True when the user (or gallery toggle) asked to minimize motion.
  static bool reduceMotionOf(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return true;
    return LingyunAdaptivity.maybeOf(context)?.reduceMotion ?? false;
  }

  /// [preferred] unless reduce-motion is active, then [Duration.zero].
  static Duration durationOf(BuildContext context, Duration preferred) {
    return reduceMotionOf(context) ? Duration.zero : preferred;
  }

  /// [preferred] unless reduce-motion is active, then [Curves.linear].
  static Curve curveOf(BuildContext context, Curve preferred) {
    return reduceMotionOf(context) ? Curves.linear : preferred;
  }

  LiquidGlassMotion copyWith({
    Duration? quick,
    Duration? standard,
    Duration? emphasized,
    Curve? quickCurve,
    Curve? standardCurve,
    Curve? emphasizedCurve,
  }) {
    return LiquidGlassMotion(
      quick: quick ?? this.quick,
      standard: standard ?? this.standard,
      emphasized: emphasized ?? this.emphasized,
      quickCurve: quickCurve ?? this.quickCurve,
      standardCurve: standardCurve ?? this.standardCurve,
      emphasizedCurve: emphasizedCurve ?? this.emphasizedCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassMotion &&
        other.quick == quick &&
        other.standard == standard &&
        other.emphasized == emphasized &&
        other.quickCurve == quickCurve &&
        other.standardCurve == standardCurve &&
        other.emphasizedCurve == emphasizedCurve;
  }

  @override
  int get hashCode => Object.hash(
    quick,
    standard,
    emphasized,
    quickCurve,
    standardCurve,
    emphasizedCurve,
  );
}
