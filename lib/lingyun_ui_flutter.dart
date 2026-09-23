/// lingyun-ui-flutter — Liquid Glass + Materials primitives for iPhone,
/// iPhone Duo, iPad, and macOS (plus web).
///
/// Two systems (do not mix names):
/// * **A. Materials** — [MaterialTier] Ultrathin / Thin / Regular / Thick
/// * **B. Liquid Glass** — [LiquidGlassStyle] Clear / Regular S·M·L /
///   Dock / Widget Glass
///
/// [GlassTabBar] is Liquid Glass chrome (default Dock), not a Materials
/// tier and not a toolbar material.
///
/// Public APIs are adaptive (MediaQuery size / width classes, tokens,
/// ThemeExtension). They do not depend on device-model or UIKit types.
library;

export 'src/adaptivity/lingyun_adaptivity.dart';
export 'src/layout/lingyun_layout.dart';
export 'src/theme/liquid_glass_theme.dart';
export 'src/tokens/glass_button_palette.dart';
export 'src/tokens/glass_material.dart';
export 'src/tokens/liquid_glass_catalog.dart';
export 'src/tokens/liquid_glass_labels.dart';
export 'src/tokens/liquid_glass_motion.dart';
export 'src/tokens/liquid_glass_style.dart';
export 'src/tokens/liquid_glass_tokens.dart';
export 'src/tokens/material_catalog.dart';
export 'src/widgets/glass_button.dart';
export 'src/widgets/glass_surface.dart';
export 'src/widgets/glass_tab_bar.dart';
