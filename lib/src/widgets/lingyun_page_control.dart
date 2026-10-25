import 'package:material_ui/material_ui.dart';

import '../theme/lingyun_theme.dart';
import '../theme/liquid_glass_theme.dart';
import '../tokens/liquid_glass_style.dart';
import 'glass_button.dart';
import 'glass_surface.dart';
import 'liquid_glass_spring_value.dart';

/// Drawing sizes for [LingyunPageControl]. Not motion tokens.
///
/// Dot diameter 7 and gap 9 are the classic page-indicator body.
/// The iOS 27 platter was not re-measured (Figma MCP limit), so these
/// stay **待核验**. They are not kit tokens.
@immutable
class LingyunPageControlMetrics {
  const LingyunPageControlMetrics._();

  static const double dotDiameter = 7;
  static const double gap = 9;

  /// Padding inside the optional Liquid Glass platter. **待核验**.
  static const double platterPaddingH = 12;
  static const double platterPaddingV = 8;

  static double stride() => dotDiameter + gap;

  static double rowWidth(int count) {
    if (count <= 0) return 0;
    return count * dotDiameter + (count - 1) * gap;
  }

  /// Physical left edge of the current dot. [index] may be fractional
  /// while the spring is running.
  static double highlightLeft(int count, double index, {bool rtl = false}) {
    final visual = rtl ? (count - 1 - index) : index;
    return visual * stride();
  }
}

/// iOS page control.
///
/// Current page is a solid dot. The others are lower contrast. [tint]
/// recolors the current dot; without it the dot uses Liquid Glass Primary
/// and the rest use Liquid Glass tertiary, so light and dark stay readable.
///
/// Dots are content. They are not Liquid Glass and not Materials Thick.
/// [platter] puts them on one [GlassSurface] at [LiquidGlassStyle.regularSmall]
/// so a busy wallpaper still has a glass lens behind the indicators.
///
/// Default is indicator-only (`onChanged == null`). No hit target is added.
/// Pass [onChanged] only when a caller wants taps. The Human Interface
/// Guidelines treat the control as a position indicator for a swipe.
///
/// When [currentIndex] changes, the highlight travels with the same
/// [LiquidGlassSpringValue] as the segmented lens (system spring, no new
/// bounce token). Reduce Motion snaps the highlight.
class LingyunPageControl extends StatelessWidget {
  const LingyunPageControl({
    super.key,
    required this.count,
    required this.currentIndex,
    this.onChanged,
    this.tint,
    this.platter = false,
    this.glassStyle = LiquidGlassStyle.regularSmall,
    this.brightness,
    this.semanticLabel,
  });

  /// The moving current-page dot.
  static const Key highlightKey = Key('lingyun-page-highlight');

  /// Present only when [onChanged] is non-null.
  static const Key tapKey = Key('lingyun-page-tap');

  static Key inactiveDotKey(int index) => ValueKey<int>(index);

  final int count;
  final int currentIndex;

  /// Null keeps the control an indicator. A non-null callback enables taps.
  final ValueChanged<int>? onChanged;

  /// Current-dot color. Null uses Liquid Glass Primary.
  final Color? tint;

  /// Liquid Glass platter behind the dots. Off by default.
  final bool platter;

  /// Platter material. Ignored when [platter] is false.
  /// Not a [MaterialTier].
  final LiquidGlassStyle glassStyle;

  final Brightness? brightness;

  /// Spoken name. The gallery passes Simplified Chinese.
  /// The numeric value is always the 1-based page.
  final String? semanticLabel;

  bool get interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    assert(count >= 1, 'LingyunPageControl.count must be at least 1.');
    assert(
      currentIndex >= 0 && currentIndex < count,
      'LingyunPageControl.currentIndex ($currentIndex) is outside 0..$count.',
    );

    final body = Builder(builder: (context) => _buildBody(context));
    final override = brightness;
    if (override == null) return body;

    final theme = Theme.of(context);
    final glass = override == Brightness.dark
        ? LiquidGlassTheme.dark
        : LiquidGlassTheme.light;
    return Theme(
      data: theme.copyWith(brightness: override, extensions: [glass]),
      child: LingyunTheme(brightness: override, child: body),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    final current = tint ?? colors.liquidGlassLabels.primary;
    final inactive = tint == null
        ? colors.liquidGlassLabels.tertiary
        : tint!.withValues(alpha: 0.35);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final width = LingyunPageControlMetrics.rowWidth(count);
    final diameter = LingyunPageControlMetrics.dotDiameter;

    Widget dots = LiquidGlassSpringValue(
      value: currentIndex.toDouble(),
      builder: (context, t) {
        return SizedBox(
          width: width,
          height: diameter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < count; i++) ...[
                    if (i > 0)
                      const SizedBox(width: LingyunPageControlMetrics.gap),
                    _Dot(
                      key: inactiveDotKey(i),
                      color: inactive,
                      diameter: diameter,
                    ),
                  ],
                ],
              ),
              Positioned(
                left: LingyunPageControlMetrics.highlightLeft(
                  count,
                  t,
                  rtl: rtl,
                ),
                top: 0,
                child: _Dot(
                  key: highlightKey,
                  color: current,
                  diameter: diameter,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (interactive) {
      dots = GestureDetector(
        key: tapKey,
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final index = _indexFor(details.localPosition.dx);
          if (index != currentIndex) onChanged!(index);
        },
        child: dots,
      );
    }

    if (platter) {
      dots = GlassSurface(
        style: glassStyle,
        borderRadius: GlassButton.capsuleRadius,
        padding: const EdgeInsets.symmetric(
          horizontal: LingyunPageControlMetrics.platterPaddingH,
          vertical: LingyunPageControlMetrics.platterPaddingV,
        ),
        enableHoverHighlight: false,
        child: dots,
      );
    }

    final canIncrease = interactive && currentIndex < count - 1;
    final canDecrease = interactive && currentIndex > 0;
    return Semantics(
      container: true,
      label: semanticLabel,
      value: '${currentIndex + 1}',
      increasedValue: canIncrease ? '${currentIndex + 2}' : null,
      decreasedValue: canDecrease ? '$currentIndex' : null,
      onIncrease: canIncrease ? () => onChanged!(currentIndex + 1) : null,
      onDecrease: canDecrease ? () => onChanged!(currentIndex - 1) : null,
      child: dots,
    );
  }

  int _indexFor(double dx) {
    final stride = LingyunPageControlMetrics.stride();
    if (stride <= 0) return 0;
    return (dx / stride).floor().clamp(0, count - 1);
  }
}

class _Dot extends StatelessWidget {
  const _Dot({super.key, required this.color, required this.diameter});

  final Color color;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
