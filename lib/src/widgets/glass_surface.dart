import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../adaptivity/lingyun_adaptivity.dart';
import '../theme/liquid_glass_theme.dart';
import '../tokens/glass_material.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import '../tokens/liquid_glass_tokens.dart';

/// A frosted panel that can paint **Materials** or **Liquid Glass**.
///
/// Works on iPhone, foldables, iPad, macOS, and web. The public API is
/// size-class and token based — it does not call device-model APIs.
///
/// Resolve order: [tokens] → [style] (Liquid Glass) → [material]
/// (Materials, default Regular). Do not pass a Materials tier when you
/// mean a Liquid Glass style (or the reverse).
///
/// Layers (bottom → top):
/// 1. Soft deep shadow + crisp grey rim + side hairlines (~0.5px)
/// 2. [BackdropFilter] blur (`TileMode.clamp`, no `bounds` named param)
/// 3. Saturation [ColorFilter]
/// 4. Tint fill
/// 5. Sketch-style overlay (Luminosity / Lighten)
/// 6. Inner-lip shadows (kit specular) + tight top-leading catch
/// 7. Directional inner refraction rim (not a second white border)
/// 8. Quiet outer hairline
/// 9. [child]
///
/// Accessibility: [LingyunAdaptivity.useOpaqueFallback] — Reduce
/// Transparency, high contrast ([MediaQuery] or gallery toggle), or
/// [forceOpaque] — paints [LiquidGlassTokens.opaqueFallbackColor].
///
/// Pointer platforms: when [enableHoverHighlight] is true, hovering
/// slightly boosts the specular wash. Touch devices ignore this.
class GlassSurface extends StatefulWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.tokens,
    this.material,
    this.style,
    this.radiusScale,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
    this.forceOpaque = false,
    this.showShadow = true,
    this.enableHoverHighlight = true,
  });

  /// Content drawn above the glass layers.
  final Widget child;

  /// Optional token override; wins over [style] and [material].
  final LiquidGlassTokens? tokens;

  /// **A. Materials** tier (Ultrathin / Thin / Regular / Thick).
  ///
  /// Ignored when [tokens] or [style] is set. Defaults to
  /// [MaterialTier.regular] when both [style] and [tokens] are null.
  final MaterialTier? material;

  /// **B. Liquid Glass** kit style (Clear / Regular S·M·L / Dock / Widget).
  ///
  /// Wins over [material]. Ignored when [tokens] is set.
  /// Button default is [LiquidGlassStyle.regularSmall] via [GlassButton].
  final LiquidGlassStyle? style;

  /// Optional Large / Medium / Small corner override.
  ///
  /// When null, [borderRadius] or the token radius is used.
  final GlassRadiusScale? radiusScale;

  /// Optional explicit corner override (wins over [radiusScale]).
  final BorderRadius? borderRadius;

  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  /// Force the opaque accessibility fallback regardless of MediaQuery.
  final bool forceOpaque;

  /// Whether to paint the token shadow stack.
  final bool showShadow;

  /// Boost specular opacity while a fine pointer hovers (macOS / desktop web).
  final bool enableHoverHighlight;

  static bool shouldUseOpaqueFallback(
    BuildContext context, {
    required bool forceOpaque,
  }) {
    return LingyunAdaptivity.useOpaqueFallback(
      context,
      forceOpaque: forceOpaque,
    );
  }

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface> {
  bool _hover = false;

  BorderRadius _radius(LiquidGlassTokens tokens) {
    if (widget.borderRadius != null) return widget.borderRadius!;
    if (widget.radiusScale != null) {
      return LiquidGlassRadii.borderRadius(widget.radiusScale!);
    }
    return tokens.borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    final resolved =
        widget.tokens ??
        (widget.style != null
            ? LiquidGlassTheme.styleOf(context, widget.style!)
            : LiquidGlassTheme.materialOf(
                context,
                widget.material ?? MaterialTier.regular,
              ));
    final radius = _radius(resolved);
    final useOpaque = GlassSurface.shouldUseOpaqueFallback(
      context,
      forceOpaque: widget.forceOpaque,
    );

    final content = Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: widget.child,
      ),
    );

    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
    final curve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
    final specularBoost = widget.enableHoverHighlight && _hover && !useOpaque
        ? 1.22
        : 1.0;
    final highlight = resolved.edgeHighlightColor.withValues(
      alpha: (resolved.edgeHighlightColor.a * specularBoost).clamp(0.0, 1.0),
    );

    final Widget surface;
    if (useOpaque) {
      surface = Material(
        color: resolved.opaqueFallbackColor,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: resolved.borderColor,
            width: resolved.borderWidth,
          ),
        ),
        clipBehavior: widget.clipBehavior,
        elevation: 0,
        child: content,
      );
    } else {
      // iOS 27 Liquid Glass stack (platform-agnostic implementation):
      // clamp-tiled blur → saturate → tint → luminosity/lighten overlay →
      // inner-lip + top-leading catch → directional refraction → quiet
      // hairline. Child is never ColorFiltered so labels stay readable.
      surface = ClipRRect(
        borderRadius: radius,
        clipBehavior: widget.clipBehavior,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final glassSize = Size(
              constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
              constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
            );
            final blur = glassSize.longestSide > 0
                ? resolved.boundedBlurFilter(glassSize)
                : resolved.blurFilter;
            return Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: blur,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        resolved.saturationMatrix,
                      ),
                      child: const ColoredBox(color: Color(0x00FFFFFF)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: resolved.tintColor,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GlassLightingPainter(
                        borderRadius: radius,
                        overlayColor: resolved.overlayColor,
                        overlayBlend: resolved.overlayBlend,
                        innerShadowColor: resolved.innerShadowColor,
                        innerShadowExtent: resolved.innerShadowExtent,
                        specular: highlight,
                        refractionColor: resolved.refractionColor,
                        refractionWidth: resolved.refractionWidth,
                        hairlineColor: resolved.borderColor,
                        hairlineWidth: resolved.borderWidth,
                      ),
                    ),
                  ),
                ),
                content,
              ],
            );
          },
        ),
      );
    }

    Widget result = surface;
    if (widget.showShadow && !useOpaque) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: resolved.copyWith(borderRadius: radius).shadows,
        ),
        child: surface,
      );
    }

    if (widget.enableHoverHighlight && !useOpaque) {
      result = MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: result,
      );
    }

    if (widget.width != null || widget.height != null) {
      result = SizedBox(
        width: widget.width,
        height: widget.height,
        child: result,
      );
    }
    if (widget.alignment != null) {
      result = Align(alignment: widget.alignment!, child: result);
    }

    return result;
  }
}

/// Convenience glass card with standard padding.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.tokens,
    this.material,
    this.style,
    this.radiusScale,
    this.borderRadius,
    this.padding = const EdgeInsets.all(20),
    this.forceOpaque = false,
    this.enableHoverHighlight = true,
  });

  final Widget child;
  final LiquidGlassTokens? tokens;
  final MaterialTier? material;
  final LiquidGlassStyle? style;
  final GlassRadiusScale? radiusScale;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool forceOpaque;
  final bool enableHoverHighlight;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tokens: tokens,
      material: material,
      style: style,
      radiusScale: radiusScale,
      borderRadius: borderRadius,
      padding: padding,
      forceOpaque: forceOpaque,
      enableHoverHighlight: enableHoverHighlight,
      child: child,
    );
  }
}

/// Paints overlay, inner-lip specular, directional refraction, hairline.
class _GlassLightingPainter extends CustomPainter {
  const _GlassLightingPainter({
    required this.borderRadius,
    required this.overlayColor,
    required this.overlayBlend,
    required this.innerShadowColor,
    required this.innerShadowExtent,
    required this.specular,
    required this.refractionColor,
    required this.refractionWidth,
    required this.hairlineColor,
    required this.hairlineWidth,
  });

  final BorderRadius borderRadius;
  final Color overlayColor;
  final BlendMode overlayBlend;
  final Color innerShadowColor;
  final double innerShadowExtent;
  final Color specular;
  final Color refractionColor;
  final double refractionWidth;
  final Color hairlineColor;
  final double hairlineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final bounds = Offset.zero & size;
    final rrect = borderRadius.toRRect(bounds);
    canvas.save();
    canvas.clipRRect(rrect);

    if (overlayColor.a > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = overlayColor
          ..blendMode = overlayBlend,
      );
    }

    final lip = math.min(innerShadowExtent, size.height * 0.42);
    if (lip > 0 && innerShadowColor.a > 0) {
      final top = Rect.fromLTWH(0, 0, size.width, lip);
      canvas.drawRect(
        top,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [innerShadowColor, innerShadowColor.withValues(alpha: 0)],
          ).createShader(top),
      );
      final bottom = Rect.fromLTWH(0, size.height - lip, size.width, lip);
      canvas.drawRect(
        bottom,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [innerShadowColor, innerShadowColor.withValues(alpha: 0)],
          ).createShader(bottom),
      );
    }

    if (specular.a > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.78, -0.92),
            radius: 0.72,
            colors: [
              specular,
              specular.withValues(alpha: specular.a * 0.22),
              specular.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.22, 0.55],
          ).createShader(bounds)
          ..blendMode = BlendMode.softLight,
      );
    }

    if (refractionWidth > 0 && refractionColor.a > 0) {
      final inset = rrect.deflate(refractionWidth * 0.5 + 0.55);
      canvas.drawRRect(
        inset,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = refractionWidth
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              refractionColor,
              refractionColor.withValues(alpha: refractionColor.a * 0.28),
              refractionColor.withValues(alpha: 0.03),
            ],
            stops: const [0.0, 0.38, 1.0],
          ).createShader(bounds),
      );
    }

    if (hairlineWidth > 0 && hairlineColor.a > 0) {
      canvas.drawRRect(
        rrect.deflate(hairlineWidth * 0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = hairlineWidth
          ..color = hairlineColor,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlassLightingPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.overlayBlend != overlayBlend ||
        oldDelegate.innerShadowColor != innerShadowColor ||
        oldDelegate.innerShadowExtent != innerShadowExtent ||
        oldDelegate.specular != specular ||
        oldDelegate.refractionColor != refractionColor ||
        oldDelegate.refractionWidth != refractionWidth ||
        oldDelegate.hairlineColor != hairlineColor ||
        oldDelegate.hairlineWidth != hairlineWidth;
  }
}
