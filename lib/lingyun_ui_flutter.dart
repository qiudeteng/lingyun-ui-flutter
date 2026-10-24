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
/// Alerts ([showLingyunAlert] / [LingyunAlertDialog]) are the iOS system
/// dialog from `package:cupertino_ui` (showCupertinoDialog +
/// CupertinoAlertDialog). They are not Liquid Glass and not a Materials
/// tier.
///
/// Public APIs are adaptive (MediaQuery size / width classes, tokens,
/// ThemeExtension). They do not depend on device-model checks.
///
/// [LingyunPage] is the Flutter page shell. On iOS it hands the same
/// [LingyunPageSpec] to [LingyunNativePage]. Off iOS it paints the skeleton.
library;

export 'src/adaptivity/lingyun_adaptivity.dart';
export 'src/layout/lingyun_layout.dart';
export 'src/page/lingyun_native_page.dart';
export 'src/page/lingyun_page.dart';
export 'src/page/lingyun_page_spec.dart';
export 'src/theme/lingyun_material_theme.dart';
export 'src/theme/lingyun_theme.dart';
export 'src/theme/liquid_glass_theme.dart';
export 'src/tokens/glass_button_palette.dart';
export 'src/tokens/glass_material.dart';
export 'src/tokens/liquid_glass_catalog.dart';
export 'src/tokens/lingyun_colors.dart';
export 'src/tokens/lingyun_text_styles.dart';
export 'src/tokens/liquid_glass_labels.dart';
export 'src/tokens/liquid_glass_motion.dart';
export 'src/tokens/liquid_glass_style.dart';
export 'src/tokens/liquid_glass_tokens.dart';
export 'src/tokens/material_catalog.dart';
export 'src/widgets/glass_button.dart';
export 'src/widgets/glass_surface.dart';
export 'src/widgets/glass_tab_bar.dart';
export 'src/widgets/lingyun_alert.dart';
