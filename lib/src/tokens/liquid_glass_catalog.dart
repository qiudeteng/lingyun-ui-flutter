import 'package:flutter/foundation.dart';

import 'liquid_glass_style.dart';
import 'liquid_glass_tokens.dart';

/// **B. Liquid Glass** catalog — Clear / Regular Small · Medium · Large /
/// Dock / Widget Glass for one brightness.
///
/// These are kit glass styles, **not** [MaterialTier] fills.
/// Button default is [regularSmall].
@immutable
class LiquidGlassCatalog {
  const LiquidGlassCatalog({
    required this.clear,
    required this.regularSmall,
    required this.regularMedium,
    required this.regularLarge,
    required this.dock,
    required this.widgetGlass,
  });

  final LiquidGlassTokens clear;
  final LiquidGlassTokens regularSmall;
  final LiquidGlassTokens regularMedium;
  final LiquidGlassTokens regularLarge;
  final LiquidGlassTokens dock;
  final LiquidGlassTokens widgetGlass;

  /// Light Liquid Glass set.
  static const LiquidGlassCatalog light = LiquidGlassCatalog(
    clear: LiquidGlassTokens.lightClear,
    regularSmall: LiquidGlassTokens.lightRegularSmall,
    regularMedium: LiquidGlassTokens.lightRegularMedium,
    regularLarge: LiquidGlassTokens.light,
    dock: LiquidGlassTokens.lightDock,
    widgetGlass: LiquidGlassTokens.lightWidgetGlass,
  );

  /// Dark Liquid Glass set.
  static const LiquidGlassCatalog dark = LiquidGlassCatalog(
    clear: LiquidGlassTokens.darkClear,
    regularSmall: LiquidGlassTokens.darkRegularSmall,
    regularMedium: LiquidGlassTokens.darkRegularMedium,
    regularLarge: LiquidGlassTokens.dark,
    dock: LiquidGlassTokens.darkDock,
    widgetGlass: LiquidGlassTokens.darkWidgetGlass,
  );

  LiquidGlassTokens resolve(LiquidGlassStyle style) {
    return switch (style) {
      LiquidGlassStyle.clear => clear,
      LiquidGlassStyle.regularSmall => regularSmall,
      LiquidGlassStyle.regularMedium => regularMedium,
      LiquidGlassStyle.regularLarge => regularLarge,
      LiquidGlassStyle.dock => dock,
      LiquidGlassStyle.widgetGlass => widgetGlass,
    };
  }

  LiquidGlassCatalog copyWith({
    LiquidGlassTokens? clear,
    LiquidGlassTokens? regularSmall,
    LiquidGlassTokens? regularMedium,
    LiquidGlassTokens? regularLarge,
    LiquidGlassTokens? dock,
    LiquidGlassTokens? widgetGlass,
  }) {
    return LiquidGlassCatalog(
      clear: clear ?? this.clear,
      regularSmall: regularSmall ?? this.regularSmall,
      regularMedium: regularMedium ?? this.regularMedium,
      regularLarge: regularLarge ?? this.regularLarge,
      dock: dock ?? this.dock,
      widgetGlass: widgetGlass ?? this.widgetGlass,
    );
  }

  LiquidGlassCatalog lerp(LiquidGlassCatalog other, double t) {
    return LiquidGlassCatalog(
      clear: clear.lerp(other.clear, t),
      regularSmall: regularSmall.lerp(other.regularSmall, t),
      regularMedium: regularMedium.lerp(other.regularMedium, t),
      regularLarge: regularLarge.lerp(other.regularLarge, t),
      dock: dock.lerp(other.dock, t),
      widgetGlass: widgetGlass.lerp(other.widgetGlass, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassCatalog &&
        other.clear == clear &&
        other.regularSmall == regularSmall &&
        other.regularMedium == regularMedium &&
        other.regularLarge == regularLarge &&
        other.dock == dock &&
        other.widgetGlass == widgetGlass;
  }

  @override
  int get hashCode => Object.hash(
    clear,
    regularSmall,
    regularMedium,
    regularLarge,
    dock,
    widgetGlass,
  );
}
