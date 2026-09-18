import 'package:flutter/material.dart';

import '../tokens/glass_material.dart';
import '../tokens/liquid_glass_tokens.dart';

/// [ThemeExtension] that carries [LiquidGlassMaterials] for light and dark.
@immutable
class LiquidGlassTheme extends ThemeExtension<LiquidGlassTheme> {
  const LiquidGlassTheme({required this.materials});

  final LiquidGlassMaterials materials;

  /// Regular-tier tokens (backward-compatible convenience).
  LiquidGlassTokens get tokens => materials.regular;

  /// Convenience accessor from a [BuildContext].
  static LiquidGlassTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<LiquidGlassTheme>();
    assert(
      extension != null,
      'LiquidGlassTheme not found. Add LiquidGlassTheme to ThemeData.extensions.',
    );
    return extension!;
  }

  /// Tokens for [tier], falling back to brightness-based materials.
  static LiquidGlassTokens tokensOf(
    BuildContext context, {
    GlassMaterialTier tier = GlassMaterialTier.regular,
  }) {
    final extension = Theme.of(context).extension<LiquidGlassTheme>();
    if (extension != null) return extension.materials.resolve(tier);
    final brightness = Theme.of(context).brightness;
    final materials = brightness == Brightness.dark
        ? LiquidGlassMaterials.dark
        : LiquidGlassMaterials.light;
    return materials.resolve(tier);
  }

  /// Light theme extension using [LiquidGlassMaterials.light].
  static const LiquidGlassTheme light = LiquidGlassTheme(
    materials: LiquidGlassMaterials.light,
  );

  /// Dark theme extension using [LiquidGlassMaterials.dark].
  static const LiquidGlassTheme dark = LiquidGlassTheme(
    materials: LiquidGlassMaterials.dark,
  );

  @override
  LiquidGlassTheme copyWith({
    LiquidGlassMaterials? materials,
    LiquidGlassTokens? tokens,
  }) {
    if (materials != null) {
      return LiquidGlassTheme(materials: materials);
    }
    if (tokens != null) {
      return LiquidGlassTheme(
        materials: this.materials.copyWith(regular: tokens),
      );
    }
    return this;
  }

  @override
  LiquidGlassTheme lerp(ThemeExtension<LiquidGlassTheme>? other, double t) {
    if (other is! LiquidGlassTheme) return this;
    return LiquidGlassTheme(materials: materials.lerp(other.materials, t));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassTheme && other.materials == materials;
  }

  @override
  int get hashCode => materials.hashCode;
}
