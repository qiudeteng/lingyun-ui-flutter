import 'package:flutter/material.dart';

import '../adaptivity/lingyun_adaptivity.dart';
import '../theme/liquid_glass_theme.dart';
import '../tokens/glass_material.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_tokens.dart';

/// A frosted glass panel inspired by Apple Liquid Glass.
///
/// Works on iPhone, foldables, iPad, macOS, and web. The public API is
/// size-class and token based — it does not call device-model APIs.
///
/// Layers (bottom → top):
/// 1. Soft drop shadow (optional)
/// 2. [BackdropFilter] blur
/// 3. Saturation [ColorFilter]
/// 4. Tint fill
/// 5. Specular highlight (top-leading → bottom-trailing)
/// 6. Refraction inner rim + outer hairline border
/// 7. [child]
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
    this.material = GlassMaterialTier.regular,
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

  /// Optional token override; defaults to theme tokens for [material].
  final LiquidGlassTokens? tokens;

  /// Thin / regular / thick recipe. Ignored when [tokens] is set.
  final GlassMaterialTier material;

  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  /// Force the opaque accessibility fallback regardless of MediaQuery.
  final bool forceOpaque;

  /// Whether to paint the soft drop shadow from tokens.
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

  @override
  Widget build(BuildContext context) {
    final resolved =
        widget.tokens ??
        LiquidGlassTheme.tokensOf(context, tier: widget.material);
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
        ? 1.18
        : 1.0;
    final highlight = resolved.edgeHighlightColor.withValues(
      alpha: (resolved.edgeHighlightColor.a * specularBoost).clamp(0.0, 1.0),
    );

    final Widget surface;
    if (useOpaque) {
      surface = Material(
        color: resolved.opaqueFallbackColor,
        shape: RoundedRectangleBorder(
          borderRadius: resolved.borderRadius,
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
      // bounded blur → saturate backdrop → tint → face specular →
      // top-edge sheen → refraction rim → hairline. Child is never
      // ColorFiltered so labels stay readable on iPhone / Duo / iPad / macOS.
      surface = ClipRRect(
        borderRadius: resolved.borderRadius,
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
                      borderRadius: resolved.borderRadius,
                      color: resolved.tintColor,
                      border: Border.all(
                        color: resolved.borderColor,
                        width: resolved.borderWidth,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          highlight,
                          highlight.withValues(alpha: 0.18),
                          highlight.withValues(alpha: 0),
                        ],
                        stops: const [0.0, 0.22, 0.55],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: resolved.borderRadius,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: const Alignment(0, -0.55),
                          colors: [
                            highlight.withValues(
                              alpha: (highlight.a * 0.55).clamp(0.0, 1.0),
                            ),
                            highlight.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: resolved.borderRadius,
                        border: Border.all(
                          color: resolved.refractionColor,
                          width: resolved.refractionWidth,
                        ),
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
          borderRadius: resolved.borderRadius,
          boxShadow: [
            BoxShadow(
              color: resolved.shadowColor,
              blurRadius: resolved.shadowBlurRadius,
              offset: resolved.shadowOffset,
            ),
          ],
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
    this.material = GlassMaterialTier.regular,
    this.padding = const EdgeInsets.all(20),
    this.forceOpaque = false,
    this.enableHoverHighlight = true,
  });

  final Widget child;
  final LiquidGlassTokens? tokens;
  final GlassMaterialTier material;
  final EdgeInsetsGeometry padding;
  final bool forceOpaque;
  final bool enableHoverHighlight;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tokens: tokens,
      material: material,
      padding: padding,
      forceOpaque: forceOpaque,
      enableHoverHighlight: enableHoverHighlight,
      child: child,
    );
  }
}
