import 'package:flutter/material.dart';

import '../theme/liquid_glass_theme.dart';
import '../tokens/liquid_glass_labels.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import 'glass_surface.dart';

/// First-party **Liquid Glass Button**.
///
/// Default style is [LiquidGlassStyle.regularSmall] (kit Regular Small,
/// 48pt capsule). Use [LiquidGlassStyle.clear] over rich media.
///
/// **Not** Materials Thick — that fill is reserved for Sheet / Sidebar
/// chrome. Labels use [LiquidGlassLabels] Light Primary `#1A1A1A` /
/// Dark Primary `#EDEDED`.
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = LiquidGlassStyle.regularSmall,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.minimumSize = const Size(48, 48),
    this.borderRadius,
    this.forceOpaque = false,
    this.enableHoverHighlight = true,
  });

  /// Label + optional leading icon, colored with [LiquidGlassLabels].
  factory GlassButton.label({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    LiquidGlassStyle style = LiquidGlassStyle.regularSmall,
    bool forceOpaque = false,
  }) {
    return GlassButton(
      key: key,
      onPressed: onPressed,
      style: style,
      forceOpaque: forceOpaque,
      child: _GlassButtonLabel(label: label, icon: icon),
    );
  }

  final VoidCallback? onPressed;
  final Widget child;

  /// Liquid Glass kit style. Default: Regular Small (button).
  final LiquidGlassStyle style;

  final EdgeInsetsGeometry padding;
  final Size minimumSize;
  final BorderRadius? borderRadius;
  final bool forceOpaque;
  final bool enableHoverHighlight;

  bool get enabled => onPressed != null;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

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
    final tokens = LiquidGlassTheme.styleOf(context, widget.style);
    final radius = widget.borderRadius ?? tokens.borderRadius;
    final scale = widget.enabled && _pressed ? 0.97 : 1.0;

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
            child: AnimatedOpacity(
              opacity: widget.enabled ? 1 : 0.45,
              duration: duration,
              curve: curve,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: widget.minimumSize.width,
                  minHeight: widget.minimumSize.height,
                ),
                child: GlassSurface(
                  style: widget.style,
                  borderRadius: radius,
                  padding: widget.padding,
                  forceOpaque: widget.forceOpaque,
                  enableHoverHighlight:
                      widget.enableHoverHighlight && widget.enabled,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      size: 18,
                      color: LiquidGlassLabels.primaryOf(context),
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: LiquidGlassLabels.primaryOf(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        height: 1.2,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
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
    final color = LiquidGlassLabels.primaryOf(context);
    final text = Text(label, textAlign: TextAlign.center);
    if (icon == null) {
      return text;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        text,
      ],
    );
  }
}
