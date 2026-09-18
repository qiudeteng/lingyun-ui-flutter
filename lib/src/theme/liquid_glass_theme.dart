import 'package:flutter/material.dart';

import '../tokens/glass_material.dart';
import '../tokens/liquid_glass_catalog.dart';
import '../tokens/liquid_glass_style.dart';
import '../tokens/liquid_glass_tokens.dart';
import '../tokens/material_catalog.dart';

/// [ThemeExtension] that carries **both** systems:
///
/// * [materials] — **A. Materials** (Ultrathin / Thin / Regular / Thick)
/// * [glasses] — **B. Liquid Glass** (Clear / Regular S·M·L / Dock / Widget)
///
/// Do not treat Materials tiers as Liquid Glass styles.
@immutable
class LiquidGlassTheme extends ThemeExtension<LiquidGlassTheme> {
  const LiquidGlassTheme({
    required this.materials,
    this.glasses = LiquidGlassCatalog.light,
  });

  /// Materials catalog (translucent fills).
  final MaterialCatalog materials;

  /// Liquid Glass catalog (kit styles).
  final LiquidGlassCatalog glasses;

  /// Default Liquid Glass Regular Large tokens.
  LiquidGlassTokens get tokens => glasses.regularLarge;

  /// Convenience accessor from a [BuildContext].
  static LiquidGlassTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<LiquidGlassTheme>();
    assert(
      extension != null,
      'LiquidGlassTheme not found. Add LiquidGlassTheme to ThemeData.extensions.',
    );
    return extension!;
  }

  /// Materials tokens for [tier].
  ///
  /// Prefer [materialOf] / [styleOf] so the two systems stay distinct.
  static LiquidGlassTokens tokensOf(
    BuildContext context, {
    MaterialTier tier = MaterialTier.regular,
  }) {
    return materialOf(context, tier);
  }

  /// **A. Materials** tokens for [tier].
  static LiquidGlassTokens materialOf(BuildContext context, MaterialTier tier) {
    final extension = Theme.of(context).extension<LiquidGlassTheme>();
    if (extension != null) return extension.materials.resolve(tier);
    final brightness = Theme.of(context).brightness;
    final catalog = brightness == Brightness.dark
        ? MaterialCatalog.dark
        : MaterialCatalog.light;
    return catalog.resolve(tier);
  }

  /// **B. Liquid Glass** tokens for [style].
  static LiquidGlassTokens styleOf(
    BuildContext context,
    LiquidGlassStyle style,
  ) {
    final extension = Theme.of(context).extension<LiquidGlassTheme>();
    if (extension != null) return extension.glasses.resolve(style);
    final brightness = Theme.of(context).brightness;
    final catalog = brightness == Brightness.dark
        ? LiquidGlassCatalog.dark
        : LiquidGlassCatalog.light;
    return catalog.resolve(style);
  }

  /// Light theme: light Materials + light Liquid Glass.
  static const LiquidGlassTheme light = LiquidGlassTheme(
    materials: MaterialCatalog.light,
    glasses: LiquidGlassCatalog.light,
  );

  /// Dark theme: dark Materials + dark Liquid Glass.
  static const LiquidGlassTheme dark = LiquidGlassTheme(
    materials: MaterialCatalog.dark,
    glasses: LiquidGlassCatalog.dark,
  );

  @override
  LiquidGlassTheme copyWith({
    MaterialCatalog? materials,
    LiquidGlassCatalog? glasses,
    LiquidGlassTokens? tokens,
  }) {
    if (materials != null || glasses != null) {
      return LiquidGlassTheme(
        materials: materials ?? this.materials,
        glasses: glasses ?? this.glasses,
      );
    }
    if (tokens != null) {
      return LiquidGlassTheme(
        materials: this.materials.copyWith(regular: tokens),
        glasses: this.glasses.copyWith(regularLarge: tokens),
      );
    }
    return this;
  }

  @override
  LiquidGlassTheme lerp(ThemeExtension<LiquidGlassTheme>? other, double t) {
    if (other is! LiquidGlassTheme) return this;
    return LiquidGlassTheme(
      materials: materials.lerp(other.materials, t),
      glasses: glasses.lerp(other.glasses, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassTheme &&
        other.materials == materials &&
        other.glasses == glasses;
  }

  @override
  int get hashCode => Object.hash(materials, glasses);
}
