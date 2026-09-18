import 'package:flutter/foundation.dart';

import 'glass_material.dart';
import 'liquid_glass_tokens.dart';

/// **A. Materials** catalog — Ultrathin / Thin / Regular / Thick for one
/// brightness.
///
/// These are translucent fills, **not** [LiquidGlassStyle] recipes.
/// Resolve with [resolve]. Thick is Sheet / Sidebar chrome only.
@immutable
class MaterialCatalog {
  const MaterialCatalog({
    required this.thin,
    required this.regular,
    required this.thick,
    LiquidGlassTokens? ultrathin,
  }) : ultrathin = ultrathin ?? thin;

  /// Materials Ultrathin.
  final LiquidGlassTokens ultrathin;

  /// Materials Thin.
  final LiquidGlassTokens thin;

  /// Materials Regular (content-layer fill — not Regular Large glass).
  final LiquidGlassTokens regular;

  /// Materials Thick (Sheet / Sidebar).
  final LiquidGlassTokens thick;

  /// Light Materials set.
  static const MaterialCatalog light = MaterialCatalog(
    ultrathin: LiquidGlassTokens.lightUltrathin,
    thin: LiquidGlassTokens.lightThin,
    regular: LiquidGlassTokens.materialLightRegular,
    thick: LiquidGlassTokens.lightThick,
  );

  /// Dark Materials set.
  static const MaterialCatalog dark = MaterialCatalog(
    ultrathin: LiquidGlassTokens.darkUltrathin,
    thin: LiquidGlassTokens.darkThin,
    regular: LiquidGlassTokens.materialDarkRegular,
    thick: LiquidGlassTokens.darkThick,
  );

  /// Same tokens for every Materials tier (tests / custom themes).
  factory MaterialCatalog.all(LiquidGlassTokens tokens) {
    return MaterialCatalog(
      ultrathin: tokens,
      thin: tokens,
      regular: tokens,
      thick: tokens,
    );
  }

  LiquidGlassTokens resolve(MaterialTier tier) {
    return switch (tier) {
      MaterialTier.ultrathin => ultrathin,
      MaterialTier.thin => thin,
      MaterialTier.regular => regular,
      MaterialTier.thick => thick,
    };
  }

  MaterialCatalog copyWith({
    LiquidGlassTokens? ultrathin,
    LiquidGlassTokens? thin,
    LiquidGlassTokens? regular,
    LiquidGlassTokens? thick,
  }) {
    return MaterialCatalog(
      ultrathin: ultrathin ?? this.ultrathin,
      thin: thin ?? this.thin,
      regular: regular ?? this.regular,
      thick: thick ?? this.thick,
    );
  }

  MaterialCatalog lerp(MaterialCatalog other, double t) {
    return MaterialCatalog(
      ultrathin: ultrathin.lerp(other.ultrathin, t),
      thin: thin.lerp(other.thin, t),
      regular: regular.lerp(other.regular, t),
      thick: thick.lerp(other.thick, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaterialCatalog &&
        other.ultrathin == ultrathin &&
        other.thin == thin &&
        other.regular == regular &&
        other.thick == thick;
  }

  @override
  int get hashCode => Object.hash(ultrathin, thin, regular, thick);
}

/// @nodoc Backward-compatible alias. Prefer [MaterialCatalog].
@Deprecated(
  'Use MaterialCatalog. The LiquidGlassMaterials name mixed Materials '
  'tiers with Liquid Glass styles.',
)
typedef LiquidGlassMaterials = MaterialCatalog;
