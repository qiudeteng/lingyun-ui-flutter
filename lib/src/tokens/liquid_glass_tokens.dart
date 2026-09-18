import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';

/// Design tokens for Apple Liquid Glass–inspired surfaces.
@immutable
class LiquidGlassTokens {
  const LiquidGlassTokens({
    required this.blurSigma,
    required this.saturation,
    required this.tintColor,
    required this.edgeHighlightColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.opaqueFallbackColor,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.shadowOffset,
  });

  /// Gaussian blur sigma applied via [ImageFilter.blur].
  final double blurSigma;

  /// Color matrix saturation multiplier (1.0 = unchanged).
  final double saturation;

  /// Translucent fill tint layered over the blurred backdrop.
  final Color tintColor;

  /// Soft inner-edge specular highlight.
  final Color edgeHighlightColor;

  /// Outer border stroke color.
  final Color borderColor;

  /// Outer border stroke width.
  final double borderWidth;

  /// Corner radius for the glass clip.
  final BorderRadius borderRadius;

  /// Solid fill used when transparency effects are reduced / high contrast.
  final Color opaqueFallbackColor;

  /// Soft drop shadow under the glass.
  final Color shadowColor;

  /// Shadow blur radius.
  final double shadowBlurRadius;

  /// Shadow offset.
  final Offset shadowOffset;

  /// Preset for light appearance.
  static const LiquidGlassTokens light = LiquidGlassTokens(
    blurSigma: 28,
    saturation: 1.35,
    tintColor: Color(0x66FFFFFF),
    edgeHighlightColor: Color(0xB3FFFFFF),
    borderColor: Color(0x59FFFFFF),
    borderWidth: 1.0,
    borderRadius: BorderRadius.all(Radius.circular(24)),
    opaqueFallbackColor: Color(0xF2F5F5F7),
    shadowColor: Color(0x1A000000),
    shadowBlurRadius: 24,
    shadowOffset: Offset(0, 8),
  );

  /// Preset for dark appearance.
  static const LiquidGlassTokens dark = LiquidGlassTokens(
    blurSigma: 32,
    saturation: 1.25,
    tintColor: Color(0x591A1A1E),
    edgeHighlightColor: Color(0x66FFFFFF),
    borderColor: Color(0x40FFFFFF),
    borderWidth: 1.0,
    borderRadius: BorderRadius.all(Radius.circular(24)),
    opaqueFallbackColor: Color(0xF21C1C1E),
    shadowColor: Color(0x40000000),
    shadowBlurRadius: 28,
    shadowOffset: Offset(0, 10),
  );

  ImageFilter get blurFilter =>
      ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);

  /// 5×4 color matrix that scales RGB saturation around luminance.
  List<double> get saturationMatrix {
    final s = saturation;
    final inv = 1.0 - s;
    const r = 0.2126;
    const g = 0.7152;
    const b = 0.0722;
    return <double>[
      inv * r + s,
      inv * g,
      inv * b,
      0,
      0,
      inv * r,
      inv * g + s,
      inv * b,
      0,
      0,
      inv * r,
      inv * g,
      inv * b + s,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  LiquidGlassTokens copyWith({
    double? blurSigma,
    double? saturation,
    Color? tintColor,
    Color? edgeHighlightColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    Color? opaqueFallbackColor,
    Color? shadowColor,
    double? shadowBlurRadius,
    Offset? shadowOffset,
  }) {
    return LiquidGlassTokens(
      blurSigma: blurSigma ?? this.blurSigma,
      saturation: saturation ?? this.saturation,
      tintColor: tintColor ?? this.tintColor,
      edgeHighlightColor: edgeHighlightColor ?? this.edgeHighlightColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      opaqueFallbackColor: opaqueFallbackColor ?? this.opaqueFallbackColor,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
    );
  }

  LiquidGlassTokens lerp(LiquidGlassTokens other, double t) {
    return LiquidGlassTokens(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
      saturation: lerpDouble(saturation, other.saturation, t)!,
      tintColor: Color.lerp(tintColor, other.tintColor, t)!,
      edgeHighlightColor: Color.lerp(
        edgeHighlightColor,
        other.edgeHighlightColor,
        t,
      )!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      opaqueFallbackColor: Color.lerp(
        opaqueFallbackColor,
        other.opaqueFallbackColor,
        t,
      )!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      shadowBlurRadius: lerpDouble(
        shadowBlurRadius,
        other.shadowBlurRadius,
        t,
      )!,
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassTokens &&
        other.blurSigma == blurSigma &&
        other.saturation == saturation &&
        other.tintColor == tintColor &&
        other.edgeHighlightColor == edgeHighlightColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.borderRadius == borderRadius &&
        other.opaqueFallbackColor == opaqueFallbackColor &&
        other.shadowColor == shadowColor &&
        other.shadowBlurRadius == shadowBlurRadius &&
        other.shadowOffset == shadowOffset;
  }

  @override
  int get hashCode => Object.hash(
    blurSigma,
    saturation,
    tintColor,
    edgeHighlightColor,
    borderColor,
    borderWidth,
    borderRadius,
    opaqueFallbackColor,
    shadowColor,
    shadowBlurRadius,
    shadowOffset,
  );
}
