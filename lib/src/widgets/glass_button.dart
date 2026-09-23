import 'package:flutter/material.dart';

import '../theme/liquid_glass_theme.dart';
import '../tokens/glass_button_palette.dart';
import '../tokens/liquid_glass_labels.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import '../tokens/liquid_glass_tokens.dart';
import 'glass_surface.dart';

/// Kit role for a [GlassButton]. Not a second button widget.
///
/// Sketch Buttons page: **Destructive** is a role on Glass and on
/// Glass Prominent. It is not a Materials tier.
enum GlassButtonRole {
  /// Default action.
  ///
  /// Glass uses [LiquidGlassLabels]. Glass Prominent uses a white label.
  normal,

  /// Kit **Destructive**.
  ///
  /// Glass: system-red label on the Liquid Glass material.
  /// Glass Prominent: filled system red, white label.
  destructive,
}

/// Kit fill for a [GlassButton]. Not a Materials tier.
///
/// * [glass] — kit **Glass**. Translucent Liquid Glass. Default material
///   is [LiquidGlassStyle.regularSmall]; pass [LiquidGlassStyle.clear]
///   over rich media.
/// * [prominent] — kit **Glass Prominent**. Tinted / filled System Blue
///   (system red when [GlassButtonRole.destructive]). White label.
///
/// Materials Thick is never a button fill.
enum GlassButtonProminence {
  /// Kit **Glass**.
  glass,

  /// Kit **Glass Prominent** — tinted / filled System Blue.
  prominent,
}

/// First-party **Liquid Glass Button**.
///
/// One widget, several kit treatments — do not add a parallel button type.
///
/// * Default material: [LiquidGlassStyle.regularSmall] (48pt capsule).
/// * [LiquidGlassStyle.clear] over rich media.
/// * [GlassButtonRole.destructive] for the kit Destructive role.
/// * [GlassButtonProminence.prominent] for tinted / filled System Blue
///   (Glass Prominent).
///
/// **Not** Materials Thick — that fill is reserved for Sheet / Sidebar
/// chrome. Labels on Glass use [LiquidGlassLabels] Light Primary
/// `#1A1A1A` / Dark Primary `#EDEDED`. Filled Glass Prominent uses white.
///
/// States: Default, Pressed (scale + press veil), Disabled
/// (`onPressed == null` — muted label, prominent fill drops back to glass).
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = LiquidGlassStyle.regularSmall,
    this.role = GlassButtonRole.normal,
    this.prominence = GlassButtonProminence.glass,
    this.forcePressed = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.minimumSize = const Size(48, 48),
    this.borderRadius,
    this.forceOpaque = false,
    this.enableHoverHighlight = true,
  });

  /// Label + optional leading icon.
  ///
  /// Color comes from the role, prominence, and enabled state — not a
  /// hardcoded demo style.
  factory GlassButton.label({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    LiquidGlassStyle style = LiquidGlassStyle.regularSmall,
    GlassButtonRole role = GlassButtonRole.normal,
    GlassButtonProminence prominence = GlassButtonProminence.glass,
    bool forcePressed = false,
    bool forceOpaque = false,
  }) {
    return GlassButton(
      key: key,
      onPressed: onPressed,
      style: style,
      role: role,
      prominence: prominence,
      forcePressed: forcePressed,
      forceOpaque: forceOpaque,
      child: _GlassButtonLabel(label: label, icon: icon),
    );
  }

  final VoidCallback? onPressed;
  final Widget child;

  /// Liquid Glass kit style. Default: Regular Small (button).
  ///
  /// [LiquidGlassStyle.clear] is the rich-media path. Ignored as a fill
  /// when [prominence] is [GlassButtonProminence.prominent] and the
  /// button is enabled — Prominent replaces the veil with System Blue
  /// or system red, and still keeps this style's capsule radius and
  /// ~0.5px hairline.
  final LiquidGlassStyle style;

  /// Kit **Destructive** role. Default: [GlassButtonRole.normal].
  final GlassButtonRole role;

  /// Kit **Glass** vs **Glass Prominent**.
  final GlassButtonProminence prominence;

  /// Pins the pressed treatment so a gallery can show it without a pointer.
  ///
  /// Pointer presses still animate when this is false.
  final bool forcePressed;

  final EdgeInsetsGeometry padding;
  final Size minimumSize;
  final BorderRadius? borderRadius;
  final bool forceOpaque;
  final bool enableHoverHighlight;

  bool get enabled => onPressed != null;

  /// Tokens for this button.
  ///
  /// Enabled Glass Prominent tints [base] (Regular Small by default) with
  /// System Blue or system red. Disabled Prominent returns [base] unchanged
  /// so the fill drops back to glass. Never substitutes Materials Thick.
  static LiquidGlassTokens resolveTokens({
    required LiquidGlassTokens base,
    required GlassButtonPalette palette,
    required GlassButtonProminence prominence,
    required GlassButtonRole role,
    required bool enabled,
  }) {
    final filled = enabled && prominence == GlassButtonProminence.prominent;
    if (!filled) return base;
    final fill = role == GlassButtonRole.destructive
        ? palette.systemRed
        : palette.systemBlue;
    return base.copyWith(
      tintColor: fill.withValues(alpha: 0.94),
      overlayColor: const Color(0x38FFFFFF),
      overlayBlend: BlendMode.softLight,
      opaqueFallbackColor: fill,
      edgeHighlightColor: const Color(0x66FFFFFF),
      refractionColor: const Color(0x80FFFFFF),
    );
  }

  /// Label color for this treatment. See [GlassButtonPalette].
  static Color resolveLabelColor({
    required GlassButtonPalette palette,
    required Brightness brightness,
    required GlassButtonRole role,
    required GlassButtonProminence prominence,
    required bool enabled,
  }) {
    if (!enabled) return palette.disabledLabel;
    if (prominence == GlassButtonProminence.prominent) {
      return palette.filledLabel;
    }
    if (role == GlassButtonRole.destructive) return palette.systemRed;
    return LiquidGlassLabels.primaryFor(brightness);
  }

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  bool get _showPressed => widget.enabled && (widget.forcePressed || _pressed);

  @override
  Widget build(BuildContext context) {
    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
    final curve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
    final palette = LiquidGlassTheme.buttonPaletteOf(context);
    final base = LiquidGlassTheme.styleOf(context, widget.style);
    final tokens = GlassButton.resolveTokens(
      base: base,
      palette: palette,
      prominence: widget.prominence,
      role: widget.role,
      enabled: widget.enabled,
    );
    final radius = widget.borderRadius ?? tokens.borderRadius;
    final labelColor = GlassButton.resolveLabelColor(
      palette: palette,
      brightness: Theme.brightnessOf(context),
      role: widget.role,
      prominence: widget.prominence,
      enabled: widget.enabled,
    );
    final scale = _showPressed ? 0.97 : 1.0;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      child: FocusableActionDetector(
        enabled: widget.enabled,
        mouseCursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.enabled
              ? (_) => setState(() => _pressed = true)
              : null,
          onTapUp: widget.enabled
              ? (_) => setState(() => _pressed = false)
              : null,
          onTapCancel: widget.enabled
              ? () => setState(() => _pressed = false)
              : null,
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: scale,
            duration: duration,
            curve: curve,
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: widget.minimumSize.width,
                    minHeight: widget.minimumSize.height,
                  ),
                  child: GlassSurface(
                    tokens: tokens,
                    borderRadius: radius,
                    padding: widget.padding,
                    forceOpaque: widget.forceOpaque,
                    enableHoverHighlight:
                        widget.enableHoverHighlight && widget.enabled,
                    child: IconTheme.merge(
                      data: IconThemeData(size: 18, color: labelColor),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          height: 1.2,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _showPressed ? 1 : 0,
                      duration: duration,
                      curve: curve,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          color: palette.pressedVeil,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButtonLabel extends StatelessWidget {
  const _GlassButtonLabel({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    if (icon == null) {
      return text;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), text],
    );
  }
}
