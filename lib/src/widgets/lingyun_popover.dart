import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show Theme;

import '../adaptivity/lingyun_adaptivity.dart';
import '../page/lingyun_page.dart';
import '../page/lingyun_page_spec.dart';
import '../theme/lingyun_theme.dart';
import '../theme/liquid_glass_theme.dart';
import '../tokens/glass_material.dart';
import '../tokens/lingyun_colors.dart';
import '../tokens/lingyun_text_styles.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import 'glass_surface.dart';

/// Which side of the anchor the popover sits on.
///
/// The arrow points back at the anchor. [after] / [before] follow
/// [TextDirection]. This is not a device-idiom switch.
enum LingyunPopoverPlacement {
  /// Chrome below the anchor. Arrow on the top edge.
  below,

  /// Chrome above the anchor. Arrow on the bottom edge.
  above,

  /// Chrome after the anchor (right in LTR). Arrow on the near edge.
  after,

  /// Chrome before the anchor (left in LTR). Arrow on the near edge.
  before,
}

/// Physical edge the arrow is attached to.
enum LingyunPopoverArrowEdge { top, bottom, left, right }

/// Working geometry for an anchored popover. Not a Design Token.
///
/// Sketch **Popovers** was not measured (Figma MCP was rate-limited; the
/// Sketch page was not sampled). Numbers here are layout steps so the
/// anchor, arrow, and safe area have a place to live. Change them when
/// design measures the kit page.
abstract final class LingyunPopoverLayout {
  /// Glass body width cap. Historical popover width, not a kit token.
  /// 待核验 vs Sketch.
  static const double maxWidth = 320;

  /// Glass body width floor, so a short label still reads as a panel.
  /// 待核验.
  static const double minWidth = 240;

  /// Inset from the safe area. 待核验.
  static const double screenMargin = 16;

  /// Gap between the anchor and the arrow tip. 待核验.
  static const double anchorGap = 8;

  /// Arrow base along the glass edge. 待核验.
  static const double arrowBase = 20;

  /// Arrow length from the edge to the tip. 待核验.
  static const double arrowLength = 10;

  /// Padding inside the glass. 待核验.
  static const double contentPadding = 16;

  /// Vertical padding of one action row. 待核验. Not a control metric.
  static const double actionVerticalPadding = 8;

  /// Preferred side is kept when at least this much room remains.
  /// Otherwise the roomier side wins. 待核验.
  static const double minRoom = 96;

  /// No dim. HIG popovers dismiss on an outside tap; they are not alerts.
  /// Sketch's scrim was not sampled. 待核验.
  static const Color barrier = Color(0x00000000);
}

/// Motion for a popover. Forwards to [LiquidGlassMotion]. Not a spring token.
///
/// WWDC25 "Meet Liquid Glass" describes lensing, flex, and morph, and says
/// Reduce Motion disables elastic properties. It does not publish a
/// spring mass, stiffness, or damping for popovers. This type does not
/// add one. Enter / exit use the library standard duration and curve.
/// Press uses the library quick duration and [GlassButton]'s 0.97 scale.
abstract final class LingyunPopoverMotion {
  /// Enter and exit. [LiquidGlassMotion.standard] unless reduce-motion.
  static Duration duration(BuildContext context) {
    return LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.standard,
    );
  }

  /// Enter and exit curve. The library's existing standard cubic.
  ///
  /// Not a [SpringDescription]. Reduce-motion resolves this to linear,
  /// and [duration] to zero, so the scale does not travel.
  static Curve curve(BuildContext context) {
    return LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.standardCurve,
    );
  }

  /// Press flex. Same duration [GlassButton] uses.
  static Duration pressDuration(BuildContext context) {
    return LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
  }

  /// Press flex curve. Same curve [GlassButton] uses.
  static Curve pressCurve(BuildContext context) {
    return LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
  }

  /// Pressed scale. The same working value as [GlassButton] (0.97).
  ///
  /// WWDC describes flex without a scale. This is not a new measurement.
  static const double pressedScale = 0.97;
}

/// Anchor, safe area, and size class for one popover.
///
/// [bucket] uses [resolveFlutterPageBucket]. [horizontalSizeClass] is
/// `compact`, `regular`, `unspecified`, or null, the same contract as
/// [LingyunPage]. Null means Flutter has no system class. The class does
/// not switch the chrome to a sheet and does not read a device model.
@immutable
class LingyunPopoverMetrics {
  const LingyunPopoverMetrics({
    required this.bounds,
    required this.safeArea,
    required this.anchor,
    this.preferredPlacement,
    this.horizontalSizeClass,
    this.textDirection = TextDirection.ltr,
  });

  final Size bounds;
  final EdgeInsets safeArea;

  /// Anchor rect in the same coordinates as [bounds].
  final Rect anchor;

  final LingyunPopoverPlacement? preferredPlacement;

  /// `compact`, `regular`, `unspecified`, or null.
  final String? horizontalSizeClass;

  final TextDirection textDirection;

  LingyunPageWidthBucket get bucket {
    assert(
      horizontalSizeClass == null ||
          horizontalSizeClass == 'compact' ||
          horizontalSizeClass == 'regular' ||
          horizontalSizeClass == 'unspecified',
      'horizontalSizeClass must be compact, regular, unspecified, or null.',
    );
    final known =
        horizontalSizeClass == 'compact' ||
            horizontalSizeClass == 'regular' ||
            horizontalSizeClass == 'unspecified'
        ? horizontalSizeClass
        : null;
    return resolveFlutterPageBucket(
      width: bounds.width,
      horizontalSizeClass: known,
    );
  }

  /// Room between the anchor and the safe edge on [placement], after the
  /// margin and the anchor gap. Negative results clamp to zero.
  double roomFor(LingyunPopoverPlacement placement) {
    final margin = LingyunPopoverLayout.screenMargin;
    final gap = LingyunPopoverLayout.anchorGap;
    final raw = switch (placement) {
      LingyunPopoverPlacement.below =>
        bounds.height - safeArea.bottom - margin - anchor.bottom - gap,
      LingyunPopoverPlacement.above => anchor.top - safeArea.top - margin - gap,
      LingyunPopoverPlacement.after => _afterEdge - margin - gap,
      LingyunPopoverPlacement.before => _beforeEdge - margin - gap,
    };
    return math.max(0.0, raw);
  }

  double get _afterEdge {
    if (textDirection == TextDirection.rtl) {
      return anchor.left - safeArea.left;
    }
    return bounds.width - safeArea.right - anchor.right;
  }

  double get _beforeEdge {
    if (textDirection == TextDirection.rtl) {
      return bounds.width - safeArea.right - anchor.right;
    }
    return anchor.left - safeArea.left;
  }

  /// Preferred side when it has [LingyunPopoverLayout.minRoom].
  /// Otherwise the side with the most room. Ties break below, above,
  /// after, before.
  LingyunPopoverPlacement get placement {
    final preferred = preferredPlacement;
    if (preferred != null &&
        roomFor(preferred) >= LingyunPopoverLayout.minRoom) {
      return preferred;
    }
    var best = LingyunPopoverPlacement.below;
    var bestRoom = -1.0;
    for (final candidate in LingyunPopoverPlacement.values) {
      final room = roomFor(candidate);
      if (room > bestRoom) {
        bestRoom = room;
        best = candidate;
      }
    }
    return best;
  }

  static LingyunPopoverArrowEdge edgeFor(
    LingyunPopoverPlacement placement,
    TextDirection direction,
  ) {
    return switch (placement) {
      LingyunPopoverPlacement.below => LingyunPopoverArrowEdge.top,
      LingyunPopoverPlacement.above => LingyunPopoverArrowEdge.bottom,
      LingyunPopoverPlacement.after =>
        direction == TextDirection.rtl
            ? LingyunPopoverArrowEdge.right
            : LingyunPopoverArrowEdge.left,
      LingyunPopoverPlacement.before =>
        direction == TextDirection.rtl
            ? LingyunPopoverArrowEdge.left
            : LingyunPopoverArrowEdge.right,
    };
  }

  LingyunPopoverArrowEdge get arrowEdge => edgeFor(placement, textDirection);

  bool get _horizontalArrow =>
      placement == LingyunPopoverPlacement.after ||
      placement == LingyunPopoverPlacement.before;

  /// Max width of the glass body. The size class does not change the cap.
  double get maxBodyWidth {
    final arrow = _horizontalArrow ? LingyunPopoverLayout.arrowLength : 0.0;
    final available = math.max(
      0.0,
      bounds.width -
          safeArea.left -
          safeArea.right -
          LingyunPopoverLayout.screenMargin * 2 -
          arrow,
    );
    return math.min(available, LingyunPopoverLayout.maxWidth);
  }

  /// Max width of the chrome, including a side arrow.
  double get maxChromeWidth {
    final extra = _horizontalArrow ? LingyunPopoverLayout.arrowLength : 0.0;
    return maxBodyWidth + extra;
  }

  /// Top-left of a chrome of [chromeSize], including its arrow.
  Offset originFor(Size chromeSize) {
    final gap = LingyunPopoverLayout.anchorGap;
    return switch (placement) {
      LingyunPopoverPlacement.below => Offset(
        _clampX(anchor.center.dx - chromeSize.width / 2, chromeSize.width),
        anchor.bottom + gap,
      ),
      LingyunPopoverPlacement.above => Offset(
        _clampX(anchor.center.dx - chromeSize.width / 2, chromeSize.width),
        anchor.top - gap - chromeSize.height,
      ),
      LingyunPopoverPlacement.after => Offset(
        _clampX(_afterLeft(chromeSize.width), chromeSize.width),
        _clampY(anchor.center.dy - chromeSize.height / 2, chromeSize.height),
      ),
      LingyunPopoverPlacement.before => Offset(
        _clampX(_beforeLeft(chromeSize.width), chromeSize.width),
        _clampY(anchor.center.dy - chromeSize.height / 2, chromeSize.height),
      ),
    };
  }

  double _afterLeft(double width) {
    final gap = LingyunPopoverLayout.anchorGap;
    if (textDirection == TextDirection.rtl) {
      return anchor.left - gap - width;
    }
    return anchor.right + gap;
  }

  double _beforeLeft(double width) {
    final gap = LingyunPopoverLayout.anchorGap;
    if (textDirection == TextDirection.rtl) {
      return anchor.right + gap;
    }
    return anchor.left - gap - width;
  }

  double _clampX(double left, double width) {
    final min = safeArea.left + LingyunPopoverLayout.screenMargin;
    final max = math.max(
      min,
      bounds.width - safeArea.right - LingyunPopoverLayout.screenMargin - width,
    );
    return left.clamp(min, max).toDouble();
  }

  double _clampY(double top, double height) {
    final min = safeArea.top + LingyunPopoverLayout.screenMargin;
    final max = math.max(
      min,
      bounds.height -
          safeArea.bottom -
          LingyunPopoverLayout.screenMargin -
          height,
    );
    return top.clamp(min, max).toDouble();
  }

  /// Distance from the start of the arrow's edge to the arrow center.
  ///
  /// Clamped inside [LiquidGlassRadii.medium] so the tip stays off the
  /// corner. That radius is already 待核验.
  double arrowCenterFor(Size chromeSize) {
    final origin = originFor(chromeSize);
    final vertical =
        arrowEdge == LingyunPopoverArrowEdge.top ||
        arrowEdge == LingyunPopoverArrowEdge.bottom;
    final along = vertical
        ? anchor.center.dx - origin.dx
        : anchor.center.dy - origin.dy;
    final extent = vertical ? chromeSize.width : chromeSize.height;
    if (extent <= 0) return 0;
    final half = LingyunPopoverLayout.arrowBase / 2;
    final inset = math.min(LiquidGlassRadii.medium, extent / 2);
    final lower = math.min(extent / 2, inset + half);
    final upper = math.max(lower, extent - inset - half);
    return along.clamp(lower, upper).toDouble();
  }

  /// Arrow tip in chrome coordinates. The enter / exit scale pivots here.
  Offset tipFor(Size chromeSize) {
    final along = arrowCenterFor(chromeSize);
    return switch (arrowEdge) {
      LingyunPopoverArrowEdge.top => Offset(along, 0),
      LingyunPopoverArrowEdge.bottom => Offset(along, chromeSize.height),
      LingyunPopoverArrowEdge.left => Offset(0, along),
      LingyunPopoverArrowEdge.right => Offset(chromeSize.width, along),
    };
  }

  Alignment alignmentFor(Size chromeSize) {
    if (chromeSize.width <= 0 || chromeSize.height <= 0) {
      return _edgeAlignment(arrowEdge);
    }
    final tip = tipFor(chromeSize);
    final x = ((tip.dx / chromeSize.width) * 2 - 1).clamp(-1.0, 1.0).toDouble();
    final y = ((tip.dy / chromeSize.height) * 2 - 1)
        .clamp(-1.0, 1.0)
        .toDouble();
    return Alignment(x, y);
  }

  static Alignment _edgeAlignment(LingyunPopoverArrowEdge edge) {
    return switch (edge) {
      LingyunPopoverArrowEdge.top => const Alignment(0, -1),
      LingyunPopoverArrowEdge.bottom => const Alignment(0, 1),
      LingyunPopoverArrowEdge.left => const Alignment(-1, 0),
      LingyunPopoverArrowEdge.right => const Alignment(1, 0),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is LingyunPopoverMetrics &&
        other.bounds == bounds &&
        other.safeArea == safeArea &&
        other.anchor == anchor &&
        other.preferredPlacement == preferredPlacement &&
        other.horizontalSizeClass == horizontalSizeClass &&
        other.textDirection == textDirection;
  }

  @override
  int get hashCode => Object.hash(
    bounds,
    safeArea,
    anchor,
    preferredPlacement,
    horizontalSizeClass,
    textDirection,
  );
}

/// One tappable row inside a popover.
///
/// Press uses [LingyunPopoverMotion.pressedScale], the quick duration, and
/// [GlassButtonPalette.pressedVeil]. That is the library's existing flex
/// approximation, not a published WWDC scale. Reduce-motion zeroes the
/// duration; the pressed pose still appears.
class LingyunPopoverAction extends StatefulWidget {
  const LingyunPopoverAction({
    super.key,
    required this.label,
    this.onPressed,
    this.forcePressed = false,
  });

  final String label;

  /// Called on tap. The row does not pop the route by itself.
  final VoidCallback? onPressed;

  /// Pins the pressed pose for a gallery or a test.
  final bool forcePressed;

  bool get enabled => onPressed != null;

  @override
  State<LingyunPopoverAction> createState() => _LingyunPopoverActionState();
}

class _LingyunPopoverActionState extends State<LingyunPopoverAction> {
  bool _pressed = false;

  bool get _showPressed => widget.forcePressed || (widget.enabled && _pressed);

  @override
  Widget build(BuildContext context) {
    final duration = LingyunPopoverMotion.pressDuration(context);
    final curve = LingyunPopoverMotion.pressCurve(context);
    final colors = LingyunTheme.colorsOf(context);
    final veil = LiquidGlassTheme.buttonPaletteOf(context).pressedVeil;
    final scale = _showPressed ? LingyunPopoverMotion.pressedScale : 1.0;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: LingyunPopoverLayout.actionVerticalPadding,
                  horizontal: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.label,
                    style: LingyunTextStyles.body(color: colors.labels.primary),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _showPressed ? 1 : 0,
                    duration: duration,
                    curve: curve,
                    child: ColoredBox(color: veil),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Anchored chrome: arrow plus [GlassSurface] Regular Medium.
///
/// The parent supplies the size and the placement. [showLingyunPopover]
/// does that from the anchor. A gallery can place this widget itself.
///
/// Chrome is `style: LiquidGlassStyle.regularMedium` with no token
/// override and no [MaterialTier]. Regular Medium is a non-binding stand-in
/// for the thicker glass WWDC describes when a control morphs into a
/// larger presentation. It is not Materials Thick and not a measured
/// Sketch Popovers plate. 待核验.
class LingyunPopover extends StatelessWidget {
  const LingyunPopover({
    super.key,
    required this.child,
    this.placement = LingyunPopoverPlacement.below,
    this.textDirection,
    this.arrowCenter,
    this.platterKey,
    this.arrowKey,
  });

  final Widget child;
  final LingyunPopoverPlacement placement;
  final TextDirection? textDirection;

  /// Arrow center along the edge, in logical pixels. Null centers it.
  final double? arrowCenter;

  final Key? platterKey;
  final Key? arrowKey;

  @override
  Widget build(BuildContext context) {
    final direction = textDirection ?? Directionality.of(context);
    final edge = LingyunPopoverMetrics.edgeFor(placement, direction);
    final tokens = LiquidGlassTheme.styleOf(
      context,
      LiquidGlassStyle.regularMedium,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal =
            edge == LingyunPopoverArrowEdge.left ||
            edge == LingyunPopoverArrowEdge.right;
        final incoming = constraints.maxWidth.isFinite
            ? constraints.maxWidth -
                  (horizontal ? LingyunPopoverLayout.arrowLength : 0)
            : LingyunPopoverLayout.maxWidth;
        final maxW = math.min(
          LingyunPopoverLayout.maxWidth,
          math.max(0.0, incoming),
        );
        final minW = math.min(LingyunPopoverLayout.minWidth, maxW);
        final glass = ConstrainedBox(
          constraints: BoxConstraints(minWidth: minW, maxWidth: maxW),
          child: GlassSurface(
            key: platterKey,
            style: LiquidGlassStyle.regularMedium,
            enableHoverHighlight: false,
            padding: const EdgeInsets.all(LingyunPopoverLayout.contentPadding),
            child: child,
          ),
        );
        final vertical =
            edge == LingyunPopoverArrowEdge.top ||
            edge == LingyunPopoverArrowEdge.bottom;
        final arrow = SizedBox(
          key: arrowKey,
          width: vertical
              ? LingyunPopoverLayout.arrowBase
              : LingyunPopoverLayout.arrowLength,
          height: vertical
              ? LingyunPopoverLayout.arrowLength
              : LingyunPopoverLayout.arrowBase,
          child: CustomPaint(
            painter: _ArrowPainter(color: tokens.tintColor, edge: edge),
          ),
        );
        return _placeArrow(edge: edge, glass: glass, arrow: arrow);
      },
    );
  }

  Widget _placeArrow({
    required LingyunPopoverArrowEdge edge,
    required Widget glass,
    required Widget arrow,
  }) {
    final before =
        edge == LingyunPopoverArrowEdge.top ||
        edge == LingyunPopoverArrowEdge.left;
    final vertical =
        edge == LingyunPopoverArrowEdge.top ||
        edge == LingyunPopoverArrowEdge.bottom;
    final pad = arrowCenter == null
        ? null
        : math.max(0.0, arrowCenter! - LingyunPopoverLayout.arrowBase / 2);
    final slot = pad == null
        ? arrow
        : Padding(
            padding: vertical
                ? EdgeInsets.only(left: pad)
                : EdgeInsets.only(top: pad),
            child: arrow,
          );
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: pad == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [if (before) slot, glass, if (!before) slot],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pad == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [if (before) slot, glass, if (!before) slot],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.color, required this.edge});

  final Color color;
  final LingyunPopoverArrowEdge edge;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || color.a <= 0) return;
    final path = Path();
    switch (edge) {
      case LingyunPopoverArrowEdge.top:
        path
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height);
      case LingyunPopoverArrowEdge.bottom:
        path
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width / 2, size.height);
      case LingyunPopoverArrowEdge.left:
        path
          ..moveTo(0, size.height / 2)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height);
      case LingyunPopoverArrowEdge.right:
        path
          ..moveTo(size.width, size.height / 2)
          ..lineTo(0, 0)
          ..lineTo(0, size.height);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.edge != edge;
  }
}

/// Paints something for the popover [BackdropFilter] to sample.
///
/// A modal route does not sample the page under it. Paint the preview in
/// this builder, in the same stack as the platter.
typedef LingyunPopoverBackdropBuilder = Widget Function(
  BuildContext context,
  LingyunPopoverMetrics metrics,
);

/// Presents an anchored popover and returns the value passed to
/// [Navigator.pop].
///
/// [anchorContext] is the source control. Its [RenderBox] is read in
/// overlay coordinates. Pass [horizontalSizeClass] the same way
/// [LingyunPage] does. Compact does not become a sheet.
///
/// Motion, all 待核验 against a published popover spring (there isn't one
/// in this repo):
///
/// * Enter / exit scale from the arrow tip using
///   [LingyunPopoverMotion.duration] / [LingyunPopoverMotion.curve].
///   That is the stand-in for the UIKit morph ("a glass button morphs
///   into the popover") and for lensing materialize. Opacity stays 1.
///   Blur sigma is not animated.
/// * Press on [LingyunPopoverAction] reuses the glass-button flex.
/// * Reduce Motion collapses those durations to zero.
///
/// `cupertino_ui` has no popover route. [CupertinoPopupSurface] is the
/// action-sheet surface and is not used here.
///
/// The host needs a Material [Theme] so [GlassSurface] can resolve
/// Regular Medium. The route installs [LingyunTheme].
Future<T?> showLingyunPopover<T>(
  BuildContext context, {
  required BuildContext anchorContext,
  required WidgetBuilder builder,
  LingyunPopoverPlacement? preferredPlacement,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  String? horizontalSizeClass,
  String? barrierLabel,
  String semanticsLabel = 'Popover',
  LingyunPopoverBackdropBuilder? backdrop,
}) {
  final box = anchorContext.findRenderObject();
  if (box is! RenderBox || !box.hasSize) {
    assert(false, 'anchorContext needs a laid-out RenderBox.');
    return Future<T?>.value();
  }
  final brightness = Theme.of(context).brightness;
  final duration = LingyunPopoverMotion.duration(context);
  final adaptivity = LingyunAdaptivity.maybeOf(context);
  final reduceMotion = LiquidGlassMotion.reduceMotionOf(context);
  final label =
      barrierLabel ??
      Localizations.of<CupertinoLocalizations>(
        context,
        CupertinoLocalizations,
      )?.modalBarrierDismissLabel ??
      DefaultCupertinoLocalizations().modalBarrierDismissLabel;
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    _LingyunPopoverRoute<T>(
      anchorContext: anchorContext,
      builder: builder,
      preferredPlacement: preferredPlacement,
      dismissible: barrierDismissible,
      brightness: brightness,
      motionDuration: duration,
      horizontalSizeClass: horizontalSizeClass,
      barrierLabelText: label,
      semanticsLabel: semanticsLabel,
      backdrop: backdrop,
      reduceMotion: reduceMotion,
      reduceTransparency: adaptivity?.reduceTransparency ?? false,
      highContrast: adaptivity?.highContrast ?? false,
    ),
  );
}

class _LingyunPopoverRoute<T> extends PopupRoute<T> {
  _LingyunPopoverRoute({
    required this.anchorContext,
    required this.builder,
    required this.preferredPlacement,
    required this.dismissible,
    required this.brightness,
    required this.motionDuration,
    required this.horizontalSizeClass,
    required this.barrierLabelText,
    required this.semanticsLabel,
    required this.backdrop,
    required this.reduceMotion,
    required this.reduceTransparency,
    required this.highContrast,
  });

  final BuildContext anchorContext;
  final WidgetBuilder builder;
  final LingyunPopoverPlacement? preferredPlacement;
  final bool dismissible;
  final Brightness brightness;
  final Duration motionDuration;
  final String? horizontalSizeClass;
  final String barrierLabelText;
  final String semanticsLabel;
  final LingyunPopoverBackdropBuilder? backdrop;
  final bool reduceMotion;
  final bool reduceTransparency;
  final bool highContrast;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => barrierLabelText;

  @override
  Duration get transitionDuration => motionDuration;

  @override
  Duration get reverseTransitionDuration => motionDuration;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _withCupertinoLocalizations(
      context,
      LingyunAdaptivity(
        reduceMotion: reduceMotion,
        reduceTransparency: reduceTransparency,
        highContrast: highContrast,
        child: _LingyunPopoverPanel(
          anchorContext: anchorContext,
          builder: builder,
          preferredPlacement: preferredPlacement,
          dismissible: dismissible,
          horizontalSizeClass: horizontalSizeClass,
          semanticsLabel: semanticsLabel,
          barrierLabelText: barrierLabelText,
          backdrop: backdrop,
          brightness: brightness,
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Scale lives on the platter so the pivot can sit on the arrow tip.
    // No fade: Meet Liquid Glass materializes by lensing, not by fading.
    // The lens itself is the Regular Medium surface, not a new sigma.
    return child;
  }
}

Widget _withCupertinoLocalizations(BuildContext context, Widget child) {
  if (Localizations.of<CupertinoLocalizations>(
        context,
        CupertinoLocalizations,
      ) !=
      null) {
    return child;
  }
  final locale = Localizations.maybeLocaleOf(context);
  final resolved =
      locale != null &&
          kCupertinoSupportedLanguages.contains(locale.languageCode)
      ? locale
      : const Locale('en', 'US');
  return Localizations(
    locale: resolved,
    delegates: const <LocalizationsDelegate<dynamic>>[
      DefaultCupertinoLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    child: child,
  );
}

class _LingyunPopoverPanel extends StatefulWidget {
  const _LingyunPopoverPanel({
    required this.anchorContext,
    required this.builder,
    required this.preferredPlacement,
    required this.dismissible,
    required this.horizontalSizeClass,
    required this.semanticsLabel,
    required this.barrierLabelText,
    required this.backdrop,
    required this.brightness,
  });

  final BuildContext anchorContext;
  final WidgetBuilder builder;
  final LingyunPopoverPlacement? preferredPlacement;
  final bool dismissible;
  final String? horizontalSizeClass;
  final String semanticsLabel;
  final String barrierLabelText;
  final LingyunPopoverBackdropBuilder? backdrop;
  final Brightness brightness;

  @override
  State<_LingyunPopoverPanel> createState() => _LingyunPopoverPanelState();
}

class _LingyunPopoverPanelState extends State<_LingyunPopoverPanel> {
  Rect? _anchor;
  double? _arrowCenter;
  Alignment _alignment = const Alignment(0, -1);
  bool _queued = false;
  bool _dismissed = false;

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  Rect? _readAnchor() {
    final anchorContext = widget.anchorContext;
    if (!anchorContext.mounted) return _anchor;
    final box = anchorContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return _anchor;
    final overlay = Navigator.of(context).overlay?.context.findRenderObject();
    if (overlay is! RenderBox || !overlay.hasSize) return _anchor;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    _anchor = topLeft & box.size;
    return _anchor;
  }

  void _queue(Size size, LingyunPopoverMetrics metrics) {
    final center = metrics.arrowCenterFor(size);
    final alignment = metrics.alignmentFor(size);
    final centerSame =
        _arrowCenter != null && (center - _arrowCenter!).abs() < 0.5;
    final alignSame =
        (_alignment.x - alignment.x).abs() < 0.02 &&
        (_alignment.y - alignment.y).abs() < 0.02;
    if (centerSame && alignSame) return;
    if (_queued) return;
    _queued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queued = false;
      if (!mounted) return;
      setState(() {
        _arrowCenter = center;
        _alignment = alignment;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final animation =
        ModalRoute.of(context)?.animation ??
        const AlwaysStoppedAnimation<double>(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final bottom = math.max(media.padding.bottom, media.viewInsets.bottom);
        final anchor = _readAnchor();
        final metrics = LingyunPopoverMetrics(
          bounds: Size(constraints.maxWidth, constraints.maxHeight),
          safeArea: media.padding.copyWith(bottom: bottom),
          anchor: anchor ?? Rect.zero,
          preferredPlacement: widget.preferredPlacement,
          horizontalSizeClass: widget.horizontalSizeClass,
          textDirection: Directionality.of(context),
        );
        final brightness = widget.brightness;
        final colors = LingyunColors.forBrightness(brightness);
        final popover = LingyunPopover(
          placement: metrics.placement,
          textDirection: metrics.textDirection,
          arrowCenter: _arrowCenter,
          platterKey: const Key('lingyun-popover-platter'),
          arrowKey: const Key('lingyun-popover-arrow'),
          child: DefaultTextStyle(
            style: LingyunTextStyles.body(color: colors.labels.primary),
            child: widget.builder(context),
          ),
        );
        return LingyunTheme(
          brightness: brightness,
          child: CupertinoTheme(
            data: LingyunTheme.cupertinoThemeFor(brightness),
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Semantics(
                    label: widget.barrierLabelText,
                    button: widget.dismissible,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.dismissible ? _dismiss : null,
                    ),
                  ),
                ),
                CustomSingleChildLayout(
                  delegate: _PopoverDelegate(
                    metrics: metrics,
                    onLaidOut: (size) => _queue(size, metrics),
                  ),
                  child: _PopoverMotion(
                    animation: animation,
                    alignment: _arrowCenter == null
                        ? LingyunPopoverMetrics._edgeAlignment(
                            metrics.arrowEdge,
                          )
                        : _alignment,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (widget.backdrop != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: widget.backdrop!(context, metrics),
                            ),
                          ),
                        Semantics(
                          namesRoute: true,
                          label: widget.semanticsLabel,
                          explicitChildNodes: true,
                          child: popover,
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
  }
}

class _PopoverMotion extends StatefulWidget {
  const _PopoverMotion({
    required this.animation,
    required this.alignment,
    required this.child,
  });

  final Animation<double> animation;
  final Alignment alignment;
  final Widget child;

  @override
  State<_PopoverMotion> createState() => _PopoverMotionState();
}

class _PopoverMotionState extends State<_PopoverMotion> {
  CurvedAnimation? _curved;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bind();
  }

  @override
  void didUpdateWidget(_PopoverMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bind();
  }

  void _bind() {
    final curve = LingyunPopoverMotion.curve(context);
    final current = _curved;
    if (current == null || current.parent != widget.animation) {
      current?.dispose();
      _curved = CurvedAnimation(
        parent: widget.animation,
        curve: curve,
        reverseCurve: curve,
      );
    } else {
      current.curve = curve;
      current.reverseCurve = curve;
    }
  }

  @override
  void dispose() {
    _curved?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      key: const Key('lingyun-popover-scale'),
      scale: _curved!,
      alignment: widget.alignment,
      filterQuality: FilterQuality.low,
      child: widget.child,
    );
  }
}

class _PopoverDelegate extends SingleChildLayoutDelegate {
  _PopoverDelegate({required this.metrics, required this.onLaidOut});

  final LingyunPopoverMetrics metrics;
  final ValueChanged<Size> onLaidOut;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxW = math.min(
      metrics.maxChromeWidth,
      math.max(0.0, constraints.maxWidth),
    );
    return BoxConstraints(
      maxWidth: maxW,
      maxHeight: math.max(0.0, constraints.maxHeight),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    onLaidOut(childSize);
    return metrics.originFor(childSize);
  }

  @override
  bool shouldRelayout(covariant _PopoverDelegate oldDelegate) {
    return oldDelegate.metrics != metrics;
  }
}
