import 'package:flutter/material.dart';

/// **Labels — Liquid Glass** (official kit names).
///
/// Light Primary `#1A1A1A` · Dark Primary `#EDEDED`.
///
/// Use on Liquid Glass controls ([GlassButton], labels sitting on Clear /
/// Regular / Dock / Widget Glass). Do not substitute Materials fill colors
/// for text.
class LiquidGlassLabels {
  const LiquidGlassLabels._();

  /// Labels — Liquid Glass / Light / Primary.
  static const Color lightPrimary = Color(0xFF1A1A1A);

  /// Labels — Liquid Glass / Dark / Primary.
  static const Color darkPrimary = Color(0xFFEDEDED);

  /// Primary label for the given brightness.
  static Color primaryFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkPrimary : lightPrimary;
  }

  /// Primary label from [Theme.brightnessOf].
  static Color primaryOf(BuildContext context) {
    return primaryFor(Theme.brightnessOf(context));
  }
}
