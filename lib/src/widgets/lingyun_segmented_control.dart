import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/lingyun_theme.dart';
import '../theme/liquid_glass_theme.dart';
import '../tokens/lingyun_text_styles.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import 'glass_button.dart';
import 'glass_surface.dart';
import 'liquid_glass_spring_value.dart';

/// Kit specimen size for [LingyunSegmentedControl].
///
/// These are drawing sizes, not motion tokens and not Materials tiers.
///
/// Apple's iOS 27 kit draws the control at 370×32 (small) and 370×50
/// (large). 370 is the specimen width on a 402pt board, not a fixed
/// control width — the widget sizes to its parent. Large segment height
/// 46 is 50 minus the 2pt inset on each edge. Small segment height 28 is
/// the same arithmetic. Figma was not re-read this session (MCP limit),
/// so the inset and the gap stay **待核验**.
enum LingyunSegmentedControlSize {
  /// Track about 32pt tall. Selection lens about 28pt.
  small,

  /// Track about 50pt tall. Selection lens about 46pt.
  large,
}

/// Drawing geometry for [LingyunSegmentedControl]. Not a motion token.
@immutable
class LingyunSegmentedMetrics {
  const LingyunSegmentedMetrics({required this.height});

  static const LingyunSegmentedMetrics small = LingyunSegmentedMetrics(
    height: 32,
  );
  static const LingyunSegmentedMetrics large = LingyunSegmentedMetrics(
    height: 50,
  );

  /// Specimen width on the 402pt board. The control itself stretches.
  static const double specimenWidth = 370;

  /// Inset of the lens inside the track. **待核验** vs the current Figma node.
  static const double padding = 2;

  /// Space between neighboring lenses. **待核验** vs the current Figma node.
  static const double gap = 4;

  /// Press scale shared with [GlassButton] (the Liquid Glass flex already
  /// shipped for buttons). Not a new kit token, and not the iOS 17 opaque
  /// thumb's 0.95.
  static const double pressedScale = 0.97;

  final double height;

  double get lensHeight => height - padding * 2;

  static LingyunSegmentedMetrics forSize(LingyunSegmentedControlSize size) {
    return switch (size) {
      LingyunSegmentedControlSize.small => small,
      LingyunSegmentedControlSize.large => large,
    };
  }

  static double cellWidth(double width, int count) {
    return (width - padding * 2) / count;
  }

  static double lensWidth(double width, int count) {
    return math.max(0, cellWidth(width, count) - gap);
  }

  /// Physical left edge of the lens. [index] may be fractional while the
  /// spring is running.
  static double lensLeft(
    double width,
    int count,
    double index, {
    bool rtl = false,
  }) {
    final visual = rtl ? (count - 1 - index) : index;
    return padding + visual * cellWidth(width, count) + gap / 2;
  }
}

/// One segment of a [LingyunSegmentedControl].
@immutable
class LingyunSegment<T> {
  const LingyunSegment({required this.value, required this.label});

  final T value;

  /// Visible label. The gallery passes Simplified Chinese.
  final String label;

  @override
  bool operator ==(Object other) {
    return other is LingyunSegment<T> &&
        other.value == value &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(value, label);
}

/// iOS 27 segmented control.
///
/// The selection is one Liquid Glass lens ([GlassSurface] at
/// [LiquidGlassStyle.regularSmall], the button material). It morphs from
/// segment to segment. It is not a second pill fading in, and it is not
/// Materials Thick.
///
/// The track is the system tertiary fill (`LingyunColors.fills.tertiary`,
/// the same role as tertiarySystemFill). That fill is not Liquid Glass
/// and not a Materials tier.
///
/// Selected label color follows the Glass button rule: Liquid Glass
/// Primary. [tint] recolors only that label (the lens stays glass). Tabs
/// paint the glyph in the tint; this control does not, unless [tint] is
/// set. Unselected labels use Liquid Glass secondary. Disabled
/// (`onChanged == null`) uses tertiary for every label and keeps the lens.
///
/// Motion, not a new token:
/// * The lens travels with [LiquidGlassSpringValue] (SwiftUI
///   `spring(duration:bounce:)` via Flutter, bounce left at the API
///   default, duration [LiquidGlassMotion.quick]).
/// * Press flexes the lens to [LingyunSegmentedMetrics.pressedScale] and
///   shows [GlassButtonPalette.pressedVeil], on the same quick duration
///   and curve as [GlassButton].
/// * Reduce Motion snaps the lens. No flight.
///
/// [CupertinoSlidingSegmentedControl] is not wrapped. Its thumb is an
/// opaque white / gray fill with an iOS 17 corner, not this lens.
class LingyunSegmentedControl<T> extends StatefulWidget {
  const LingyunSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    this.onChanged,
    this.size = LingyunSegmentedControlSize.small,
    this.glassStyle = LiquidGlassStyle.regularSmall,
    this.tint,
    this.brightness,
    this.forcePressed = false,
  });

  /// Layout key for the sliding lens. Shared by every control; scope
  /// queries with a parent key.
  static const Key lensKey = Key('lingyun-segmented-lens');

  /// Layout key for the track fill. Not a [GlassSurface].
  static const Key trackKey = Key('lingyun-segmented-track');

  final List<LingyunSegment<T>> segments;

  /// Value of the selected segment. Must match exactly one segment.
  final T selected;

  /// Called with the segment value on tap up. Null disables the control.
  final ValueChanged<T>? onChanged;

  final LingyunSegmentedControlSize size;

  /// Liquid Glass recipe for the selection lens. Default Regular Small.
  ///
  /// Not a [MaterialTier]. Materials Thick is sheet / sidebar chrome.
  final LiquidGlassStyle glassStyle;

  /// Recolors the selected label. Null keeps Liquid Glass Primary.
  /// The lens material does not change.
  final Color? tint;

  /// Overrides the ambient brightness for labels, fill, and glass.
  final Brightness? brightness;

  /// Pins the pressed flex so a gallery can show it without a pointer.
  final bool forcePressed;

  bool get enabled => onChanged != null;

  int get selectedIndex {
    return segments.indexWhere((segment) => segment.value == selected);
  }

  @override
  State<LingyunSegmentedControl<T>> createState() =>
      _LingyunSegmentedControlState<T>();
}

class _LingyunSegmentedControlState<T>
    extends State<LingyunSegmentedControl<T>> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    assert(
      widget.segments.length >= 2,
      'LingyunSegmentedControl needs at least two segments.',
    );
    assert(
      widget.selectedIndex >= 0,
      'LingyunSegmentedControl.selected must match a segment value.',
    );

    final body = Builder(builder: (context) => _buildBody(context));
    final override = widget.brightness;
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

  void _setPressed(int index, bool down) {
    if (!widget.enabled) return;
    setState(() => _pressedIndex = down ? index : null);
    if (down) return;
    final value = widget.segments[index].value;
    if (value != widget.selected) widget.onChanged!(value);
  }

  Widget _buildBody(BuildContext context) {
    final metrics = LingyunSegmentedMetrics.forSize(widget.size);
    final colors = LingyunTheme.colorsOf(context);
    final labels = colors.liquidGlassLabels;
    final selectedIndex = widget.selectedIndex;
    final pressed =
        widget.enabled &&
        (widget.forcePressed || _pressedIndex == selectedIndex);
    final pressDuration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
    final pressCurve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
    final veil = LiquidGlassTheme.buttonPaletteOf(context).pressedVeil;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : LingyunSegmentedMetrics.specimenWidth;
        final count = widget.segments.length;
        final lensWidth = LingyunSegmentedMetrics.lensWidth(width, count);

        return LiquidGlassSpringValue(
          value: selectedIndex.toDouble(),
          builder: (context, t) {
            final left = LingyunSegmentedMetrics.lensLeft(
              width,
              count,
              t,
              rtl: rtl,
            );
            return Semantics(
              container: true,
              explicitChildNodes: true,
              child: SizedBox(
                width: width,
                height: metrics.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        key: LingyunSegmentedControl.trackKey,
                        decoration: BoxDecoration(
                          color: colors.fills.tertiary,
                          borderRadius: GlassButton.capsuleRadius,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Positioned(
                      left: left,
                      top: LingyunSegmentedMetrics.padding,
                      width: lensWidth,
                      height: metrics.lensHeight,
                      child: AnimatedScale(
                        key: LingyunSegmentedControl.lensKey,
                        scale: pressed
                            ? LingyunSegmentedMetrics.pressedScale
                            : 1,
                        duration: pressDuration,
                        curve: pressCurve,
                        child: Stack(
                          children: [
                            GlassSurface(
                              style: widget.glassStyle,
                              width: lensWidth,
                              height: metrics.lensHeight,
                              borderRadius: GlassButton.capsuleRadius,
                              enableHoverHighlight: false,
                              child: const SizedBox.expand(),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  opacity: pressed ? 1 : 0,
                                  duration: pressDuration,
                                  curve: pressCurve,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: GlassButton.capsuleRadius,
                                      color: veil,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: LingyunSegmentedMetrics.padding,
                        ),
                        child: Row(
                          children: [
                            for (var i = 0; i < count; i++)
                              Expanded(
                                child: _SegmentLabel<T>(
                                  control: widget,
                                  index: i,
                                  selected: i == selectedIndex,
                                  primary: labels.primary,
                                  secondary: labels.secondary,
                                  disabled: labels.tertiary,
                                  duration: pressDuration,
                                  curve: pressCurve,
                                  onPressed: _setPressed,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SegmentLabel<T> extends StatelessWidget {
  const _SegmentLabel({
    required this.control,
    required this.index,
    required this.selected,
    required this.primary,
    required this.secondary,
    required this.disabled,
    required this.duration,
    required this.curve,
    required this.onPressed,
  });

  final LingyunSegmentedControl<T> control;
  final int index;
  final bool selected;
  final Color primary;
  final Color secondary;
  final Color disabled;
  final Duration duration;
  final Curve curve;
  final void Function(int index, bool down) onPressed;

  @override
  Widget build(BuildContext context) {
    final segment = control.segments[index];
    final enabled = control.enabled;
    final color = !enabled
        ? disabled
        : selected
        ? (control.tint ?? primary)
        : secondary;
    final style = control.size == LingyunSegmentedControlSize.large
        ? LingyunTextStyles.body(emphasized: selected, color: color)
        : LingyunTextStyles.footnote(emphasized: selected, color: color);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      inMutuallyExclusiveGroup: true,
      label: segment.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => onPressed(index, true) : null,
        onTapUp: enabled
            ? (_) {
                onPressed(index, false);
              }
            : null,
        onTapCancel: enabled ? () => onPressed(index, false) : null,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: duration,
            curve: curve,
            style: style,
            child: Text(
              segment.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
