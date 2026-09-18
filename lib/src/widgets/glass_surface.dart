import 'package:flutter/material.dart';

import '../theme/liquid_glass_theme.dart';
import '../tokens/liquid_glass_tokens.dart';

/// A frosted glass panel inspired by Apple Liquid Glass.
///
/// Layers (bottom → top):
/// 1. Soft drop shadow (optional)
/// 2. [BackdropFilter] blur
/// 3. Saturation [ColorFilter]
/// 4. Tint fill + edge-highlight gradient + border
/// 5. [child]
///
/// Accessibility: when [MediaQueryData.highContrast] is true, or when
/// [forceOpaque] is set (e.g. user toggled Reduce Transparency in the demo),
/// the surface paints [LiquidGlassTokens.opaqueFallbackColor] instead of blur.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.tokens,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
    this.forceOpaque = false,
    this.showShadow = true,
  });

  /// Content drawn above the glass layers.
  final Widget child;

  /// Optional token override; defaults to [LiquidGlassTheme.tokensOf].
  final LiquidGlassTokens? tokens;

  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  /// Force the opaque accessibility fallback regardless of MediaQuery.
  final bool forceOpaque;

  /// Whether to paint the soft drop shadow from tokens.
  final bool showShadow;

  static bool shouldUseOpaqueFallback(
    BuildContext context, {
    required bool forceOpaque,
  }) {
    if (forceOpaque) return true;
    return MediaQuery.highContrastOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final resolved = tokens ?? LiquidGlassTheme.tokensOf(context);
    final useOpaque = shouldUseOpaqueFallback(
      context,
      forceOpaque: forceOpaque,
    );

    final content = Padding(padding: padding ?? EdgeInsets.zero, child: child);

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
        clipBehavior: clipBehavior,
        elevation: 0,
        child: content,
      );
    } else {
      surface = ClipRRect(
        borderRadius: resolved.borderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: resolved.blurFilter,
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(resolved.saturationMatrix),
            child: DecoratedBox(
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
                    resolved.edgeHighlightColor,
                    resolved.edgeHighlightColor.withValues(alpha: 0),
                    resolved.tintColor.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
              child: content,
            ),
          ),
        ),
      );
    }

    Widget result = surface;
    if (showShadow && !useOpaque) {
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

    if (width != null || height != null) {
      result = SizedBox(width: width, height: height, child: result);
    }
    if (alignment != null) {
      result = Align(alignment: alignment!, child: result);
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
    this.padding = const EdgeInsets.all(20),
    this.forceOpaque = false,
  });

  final Widget child;
  final LiquidGlassTokens? tokens;
  final EdgeInsetsGeometry padding;
  final bool forceOpaque;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tokens: tokens,
      padding: padding,
      forceOpaque: forceOpaque,
      child: child,
    );
  }
}
