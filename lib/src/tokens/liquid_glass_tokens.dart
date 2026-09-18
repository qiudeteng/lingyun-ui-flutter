import 'dart:ui' show ImageFilter, TileMode, lerpDouble;

import 'package:flutter/material.dart';

import 'glass_material.dart';

/// Design tokens for Liquid Glass–inspired surfaces.
///
/// ## Specular / refraction conventions
///
/// These are **visual recipes**, not Apple private APIs. They apply on
/// iPhone, foldables, iPad, macOS, and web:
///
/// * **Specular highlight** ([edgeHighlightColor]) — a directional wash on
///   the glass *face*. Treat the light as coming from the **top-leading**
///   corner; the gradient fades toward the bottom-trailing edge. Do not use
///   this wash as a focus ring.
/// * **Refraction rim** ([refractionColor], [refractionWidth]) — a thinner,
///   brighter inner stroke that suggests light bending at the glass edge.
///   It sits just inside the outer [borderColor] hairline.
/// * **Hover** (pointer platforms) may boost specular opacity; touch
///   platforms simply never fire `MouseRegion.onEnter`.
///
/// [light] / [dark] are the **regular** tier presets. Resolve thin / thick
/// with [LiquidGlassMaterials] or [forTier].
@immutable
class LiquidGlassTokens {
  const LiquidGlassTokens({
    required this.blurSigma,
    required this.saturation,
    required this.tintColor,
    required this.edgeHighlightColor,
    required this.refractionColor,
    required this.refractionWidth,
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

  /// Specular face highlight (top-leading → bottom-trailing).
  final Color edgeHighlightColor;

  /// Inner refraction rim color.
  final Color refractionColor;

  /// Inner refraction rim width in logical pixels.
  final double refractionWidth;

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

  /// Regular-tier preset for light appearance.
  static const LiquidGlassTokens light = LiquidGlassTokens(
    blurSigma: 28,
    saturation: 1.35,
    tintColor: Color(0x66FFFFFF),
    edgeHighlightColor: Color(0xB3FFFFFF),
    refractionColor: Color(0x99FFFFFF),
    refractionWidth: 1.0,
    borderColor: Color(0x59FFFFFF),
    borderWidth: 1.0,
    borderRadius: BorderRadius.all(Radius.circular(24)),
    opaqueFallbackColor: Color(0xF2F5F5F7),
    shadowColor: Color(0x1A000000),
    shadowBlurRadius: 24,
    shadowOffset: Offset(0, 8),
  );

  /// Regular-tier preset for dark appearance.
  static const LiquidGlassTokens dark = LiquidGlassTokens(
    blurSigma: 32,
    saturation: 1.25,
    tintColor: Color(0x591A1A1E),
    edgeHighlightColor: Color(0x66FFFFFF),
    refractionColor: Color(0x4DFFFFFF),
    refractionWidth: 1.0,
    borderColor: Color(0x40FFFFFF),
    borderWidth: 1.0,
    borderRadius: BorderRadius.all(Radius.circular(24)),
    opaqueFallbackColor: Color(0xF21C1C1E),
    shadowColor: Color(0x40000000),
    shadowBlurRadius: 28,
    shadowOffset: Offset(0, 10),
  );

  static const LiquidGlassTokens lightThin = LiquidGlassTokens(
    blurSigma: 14,
    saturation: 1.12,
    tintColor: Color(0x3DFFFFFF),
    edgeHighlightColor: Color(0x8CFFFFFF),
    refractionColor: Color(0x73FFFFFF),
    refractionWidth: 0.75,
    borderColor: Color(0x40FFFFFF),
    borderWidth: 0.75,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    opaqueFallbackColor: Color(0xE6F5F5F7),
    shadowColor: Color(0x14000000),
    shadowBlurRadius: 16,
    shadowOffset: Offset(0, 4),
  );

  static const LiquidGlassTokens lightThick = LiquidGlassTokens(
    blurSigma: 42,
    saturation: 1.5,
    tintColor: Color(0x8CFFFFFF),
    edgeHighlightColor: Color(0xCCFFFFFF),
    refractionColor: Color(0xB3FFFFFF),
    refractionWidth: 1.25,
    borderColor: Color(0x73FFFFFF),
    borderWidth: 1.25,
    borderRadius: BorderRadius.all(Radius.circular(28)),
    opaqueFallbackColor: Color(0xFFF2F2F7),
    shadowColor: Color(0x26000000),
    shadowBlurRadius: 32,
    shadowOffset: Offset(0, 12),
  );

  static const LiquidGlassTokens darkThin = LiquidGlassTokens(
    blurSigma: 16,
    saturation: 1.08,
    tintColor: Color(0x331A1A1E),
    edgeHighlightColor: Color(0x4DFFFFFF),
    refractionColor: Color(0x33FFFFFF),
    refractionWidth: 0.75,
    borderColor: Color(0x33FFFFFF),
    borderWidth: 0.75,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    opaqueFallbackColor: Color(0xE61C1C1E),
    shadowColor: Color(0x33000000),
    shadowBlurRadius: 18,
    shadowOffset: Offset(0, 6),
  );

  static const LiquidGlassTokens darkThick = LiquidGlassTokens(
    blurSigma: 48,
    saturation: 1.38,
    tintColor: Color(0x731A1A1E),
    edgeHighlightColor: Color(0x8CFFFFFF),
    refractionColor: Color(0x66FFFFFF),
    refractionWidth: 1.25,
    borderColor: Color(0x59FFFFFF),
    borderWidth: 1.25,
    borderRadius: BorderRadius.all(Radius.circular(28)),
    opaqueFallbackColor: Color(0xFF1C1C1E),
    shadowColor: Color(0x59000000),
    shadowBlurRadius: 36,
    shadowOffset: Offset(0, 14),
  );

  /// Convenience: map a tier onto the light or dark regular-based family.
  ///
  /// Prefer [LiquidGlassMaterials.resolve] when the theme provides a full
  /// thin / regular / thick set.
  LiquidGlassTokens forTier(GlassMaterialTier tier) {
    final isDark = opaqueFallbackColor.computeLuminance() < 0.5;
    return switch (tier) {
      GlassMaterialTier.thin => isDark ? darkThin : lightThin,
      GlassMaterialTier.regular => this,
      GlassMaterialTier.thick => isDark ? darkThick : lightThick,
    };
  }

  /// Unbounded Gaussian blur (tests / custom compositors).
  ImageFilter get blurFilter =>
      ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);

  /// Frosted blur used by [GlassSurface].
  ///
  /// Uses unbounded blur + [TileMode.clamp]; the glass shape clips the
  /// result. (`ImageFilter.blur` `bounds` is not available on all Flutter
  /// stables / web compilers we support.)
  ImageFilter boundedBlurFilter(Size size) {
    assert(size.width >= 0 && size.height >= 0);
    return ImageFilter.blur(
      sigmaX: blurSigma,
      sigmaY: blurSigma,
      tileMode: TileMode.clamp,
    );
  }

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
    Color? refractionColor,
    double? refractionWidth,
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
      refractionColor: refractionColor ?? this.refractionColor,
      refractionWidth: refractionWidth ?? this.refractionWidth,
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
      refractionColor: Color.lerp(refractionColor, other.refractionColor, t)!,
      refractionWidth: lerpDouble(refractionWidth, other.refractionWidth, t)!,
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
        other.refractionColor == refractionColor &&
        other.refractionWidth == refractionWidth &&
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
    refractionColor,
    refractionWidth,
    borderColor,
    borderWidth,
    borderRadius,
    opaqueFallbackColor,
    shadowColor,
    shadowBlurRadius,
    shadowOffset,
  );
}

/// Thin / regular / thick token set for one brightness.
@immutable
class LiquidGlassMaterials {
  const LiquidGlassMaterials({
    required this.thin,
    required this.regular,
    required this.thick,
  });

  final LiquidGlassTokens thin;
  final LiquidGlassTokens regular;
  final LiquidGlassTokens thick;

  static const LiquidGlassMaterials light = LiquidGlassMaterials(
    thin: LiquidGlassTokens.lightThin,
    regular: LiquidGlassTokens.light,
    thick: LiquidGlassTokens.lightThick,
  );

  static const LiquidGlassMaterials dark = LiquidGlassMaterials(
    thin: LiquidGlassTokens.darkThin,
    regular: LiquidGlassTokens.dark,
    thick: LiquidGlassTokens.darkThick,
  );

  /// Same tokens for every tier (useful in tests / custom themes).
  factory LiquidGlassMaterials.all(LiquidGlassTokens tokens) {
    return LiquidGlassMaterials(thin: tokens, regular: tokens, thick: tokens);
  }

  LiquidGlassTokens resolve(GlassMaterialTier tier) {
    return switch (tier) {
      GlassMaterialTier.thin => thin,
      GlassMaterialTier.regular => regular,
      GlassMaterialTier.thick => thick,
    };
  }

  LiquidGlassMaterials copyWith({
    LiquidGlassTokens? thin,
    LiquidGlassTokens? regular,
    LiquidGlassTokens? thick,
  }) {
    return LiquidGlassMaterials(
      thin: thin ?? this.thin,
      regular: regular ?? this.regular,
      thick: thick ?? this.thick,
    );
  }

  LiquidGlassMaterials lerp(LiquidGlassMaterials other, double t) {
    return LiquidGlassMaterials(
      thin: thin.lerp(other.thin, t),
      regular: regular.lerp(other.regular, t),
      thick: thick.lerp(other.thick, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassMaterials &&
        other.thin == thin &&
        other.regular == regular &&
        other.thick == thick;
  }

  @override
  int get hashCode => Object.hash(thin, regular, thick);
}
