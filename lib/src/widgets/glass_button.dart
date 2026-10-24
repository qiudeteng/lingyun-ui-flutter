import 'dart:math' as math;

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
/// Figma **Button - Liquid Glass - Text** axis `Destructive`. It is not a
/// Materials tier.
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
/// * [glass] — Figma Style **Glass**. Translucent Liquid Glass. Default
///   material is [LiquidGlassStyle.regularSmall]; pass
///   [LiquidGlassStyle.clear] over rich media.
/// * [prominent] — Figma Style **Glass Prominent**. White backing plus an
///   opaque System Blue tint (system red when [GlassButtonRole.destructive]).
///   White label.
///
/// Materials Thick is never a button fill.
enum GlassButtonProminence {
  /// Kit **Glass**.
  glass,

  /// Kit **Glass Prominent**.
  prominent,
}

/// Figma **Button - Liquid Glass - Text** `Size` axis.
///
/// These are control sizes. They are not Liquid Glass material names.
/// **Regular Small** is the default material ([LiquidGlassStyle.regularSmall]),
/// and the matching default control size is [small].
enum GlassButtonSize {
  /// About 28pt tall. Padding 10 × 5 (horizontal × vertical).
  small,

  /// About 34pt tall. Padding 12 × 8 (horizontal × vertical).
  medium,

  /// About 50pt tall. Padding 20 × 16 (horizontal × vertical).
  large,
}

/// Button control metrics from the Figma Text export.
///
/// Heights are the acceptance brief's "约 28 / 34 / 50". Padding is written
/// horizontal × vertical because that is the pair that lands on those
/// heights with an 18pt content slot (5×2+18=28, 8×2+18=34, 16×2+18=50).
///
/// Not a blur / frost / radius token. Panel radii 18 / 26 / 34 stay
/// unverified and are not used here — buttons are capsules.
@immutable
class GlassButtonMetrics {
  const GlassButtonMetrics({required this.height, required this.padding});

  /// Small control. Default. Aligns with the "Regular Small" material name.
  static const GlassButtonMetrics small = GlassButtonMetrics(
    height: 28,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  );

  /// Medium control.
  static const GlassButtonMetrics medium = GlassButtonMetrics(
    height: 34,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  /// Large control. Figma representative node is Glass Prominent Large.
  static const GlassButtonMetrics large = GlassButtonMetrics(
    height: 50,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );

  static GlassButtonMetrics forSize(GlassButtonSize size) {
    return switch (size) {
      GlassButtonSize.small => small,
      GlassButtonSize.medium => medium,
      GlassButtonSize.large => large,
    };
  }

  /// Control height in logical pixels.
  final double height;

  /// Insets inside the capsule. Horizontal × vertical as documented above.
  final EdgeInsets padding;

  /// Label / icon slot. 18 for every published size.
  double get contentExtent => height - padding.vertical;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlassButtonMetrics &&
        other.height == height &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(height, padding);
}

/// First-party **Liquid Glass Button**.
///
/// One widget, several kit treatments — do not add a parallel button type.
///
/// * Default material: [LiquidGlassStyle.regularSmall] (Style Glass).
/// * Default control size: [GlassButtonSize.small] (about 28pt).
/// * [LiquidGlassStyle.clear] over rich media.
/// * [GlassButtonRole.destructive] for the kit Destructive role.
/// * [GlassButtonProminence.prominent] for Glass Prominent.
/// * [GlassButton.icon] for the Symbol variant.
///
/// **Not** Materials Thick — that fill is reserved for Sheet / Sidebar
/// chrome. Labels on Glass use [LiquidGlassLabels] Light Primary
/// `#1A1A1A` / Dark Primary `#EDEDED`. Filled Glass Prominent uses white.
/// The kit face is SF Pro Medium; this package does not bundle SF Pro, so
/// the label uses [FontWeight.w500] on the ambient font.
///
/// Shape is a capsule (`border-radius: 1000`), not the unverified panel
/// radii 18 / 26 / 34.
///
/// States:
/// * Default — glass, or White Backing + accent tint when prominent.
/// * Pressed — scale 0.97 plus a press veil. The veil is an implementation
///   approximation, not a kit token (Figma's button axis has no Pressed
///   variant; [forcePressed] only pins the demo).
/// * Disabled — `onPressed == null`. Glass keeps the material and switches
///   the label to tertiary. Glass Prominent keeps the accent fill and drops
///   to about 50% opacity.
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = LiquidGlassStyle.regularSmall,
    this.role = GlassButtonRole.normal,
    this.prominence = GlassButtonProminence.glass,
    this.size = GlassButtonSize.small,
    this.forcePressed = false,
    this.padding,
    this.minimumSize,
    this.borderRadius,
    this.forceOpaque = false,
    this.enableHoverHighlight = true,
    this.semanticLabel,
  });

  /// Label + optional leading icon.
  ///
  /// Color comes from the role, prominence, and enabled state.
  factory GlassButton.label({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    LiquidGlassStyle style = LiquidGlassStyle.regularSmall,
    GlassButtonRole role = GlassButtonRole.normal,
    GlassButtonProminence prominence = GlassButtonProminence.glass,
    GlassButtonSize size = GlassButtonSize.small,
    bool forcePressed = false,
    bool forceOpaque = false,
    String? semanticLabel,
  }) {
    return GlassButton(
      key: key,
      onPressed: onPressed,
      style: style,
      role: role,
      prominence: prominence,
      size: size,
      forcePressed: forcePressed,
      forceOpaque: forceOpaque,
      semanticLabel: semanticLabel,
      child: _GlassButtonLabel(label: label, icon: icon),
    );
  }

  /// Figma **Button - Liquid Glass - Symbol**.
  ///
  /// Same style, role, prominence, and enabled axes as text. The capsule is
  /// a circle whose diameter is the text control's height (Small 28,
  /// Medium 34, Large 50). Symbol frames were not re-measured after the
  /// Figma rate limit; Large landing on 50 matches the brief's Large height.
  factory GlassButton.icon({
    Key? key,
    required IconData icon,
    required String semanticLabel,
    VoidCallback? onPressed,
    LiquidGlassStyle style = LiquidGlassStyle.regularSmall,
    GlassButtonRole role = GlassButtonRole.normal,
    GlassButtonProminence prominence = GlassButtonProminence.glass,
    GlassButtonSize size = GlassButtonSize.small,
    bool forcePressed = false,
    bool forceOpaque = false,
  }) {
    final metrics = GlassButtonMetrics.forSize(size);
    final inset = (metrics.height - iconSize) / 2;
    return GlassButton(
      key: key,
      onPressed: onPressed,
      style: style,
      role: role,
      prominence: prominence,
      size: size,
      forcePressed: forcePressed,
      forceOpaque: forceOpaque,
      padding: EdgeInsets.all(inset),
      semanticLabel: semanticLabel,
      child: Icon(icon, size: iconSize),
    );
  }

  final VoidCallback? onPressed;
  final Widget child;

  /// Liquid Glass kit style. Default: Regular Small (button material).
  ///
  /// [LiquidGlassStyle.clear] is the rich-media path. Ignored as a fill
  /// when [prominence] is [GlassButtonProminence.prominent] — Prominent
  /// paints White Backing + an opaque accent, and still keeps this style's
  /// ~0.5px hairline and specular. The corner is always the button capsule,
  /// even when the style's panel radius is 18 / 26 / 34.
  final LiquidGlassStyle style;

  /// Kit **Destructive** role. Default: [GlassButtonRole.normal].
  final GlassButtonRole role;

  /// Kit **Glass** vs **Glass Prominent**.
  final GlassButtonProminence prominence;

  /// Figma Size axis. Default: [GlassButtonSize.small].
  final GlassButtonSize size;

  /// Pins the pressed treatment so a gallery can show it without a pointer.
  ///
  /// Pointer presses still animate when this is false. The press wash is
  /// not a Design Token.
  final bool forcePressed;

  /// Overrides [GlassButtonMetrics.padding] when non-null.
  final EdgeInsetsGeometry? padding;

  /// Overrides the control's minimum size when non-null.
  ///
  /// Height also replaces the size preset's height. Width is a floor; the
  /// capsule still grows with the label.
  final Size? minimumSize;

  /// Overrides the capsule radius. Null keeps [capsuleRadius].
  final BorderRadius? borderRadius;

  final bool forceOpaque;
  final bool enableHoverHighlight;

  /// Spoken name for icon-only buttons. Text buttons use their label.
  final String? semanticLabel;

  bool get enabled => onPressed != null;

  /// Figma Text export: `border-radius: 1000px` (stadium / capsule).
  ///
  /// Not the panel radii 18 / 26 / 34, which stay unverified.
  static const BorderRadius capsuleRadius = BorderRadius.all(
    Radius.circular(1000),
  );

  /// Kit label face is SF Pro Medium. Ambient font, weight 500.
  static const FontWeight labelWeight = FontWeight.w500;

  /// Glyph size that fills the 18pt content slot shared by every size.
  ///
  /// The Text Styles page was not re-read (Figma rate limit). 18 is the
  /// slot implied by the published height and padding, not a separate
  /// type-ramp token. Do not relabel it as Frost, Depth, or a blur sigma.
  static const double iconSize = 18;

  /// Same source as [iconSize]. One point under the slot so the glyph
  /// stays inside the 18pt line.
  static const double labelFontSize = 17;

  /// Disabled Glass Prominent opacity from the acceptance brief ("约 50%").
  ///
  /// The accent fill stays. This is not a blur or material token.
  static const double prominentDisabledOpacity = 0.5;

  /// Tokens for this button.
  ///
  /// Glass Prominent replaces the veil with an opaque System Blue or system
  /// red (White Backing sits under that tint in the widget). Disabled
  /// Prominent keeps the fill; the widget fades the whole control to
  /// [prominentDisabledOpacity]. Never substitutes Materials Thick.
  ///
  /// [LiquidGlassTokens.blurSigma] is left on the style preset. It is an
  /// implementation approximation, not a Frost/Depth kit value.
  static LiquidGlassTokens resolveTokens({
    required LiquidGlassTokens base,
    required GlassButtonPalette palette,
    required GlassButtonProminence prominence,
    required GlassButtonRole role,
    required bool enabled,
  }) {
    final filled = prominence == GlassButtonProminence.prominent;
    if (!filled) return base;
    final fill = role == GlassButtonRole.destructive
        ? palette.systemRed
        : palette.systemBlue;
    return base.copyWith(
      tintColor: fill,
      overlayColor: const Color(0x00FFFFFF),
      overlayBlend: BlendMode.srcOver,
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
    if (prominence == GlassButtonProminence.prominent) {
      return palette.filledLabel;
    }
    if (!enabled) return palette.disabledLabel;
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
    final metrics = GlassButtonMetrics.forSize(widget.size);
    final padding = widget.padding ?? metrics.padding;
    final controlHeight = widget.minimumSize?.height ?? metrics.height;
    final minWidth = widget.minimumSize?.width ?? 0;
    final slot = math.max(0.0, controlHeight - padding.vertical);
    final radius = widget.borderRadius ?? GlassButton.capsuleRadius;
    final labelColor = GlassButton.resolveLabelColor(
      palette: palette,
      brightness: Theme.brightnessOf(context),
      role: widget.role,
      prominence: widget.prominence,
      enabled: widget.enabled,
    );
    final scale = _showPressed ? 0.97 : 1.0;
    final dimProminent =
        !widget.enabled && widget.prominence == GlassButtonProminence.prominent;

    Widget visual = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.prominence == GlassButtonProminence.prominent)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: GlassButtonPalette.prominentBacking,
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          GlassSurface(
            tokens: tokens,
            borderRadius: radius,
            padding: padding,
            forceOpaque: widget.forceOpaque,
            enableHoverHighlight: widget.enableHoverHighlight && widget.enabled,
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(height: slot),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: GlassButton.iconSize,
                    color: labelColor,
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: labelColor,
                      fontWeight: GlassButton.labelWeight,
                      fontSize: GlassButton.labelFontSize,
                      height: 1,
                    ),
                    child: widget.child,
                  ),
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
    );

    if (dimProminent) {
      visual = Opacity(
        opacity: GlassButton.prominentDisabledOpacity,
        child: visual,
      );
    }

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
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
            child: visual,
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
      children: [
        Icon(icon, size: GlassButton.iconSize),
        const SizedBox(width: 8),
        text,
      ],
    );
  }
}
