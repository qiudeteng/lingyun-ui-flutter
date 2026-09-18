import 'dart:ui' show BlendMode, ImageFilter, TileMode, lerpDouble;

import 'package:flutter/material.dart';

import 'glass_material.dart';
import 'liquid_glass_style.dart';

/// Shared visual recipe for Materials fills and Liquid Glass styles.
///
/// ## Two systems (do not mix names)
///
/// * **A. Materials** ([MaterialTier]) — Ultrathin / Thin / Regular / Thick
///   translucent fills. Resolve with [MaterialCatalog].
/// * **B. Liquid Glass** ([LiquidGlassStyle]) — Clear / Regular Small ·
///   Medium · Large / Dock / Widget Glass. Resolve with [LiquidGlassCatalog].
///
/// [blurSigma] and [saturation] are **implementation approximations —
/// not official Design Tokens**. Do not show them in UI as kit values.
///
/// ## Specular / refraction / rim conventions
///
/// Recipes are tuned against the public iOS 27 Sketch / Figma UI Kit
/// without claiming those names as Apple APIs:
///
/// * **Rim** — ~0.5px hairline + multi-layer specular (grey ring, side
///   hairlines, inner-lip, tight top-leading catch, directional inner
///   refraction). **Not** linearly thickened by Materials tier or glass
///   style (no 0.55 → 0.85 progression).
/// * **Tint** ([tintColor]) — veil over the blurred backdrop.
/// * **Overlay** ([overlayColor], [overlayBlend]) — second fill
///   (Luminosity on light, Lighten on dark).
/// * **Specular** ([edgeHighlightColor]) — tight top-leading catch,
///   plus [innerShadowColor] bands (kit ±40 Y / −40 spread analog).
/// * **Hover** (pointer platforms) may boost specular opacity.
///
/// [light] / [dark] are **Liquid Glass Regular Large**. Materials and
/// other glass styles live on the catalogs / named presets.
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
    this.rimSpread = hairlineWidth,
    this.rimSideOffset = 1.25,
    this.rimSideSpread = -0.75,
    required this.innerShadowColor,
    this.innerShadowExtent = 28,
  });

  /// Shared ~0.5px hairline / rim spread.
  ///
  /// **Implementation approximation — not an official Design Token.**
  /// Applied to every Materials tier and Liquid Glass style. Do not
  /// thicken this by tier.
  static const double hairlineWidth = 0.5;

  /// Gaussian blur sigma applied via [ImageFilter.blur].
  ///
  /// **Implementation approximation — not an official Design Token.**
  final double blurSigma;

  /// Color matrix saturation multiplier (1.0 = unchanged).
  ///
  /// **Implementation approximation — not an official Design Token.**
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
  ///
  /// Kept at [hairlineWidth] (~0.5). Not a per-tier thickness knob.
  final double refractionWidth;

  /// Outer hairline (kept very quiet; the grey [rimColor] ring does
  /// most of the edge work).
  final Color borderColor;

  /// Outer hairline width. Official-adjacent: ~0.5px, same for every recipe.
  final double borderWidth;

  /// Corner radius for the glass clip.
  ///
  /// Package steps 18 / 26 / 34 are **待核验 (unverified vs Sketch)**.
  final BorderRadius borderRadius;

  /// Solid fill used when transparency effects are reduced / high contrast.
  final Color opaqueFallbackColor;

  /// Soft deep drop shadow under the glass.
  final Color shadowColor;

  /// Deep-shadow blur radius.
  ///
  /// **Implementation approximation — not an official Design Token.**
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

  // ---------------------------------------------------------------------------
  // B. Liquid Glass — Regular Large (default `light` / `dark` aliases)
  // ---------------------------------------------------------------------------

  /// Liquid Glass **Regular Large** (light).
  static const LiquidGlassTokens light = LiquidGlassTokens(
    blurSigma: 20,
    saturation: 1.16,
    tintColor: Color(0x7AF8F3EF),
    overlayColor: Color(0x14BFBFBF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x59FFFFFF),
    refractionColor: Color(0x73FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x26FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xF2F5F5F7),
    shadowColor: Color(0x40000000),
    shadowBlurRadius: 48,
    shadowOffset: Offset(0, 8),
    shadowSpread: -4,
    rimColor: Color(0xFFDBDBDB),
    innerShadowColor: Color(0x2E282828),
  );

  /// Liquid Glass **Regular Large** (dark).
  static const LiquidGlassTokens dark = LiquidGlassTokens(
    blurSigma: 22,
    saturation: 1.10,
    tintColor: Color(0x731A1A1A),
    overlayColor: Color(0x991A1A1A),
    overlayBlend: BlendMode.lighten,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x4DFFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xF21C1C1E),
    shadowColor: Color(0x73000000),
    shadowBlurRadius: 48,
    shadowOffset: Offset(0, 8),
    shadowSpread: -4,
    rimColor: Color(0xFFA6A6A6),
    innerShadowColor: Color(0x331A1A1A),
  );

  /// Alias of [light] — Liquid Glass Regular Large (light).
  static const LiquidGlassTokens lightRegularLarge = light;

  /// Alias of [dark] — Liquid Glass Regular Large (dark).
  static const LiquidGlassTokens darkRegularLarge = dark;

  // ---------------------------------------------------------------------------
  // B. Liquid Glass — Clear / Regular Small · Medium / Dock / Widget Glass
  // ---------------------------------------------------------------------------

  /// Liquid Glass **Clear** (light). Alternate button style over rich media.
  static const LiquidGlassTokens lightClear = LiquidGlassTokens(
    blurSigma: 10,
    saturation: 1.10,
    tintColor: Color(0x14FFFFFF),
    overlayColor: Color(0x0AFFFFFF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x66FFFFFF),
    refractionColor: Color(0x8CFFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x33FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.small)),
    opaqueFallbackColor: Color(0xE6F5F5F7),
    shadowColor: Color(0x14000000),
    shadowBlurRadius: 16,
    shadowOffset: Offset(0, 8),
    shadowSpread: -2,
    rimColor: Color(0xFFEBEBEB),
    innerShadowColor: Color(0x1A282828),
    innerShadowExtent: 22,
  );

  /// Liquid Glass **Clear** (dark).
  static const LiquidGlassTokens darkClear = LiquidGlassTokens(
    blurSigma: 11,
    saturation: 1.08,
    tintColor: Color(0x14101010),
    overlayColor: Color(0x0AFFFFFF),
    overlayBlend: BlendMode.srcOver,
    edgeHighlightColor: Color(0x4DFFFFFF),
    refractionColor: Color(0x59FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x26FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.small)),
    opaqueFallbackColor: Color(0xE61C1C1E),
    shadowColor: Color(0x33000000),
    shadowBlurRadius: 16,
    shadowOffset: Offset(0, 8),
    shadowSpread: -2,
    rimColor: Color(0xFFE6E6E6),
    innerShadowColor: Color(0x261A1A1A),
    innerShadowExtent: 22,
  );

  /// Liquid Glass **Regular Small** (light). **Button default.**
  ///
  /// Kit Regular Small is a 48pt capsule (`BorderRadius.circular(100)`).
  static const LiquidGlassTokens lightRegularSmall = LiquidGlassTokens(
    blurSigma: 14,
    saturation: 1.12,
    tintColor: Color(0x14747480),
    overlayColor: Color(0x12747480),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x59FFFFFF),
    refractionColor: Color(0x73FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x26FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(100)),
    opaqueFallbackColor: Color(0xF2F5F5F7),
    shadowColor: Color(0x05000000),
    shadowBlurRadius: 15,
    shadowOffset: Offset(0, 8),
    shadowSpread: 0,
    rimColor: Color(0xFFEBEBEB),
    innerShadowColor: Color(0x1A282828),
    innerShadowExtent: 18,
  );

  /// Liquid Glass **Regular Small** (dark). **Button default.**
  static const LiquidGlassTokens darkRegularSmall = LiquidGlassTokens(
    blurSigma: 15,
    saturation: 1.08,
    tintColor: Color(0x1F767680),
    overlayColor: Color(0x14767680),
    overlayBlend: BlendMode.srcOver,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x4DFFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(100)),
    opaqueFallbackColor: Color(0xF21C1C1E),
    shadowColor: Color(0x0A000000),
    shadowBlurRadius: 15,
    shadowOffset: Offset(0, 8),
    shadowSpread: 0,
    rimColor: Color(0xFFE6E6E6),
    innerShadowColor: Color(0x261A1A1A),
    innerShadowExtent: 18,
  );

  /// Liquid Glass **Regular Medium** (light).
  ///
  /// Radius 26 is **待核验 (unverified vs Sketch)**.
  static const LiquidGlassTokens lightRegularMedium = LiquidGlassTokens(
    blurSigma: 18,
    saturation: 1.14,
    tintColor: Color(0x70F8F3EF),
    overlayColor: Color(0x14BFBFBF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x59FFFFFF),
    refractionColor: Color(0x73FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x26FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.medium)),
    opaqueFallbackColor: Color(0xF2F5F5F7),
    shadowColor: Color(0x33000000),
    shadowBlurRadius: 36,
    shadowOffset: Offset(0, 8),
    shadowSpread: -3,
    rimColor: Color(0xFFDBDBDB),
    innerShadowColor: Color(0x2E282828),
    innerShadowExtent: 24,
  );

  /// Liquid Glass **Regular Medium** (dark).
  static const LiquidGlassTokens darkRegularMedium = LiquidGlassTokens(
    blurSigma: 20,
    saturation: 1.10,
    tintColor: Color(0x6B1A1A1A),
    overlayColor: Color(0x8C1A1A1A),
    overlayBlend: BlendMode.lighten,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x4DFFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.medium)),
    opaqueFallbackColor: Color(0xF21C1C1E),
    shadowColor: Color(0x59000000),
    shadowBlurRadius: 36,
    shadowOffset: Offset(0, 8),
    shadowSpread: -3,
    rimColor: Color(0xFFA6A6A6),
    innerShadowColor: Color(0x331A1A1A),
    innerShadowExtent: 24,
  );

  /// Liquid Glass **Dock** (light).
  static const LiquidGlassTokens lightDock = LiquidGlassTokens(
    blurSigma: 18,
    saturation: 1.14,
    tintColor: Color(0x66F8F3EF),
    overlayColor: Color(0x1ABFBFBF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x66FFFFFF),
    refractionColor: Color(0x80FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x2EFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(28)),
    opaqueFallbackColor: Color(0xF2F5F5F7),
    shadowColor: Color(0x29000000),
    shadowBlurRadius: 28,
    shadowOffset: Offset(0, 10),
    shadowSpread: -2,
    rimColor: Color(0xFFDBDBDB),
    innerShadowColor: Color(0x2E282828),
    innerShadowExtent: 20,
  );

  /// Liquid Glass **Dock** (dark).
  static const LiquidGlassTokens darkDock = LiquidGlassTokens(
    blurSigma: 20,
    saturation: 1.10,
    tintColor: Color(0x661A1A1A),
    overlayColor: Color(0x8C1A1A1A),
    overlayBlend: BlendMode.lighten,
    edgeHighlightColor: Color(0x4DFFFFFF),
    refractionColor: Color(0x59FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(28)),
    opaqueFallbackColor: Color(0xF21C1C1E),
    shadowColor: Color(0x59000000),
    shadowBlurRadius: 28,
    shadowOffset: Offset(0, 10),
    shadowSpread: -2,
    rimColor: Color(0xFFA6A6A6),
    innerShadowColor: Color(0x331A1A1A),
    innerShadowExtent: 20,
  );

  /// Liquid Glass **Widget Glass** (light).
  static const LiquidGlassTokens lightWidgetGlass = LiquidGlassTokens(
    blurSigma: 22,
    saturation: 1.16,
    tintColor: Color(0x85F8F3EF),
    overlayColor: Color(0x1ABFBFBF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x59FFFFFF),
    refractionColor: Color(0x73FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x26FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xFFF2F2F7),
    shadowColor: Color(0x40000000),
    shadowBlurRadius: 40,
    shadowOffset: Offset(0, 10),
    shadowSpread: -4,
    rimColor: Color(0xFFDBDBDB),
    innerShadowColor: Color(0x2E282828),
    innerShadowExtent: 28,
  );

  /// Liquid Glass **Widget Glass** (dark).
  static const LiquidGlassTokens darkWidgetGlass = LiquidGlassTokens(
    blurSigma: 24,
    saturation: 1.12,
    tintColor: Color(0x851A1A1A),
    overlayColor: Color(0xA61A1A1A),
    overlayBlend: BlendMode.lighten,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x4DFFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xFF1C1C1E),
    shadowColor: Color(0x73000000),
    shadowBlurRadius: 40,
    shadowOffset: Offset(0, 10),
    shadowSpread: -4,
    rimColor: Color(0xFFA6A6A6),
    innerShadowColor: Color(0x331A1A1A),
    innerShadowExtent: 28,
  );

  // ---------------------------------------------------------------------------
  // A. Materials — Ultrathin / Thin / Regular / Thick
  // ---------------------------------------------------------------------------

  /// Materials **Ultrathin** (light). Translucent fill, not a glass style.
  static const LiquidGlassTokens lightUltrathin = LiquidGlassTokens(
    blurSigma: 8,
    saturation: 1.04,
    tintColor: Color(0x12FFFFFF),
    overlayColor: Color(0x08FFFFFF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x33FFFFFF),
    refractionColor: Color(0x40FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x14FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.medium)),
    opaqueFallbackColor: Color(0xD9F5F5F7),
    shadowColor: Color(0x0A000000),
    shadowBlurRadius: 12,
    shadowOffset: Offset(0, 4),
    shadowSpread: -1,
    rimColor: Color(0xFFEBEBEB),
    innerShadowColor: Color(0x14282828),
    innerShadowExtent: 16,
  );

  /// Materials **Thin** (light).
  ///
  /// Previously mis-labeled as Clear / Regular Small — that mapping is gone.
  static const LiquidGlassTokens lightThin = LiquidGlassTokens(
    blurSigma: 12,
    saturation: 1.08,
    tintColor: Color(0x66FFFFFF),
    overlayColor: Color(0x0DFFFFFF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x59FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.medium)),
    opaqueFallbackColor: Color(0xE6F5F5F7),
    shadowColor: Color(0x14000000),
    shadowBlurRadius: 16,
    shadowOffset: Offset(0, 6),
    shadowSpread: -2,
    rimColor: Color(0xFFEBEBEB),
    innerShadowColor: Color(0x1A282828),
    innerShadowExtent: 20,
  );

  /// Materials **Regular** (light). Content-layer fill — not Regular Large glass.
  static const LiquidGlassTokens materialLightRegular = LiquidGlassTokens(
    blurSigma: 18,
    saturation: 1.12,
    tintColor: Color(0x99FFFFFF),
    overlayColor: Color(0x40FFFFFF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x59FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xF2F5F5F7),
    shadowColor: Color(0x29000000),
    shadowBlurRadius: 24,
    shadowOffset: Offset(0, 8),
    shadowSpread: -2,
    rimColor: Color(0xFFDBDBDB),
    innerShadowColor: Color(0x1F282828),
    innerShadowExtent: 22,
  );

  /// Materials **Thick** (light). Sheet / Sidebar chrome — not a button.
  ///
  /// Previously mis-labeled as Widget Glass — that mapping is gone.
  static const LiquidGlassTokens lightThick = LiquidGlassTokens(
    blurSigma: 26,
    saturation: 1.16,
    tintColor: Color(0xD6FFFFFF),
    overlayColor: Color(0x57FFFFFF),
    overlayBlend: BlendMode.luminosity,
    edgeHighlightColor: Color(0x40FFFFFF),
    refractionColor: Color(0x59FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x1AFFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xFFF2F2F7),
    shadowColor: Color(0x33000000),
    shadowBlurRadius: 32,
    shadowOffset: Offset(0, 10),
    shadowSpread: -3,
    rimColor: Color(0xFFD0D0D0),
    innerShadowColor: Color(0x26282828),
    innerShadowExtent: 24,
  );

  /// Materials **Ultrathin** (dark).
  static const LiquidGlassTokens darkUltrathin = LiquidGlassTokens(
    blurSigma: 9,
    saturation: 1.03,
    tintColor: Color(0x05000000),
    overlayColor: Color(0x05000000),
    overlayBlend: BlendMode.srcOver,
    edgeHighlightColor: Color(0x26FFFFFF),
    refractionColor: Color(0x2EFFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x14FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.medium)),
    opaqueFallbackColor: Color(0xD91C1C1E),
    shadowColor: Color(0x1A000000),
    shadowBlurRadius: 12,
    shadowOffset: Offset(0, 4),
    shadowSpread: -1,
    rimColor: Color(0xFFE6E6E6),
    innerShadowColor: Color(0x141A1A1A),
    innerShadowExtent: 16,
  );

  /// Materials **Thin** (dark).
  static const LiquidGlassTokens darkThin = LiquidGlassTokens(
    blurSigma: 14,
    saturation: 1.06,
    tintColor: Color(0x42000000),
    overlayColor: Color(0x14000000),
    overlayBlend: BlendMode.srcOver,
    edgeHighlightColor: Color(0x33FFFFFF),
    refractionColor: Color(0x33FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x14FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.medium)),
    opaqueFallbackColor: Color(0xE61C1C1E),
    shadowColor: Color(0x33000000),
    shadowBlurRadius: 18,
    shadowOffset: Offset(0, 6),
    shadowSpread: -2,
    rimColor: Color(0xFFE6E6E6),
    innerShadowColor: Color(0x261A1A1A),
    innerShadowExtent: 20,
  );

  /// Materials **Regular** (dark).
  static const LiquidGlassTokens materialDarkRegular = LiquidGlassTokens(
    blurSigma: 20,
    saturation: 1.08,
    tintColor: Color(0x69000000),
    overlayColor: Color(0x29000000),
    overlayBlend: BlendMode.lighten,
    edgeHighlightColor: Color(0x33FFFFFF),
    refractionColor: Color(0x40FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x14FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xF21C1C1E),
    shadowColor: Color(0x4D000000),
    shadowBlurRadius: 24,
    shadowOffset: Offset(0, 8),
    shadowSpread: -2,
    rimColor: Color(0xFFA6A6A6),
    innerShadowColor: Color(0x291A1A1A),
    innerShadowExtent: 22,
  );

  /// Materials **Thick** (dark). Sheet / Sidebar chrome — not a button.
  static const LiquidGlassTokens darkThick = LiquidGlassTokens(
    blurSigma: 28,
    saturation: 1.10,
    tintColor: Color(0x99000000),
    overlayColor: Color(0x3D000000),
    overlayBlend: BlendMode.lighten,
    edgeHighlightColor: Color(0x33FFFFFF),
    refractionColor: Color(0x40FFFFFF),
    refractionWidth: hairlineWidth,
    borderColor: Color(0x14FFFFFF),
    borderWidth: hairlineWidth,
    borderRadius: BorderRadius.all(Radius.circular(LiquidGlassRadii.large)),
    opaqueFallbackColor: Color(0xFF1C1C1E),
    shadowColor: Color(0x66000000),
    shadowBlurRadius: 32,
    shadowOffset: Offset(0, 10),
    shadowSpread: -3,
    rimColor: Color(0xFFA6A6A6),
    innerShadowColor: Color(0x331A1A1A),
    innerShadowExtent: 24,
  );

  /// Map a **Materials** tier onto the light or dark family.
  ///
  /// [MaterialTier.regular] returns `this` (legacy). Prefer
  /// [MaterialCatalog.resolve] for a real Materials Regular fill.
  LiquidGlassTokens forTier(MaterialTier tier) {
    final isDark = opaqueFallbackColor.computeLuminance() < 0.5;
    return switch (tier) {
      MaterialTier.ultrathin => isDark ? darkUltrathin : lightUltrathin,
      MaterialTier.thin => isDark ? darkThin : lightThin,
      MaterialTier.regular => this,
      MaterialTier.thick => isDark ? darkThick : lightThick,
    };
  }

  /// Map a **Liquid Glass** style onto the light or dark family.
  LiquidGlassTokens forStyle(LiquidGlassStyle style) {
    final isDark = opaqueFallbackColor.computeLuminance() < 0.5;
    return switch (style) {
      LiquidGlassStyle.clear => isDark ? darkClear : lightClear,
      LiquidGlassStyle.regularSmall =>
        isDark ? darkRegularSmall : lightRegularSmall,
      LiquidGlassStyle.regularMedium =>
        isDark ? darkRegularMedium : lightRegularMedium,
      LiquidGlassStyle.regularLarge => isDark ? dark : light,
      LiquidGlassStyle.dock => isDark ? darkDock : lightDock,
      LiquidGlassStyle.widgetGlass =>
        isDark ? darkWidgetGlass : lightWidgetGlass,
    };
  }

  /// Copy with a [GlassRadiusScale] corner.
  ///
  /// 18 / 26 / 34 are **待核验 (unverified vs Sketch)**.
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
