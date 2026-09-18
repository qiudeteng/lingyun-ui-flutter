import 'dart:ui' show BlendMode, ImageFilter, TileMode, lerpDouble;

import 'package:flutter/material.dart';

import 'glass_material.dart';

/// Design tokens for Liquid Glass–inspired surfaces.
///
/// ## Specular / refraction / rim conventions
///
/// These are **visual recipes**, not Apple private APIs. They apply on
/// iPhone, foldables, iPad, macOS, and web.
///
/// Recipes are tuned against the public iOS 27 Sketch / Figma UI Kit
/// layer styles (Clear, Regular Large / Medium / Small, Widget Glass)
/// without claiming those names as this package's API:
///
/// * **Tint** ([tintColor]) — a warm or charcoal veil. Regular is a
///   ~60–70% veil (kit Regular), not a 2018 30% white wash.
/// * **Overlay** ([overlayColor], [overlayBlend]) — Sketch-style second
///   fill (Luminosity on light, Lighten on dark).
/// * **Specular** ([edgeHighlightColor]) — a *tight* top-leading catch,
///   not a full-face sheen. Combined with [innerShadowColor] bands that
///   approximate the kit's dark inner shadows at ±40 Y / −40 spread.
/// * **Refraction rim** ([refractionColor], [refractionWidth]) — a
///   directional inner stroke (bright top-leading → quiet bottom-trailing),
///   inset from the outer ring. Not a second white border.
/// * **Crisp rim** ([rimColor], [rimSpread], [rimSideOffset]) — light-grey
///   zero-blur ring (kit `#dbdbdb` / `#a6a6a6`) plus side offsets with
///   negative spread (Sketch "Plus Darker" hairlines).
/// * **Soft deep shadow** ([shadowColor], [shadowBlurRadius],
///   [shadowOffset]) — large blur, modest Y, optional negative
///   [shadowSpread].
/// * **Hover** (pointer platforms) may boost specular opacity; touch
///   platforms simply never fire `MouseRegion.onEnter`.
///
/// [light] / [dark] are the **regular** tier presets. Resolve thin / thick
/// with [LiquidGlassMaterials] or [forTier]. Override corners with
/// [GlassRadiusScale] via [withRadiusScale] or [GlassSurface.radiusScale].
@immutable
class LiquidGlassTokens {
  const LiquidGlassTokens({
    required this.blurSigma,
    required this.saturation,
    required this.tintColor,
    required this.overlayColor,
    required this.overlayBlend,
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
    this.shadowSpread = 0,
    required this.rimColor,
    this.rimSpread = 0.5,
    this.rimSideOffset = 1.25,
    this.rimSideSpread = -0.75,
    required this.innerShadowColor,
    this.innerShadowExtent = 28,
  });

  /// Gaussian blur sigma applied via [ImageFilter.blur].
  final double blurSigma;

  /// Color matrix saturation multiplier (1.0 = unchanged).
  final double saturation;

  /// Translucent fill tint layered over the blurred backdrop.
  final Color tintColor;

  /// Second fill (Sketch Luminosity / Lighten analog).
  final Color overlayColor;

  /// Blend used for [overlayColor] against the tinted glass.
  final BlendMode overlayBlend;

  /// Specular face highlight (tight top-leading catch).
  final Color edgeHighlightColor;

  /// Inner refraction rim color (painted directionally).
  final Color refractionColor;

  /// Inner refraction rim width in logical pixels.
  final double refractionWidth;

  /// Outer hairline (kept very quiet; the grey [rimColor] ring does
  /// most of the edge work).
  final Color borderColor;

  /// Outer hairline width.
  final double borderWidth;

  /// Corner radius for the glass clip.
  final BorderRadius borderRadius;

  /// Solid fill used when transparency effects are reduced / high contrast.
  final Color opaqueFallbackColor;

  /// Soft deep drop shadow under the glass.
  final Color shadowColor;

  /// Deep-shadow blur radius.
  final double shadowBlurRadius;

  /// Deep-shadow offset.
  final Offset shadowOffset;

  /// Deep-shadow spread (negative = tighter, more iOS-like).
  final double shadowSpread;

  /// Crisp grey ring (kit darkened edge — a *light* grey, not black).
  final Color rimColor;

  /// Zero-blur ring spread (kit +0.5).
  final double rimSpread;

  /// Side hairline offset (kit / Sketch ≈ 1.25).
  final double rimSideOffset;

  /// Side hairline spread (kit / Sketch ≈ −0.75).
  final double rimSideSpread;

  /// Dark inner-lip color (kit specular via inner shadows).
  final Color innerShadowColor;

  /// How far the inner-lip gradient extends from the top/bottom edges.
  final double innerShadowExtent;

  /// Regular-tier preset for light appearance.
  ///
  /// Sketch-adjacent: Liquid Glass Regular Large (light).
  static const LiquidGlassTokens light = LiquidGlassTokens(
    blurSigma: 20,
    saturation: 1.16,
    tintColor: Color(0x7AF8F3EF),
    overlayColor: Color(0x14BFBFBF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x59FFFFFF),
    refractionColor: Color(0x73FFFFFF),
    refractionWidth: 0.7,
    borderColor: Color(0x26FFFFFF),
    borderWidth: 0.5,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xF2F5F5F7),
    shadowColor: Color(0x40000000),
    shadowBlurRadius: 48,
    shadowOffset: Offset(0, 8),
    shadowSpread: -4,
    rimColor: Color(0xFFDBDBDB),
    innerShadowColor: Color(0x2E282828),
  );

  /// Regular-tier preset for dark appearance.
  ///
  /// Sketch-adjacent: Liquid Glass Regular Large (dark).
  static const LiquidGlassTokens dark = LiquidGlassTokens(
    blurSigma: 22,
    saturation: 1.10,
    tintColor: Color(0x731A1A1A),
    overlayColor: Color(0x991A1A1A),
    overlayBlend: BlendMode.lighten,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x4DFFFFFF),
    refractionWidth: 0.7,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: 0.5,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xF21C1C1E),
    shadowColor: Color(0x73000000),
    shadowBlurRadius: 48,
    shadowOffset: Offset(0, 8),
    shadowSpread: -4,
    rimColor: Color(0xFFA6A6A6),
    innerShadowColor: Color(0x331A1A1A),
  );

  /// Light thin. Sketch-adjacent: Clear / Regular Small.
  static const LiquidGlassTokens lightThin = LiquidGlassTokens(
    blurSigma: 12,
    saturation: 1.08,
    tintColor: Color(0x2EFFFFFF),
    overlayColor: Color(0x12747480),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x59FFFFFF),
    refractionWidth: 0.55,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: 0.5,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.small)),
    opaqueFallbackColor: Color(0xE6F5F5F7),
    shadowColor: Color(0x14000000),
    shadowBlurRadius: 16,
    shadowOffset: Offset(0, 6),
    shadowSpread: -2,
    rimColor: Color(0xFFEBEBEB),
    rimSpread: 0.4,
    innerShadowColor: Color(0x1A282828),
    innerShadowExtent: 20,
  );

  /// Light thick. Sketch-adjacent: Widget Glass / elevated chrome.
  static const LiquidGlassTokens lightThick = LiquidGlassTokens(
    blurSigma: 28,
    saturation: 1.20,
    tintColor: Color(0x99F8F3EF),
    overlayColor: Color(0x1FBFBFBF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x66FFFFFF),
    refractionColor: Color(0x8CFFFFFF),
    refractionWidth: 0.85,
    borderColor: Color(0x33FFFFFF),
    borderWidth: 0.6,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xFFF2F2F7),
    shadowColor: Color(0x4D000000),
    shadowBlurRadius: 52,
    shadowOffset: Offset(0, 10),
    shadowSpread: -6,
    rimColor: Color(0xFFD0D0D0),
    innerShadowColor: Color(0x33282828),
    innerShadowExtent: 34,
  );

  /// Dark thin. Sketch-adjacent: Clear / Regular Small (dark).
  static const LiquidGlassTokens darkThin = LiquidGlassTokens(
    blurSigma: 14,
    saturation: 1.06,
    tintColor: Color(0x2E1A1A1A),
    overlayColor: Color(0x1F767680),
    overlayBlend: BlendMode.srcOver,
    edgeHighlightColor: Color(0x33FFFFFF),
    refractionColor: Color(0x33FFFFFF),
    refractionWidth: 0.55,
    borderColor: Color(0x14FFFFFF),
    borderWidth: 0.5,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.small)),
    opaqueFallbackColor: Color(0xE61C1C1E),
    shadowColor: Color(0x33000000),
    shadowBlurRadius: 18,
    shadowOffset: Offset(0, 6),
    shadowSpread: -2,
    rimColor: Color(0xFFE6E6E6),
    rimSpread: 0.4,
    innerShadowColor: Color(0x261A1A1A),
    innerShadowExtent: 20,
  );

  /// Dark thick. Sketch-adjacent: Widget Glass / elevated chrome (dark).
  static const LiquidGlassTokens darkThick = LiquidGlassTokens(
    blurSigma: 30,
    saturation: 1.14,
    tintColor: Color(0x991A1A1A),
    overlayColor: Color(0xB31A1A1A),
    overlayBlend: BlendMode.lighten,
    edgeHighlightColor: Color(0x4DFFFFFF),
    refractionColor: Color(0x59FFFFFF),
    refractionWidth: 0.85,
    borderColor: Color(0x26FFFFFF),
    borderWidth: 0.6,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xFF1C1C1E),
    shadowColor: Color(0x8C000000),
    shadowBlurRadius: 52,
    shadowOffset: Offset(0, 10),
    shadowSpread: -6,
    rimColor: Color(0xFFA6A6A6),
    innerShadowColor: Color(0x401A1A1A),
    innerShadowExtent: 34,
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

  /// Copy with a [GlassRadiusScale] corner.
  LiquidGlassTokens withRadiusScale(GlassRadiusScale scale) {
    return copyWith(borderRadius: LiquidGlassRadii.borderRadius(scale));
  }

  /// Soft deep shadow + crisp grey ring + side hairlines.
  List<BoxShadow> get shadows => [
    BoxShadow(
      color: shadowColor,
      blurRadius: shadowBlurRadius,
      offset: shadowOffset,
      spreadRadius: shadowSpread,
    ),
    BoxShadow(color: rimColor, blurRadius: 0, spreadRadius: rimSpread),
    BoxShadow(
      color: rimColor,
      blurRadius: 0,
      offset: Offset(rimSideOffset, 0),
      spreadRadius: rimSideSpread,
    ),
    BoxShadow(
      color: rimColor,
      blurRadius: 0,
      offset: Offset(-rimSideOffset, 0),
      spreadRadius: rimSideSpread,
    ),
  ];

  /// Unbounded Gaussian blur (tests / custom compositors).
  ImageFilter get blurFilter =>
      ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);

  /// Frosted blur used by [GlassSurface].
  ///
  /// Uses unbounded blur + [TileMode.clamp]; the glass shape clips the
  /// result. (`ImageFilter.blur` `bounds` is not available on all Flutter
  /// stables / web compilers we support — do not add that named param.)
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
    Color? overlayColor,
    BlendMode? overlayBlend,
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
    double? shadowSpread,
    Color? rimColor,
    double? rimSpread,
    double? rimSideOffset,
    double? rimSideSpread,
    Color? innerShadowColor,
    double? innerShadowExtent,
  }) {
    return LiquidGlassTokens(
      blurSigma: blurSigma ?? this.blurSigma,
      saturation: saturation ?? this.saturation,
      tintColor: tintColor ?? this.tintColor,
      overlayColor: overlayColor ?? this.overlayColor,
      overlayBlend: overlayBlend ?? this.overlayBlend,
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
      shadowSpread: shadowSpread ?? this.shadowSpread,
      rimColor: rimColor ?? this.rimColor,
      rimSpread: rimSpread ?? this.rimSpread,
      rimSideOffset: rimSideOffset ?? this.rimSideOffset,
      rimSideSpread: rimSideSpread ?? this.rimSideSpread,
      innerShadowColor: innerShadowColor ?? this.innerShadowColor,
      innerShadowExtent: innerShadowExtent ?? this.innerShadowExtent,
    );
  }

  LiquidGlassTokens lerp(LiquidGlassTokens other, double t) {
    return LiquidGlassTokens(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
      saturation: lerpDouble(saturation, other.saturation, t)!,
      tintColor: Color.lerp(tintColor, other.tintColor, t)!,
      overlayColor: Color.lerp(overlayColor, other.overlayColor, t)!,
      overlayBlend: t < 0.5 ? overlayBlend : other.overlayBlend,
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
      shadowSpread: lerpDouble(shadowSpread, other.shadowSpread, t)!,
      rimColor: Color.lerp(rimColor, other.rimColor, t)!,
      rimSpread: lerpDouble(rimSpread, other.rimSpread, t)!,
      rimSideOffset: lerpDouble(rimSideOffset, other.rimSideOffset, t)!,
      rimSideSpread: lerpDouble(rimSideSpread, other.rimSideSpread, t)!,
      innerShadowColor: Color.lerp(
        innerShadowColor,
        other.innerShadowColor,
        t,
      )!,
      innerShadowExtent: lerpDouble(
        innerShadowExtent,
        other.innerShadowExtent,
        t,
      )!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassTokens &&
        other.blurSigma == blurSigma &&
        other.saturation == saturation &&
        other.tintColor == tintColor &&
        other.overlayColor == overlayColor &&
        other.overlayBlend == overlayBlend &&
        other.edgeHighlightColor == edgeHighlightColor &&
        other.refractionColor == refractionColor &&
        other.refractionWidth == refractionWidth &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.borderRadius == borderRadius &&
        other.opaqueFallbackColor == opaqueFallbackColor &&
        other.shadowColor == shadowColor &&
        other.shadowBlurRadius == shadowBlurRadius &&
        other.shadowOffset == shadowOffset &&
        other.shadowSpread == shadowSpread &&
        other.rimColor == rimColor &&
        other.rimSpread == rimSpread &&
        other.rimSideOffset == rimSideOffset &&
        other.rimSideSpread == rimSideSpread &&
        other.innerShadowColor == innerShadowColor &&
        other.innerShadowExtent == innerShadowExtent;
  }

  @override
  int get hashCode => Object.hashAll([
    blurSigma,
    saturation,
    tintColor,
    overlayColor,
    overlayBlend,
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
    shadowSpread,
    rimColor,
    rimSpread,
    rimSideOffset,
    rimSideSpread,
    innerShadowColor,
    innerShadowExtent,
  ]);
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
