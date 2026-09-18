import 'package:flutter/material.dart';

import '../tokens/liquid_glass_tokens.dart';

/// [ThemeExtension] that carries [LiquidGlassTokens] for light and dark themes.
@immutable
class LiquidGlassTheme extends ThemeExtension<LiquidGlassTheme> {
  const LiquidGlassTheme({required this.tokens});

  final LiquidGlassTokens tokens;

  /// Convenience accessor from a [BuildContext].
  static LiquidGlassTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<LiquidGlassTheme>();
    assert(
      extension != null,
      'LiquidGlassTheme not found. Add LiquidGlassTheme to ThemeData.extensions.',
    );
    return extension!;
  }

  /// Maybe accessor that falls back to brightness-based defaults.
  static LiquidGlassTokens tokensOf(BuildContext context) {
    final extension = Theme.of(context).extension<LiquidGlassTheme>();
    if (extension != null) return extension.tokens;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? LiquidGlassTokens.dark
        : LiquidGlassTokens.light;
  }

  /// Light theme extension using [LiquidGlassTokens.light].
  static const LiquidGlassTheme light = LiquidGlassTheme(
    tokens: LiquidGlassTokens.light,
  );

  /// Dark theme extension using [LiquidGlassTokens.dark].
  static const LiquidGlassTheme dark = LiquidGlassTheme(
    tokens: LiquidGlassTokens.dark,
  );

  @override
  LiquidGlassTheme copyWith({LiquidGlassTokens? tokens}) {
    return LiquidGlassTheme(tokens: tokens ?? this.tokens);
  }

  @override
  LiquidGlassTheme lerp(ThemeExtension<LiquidGlassTheme>? other, double t) {
    if (other is! LiquidGlassTheme) return this;
    return LiquidGlassTheme(tokens: tokens.lerp(other.tokens, t));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassTheme && other.tokens == tokens;
  }

  @override
  int get hashCode => tokens.hashCode;
}
