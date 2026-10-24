import 'dart:ui' show ImageFilter, MaskFilter, BlurStyle;

import 'package:cupertino_ui/cupertino_ui.dart';

import '../tokens/control_layer_style.dart';

/// Paints one [ControlLayerStyle].
///
/// Corner radius is the caller’s shape. The layer style does not include
/// one; omit [borderRadius] and the plate stays rectangular.
///
/// Clicked - Shadow’s gaussian radius is blurred with the same
/// radius-to-sigma step Flutter uses for [BoxShadow] (`radius * 0.57735 +
/// 0.5`). Sketch did not publish a sigma. That step is an implementation
/// approximation, not a kit token. Plus Darker is stored on the border and
/// is not applied; the stroke uses the Sketch color with source-over so the
/// ring stays visible. See `docs/CONTROLS.md`.
class ControlLayerView extends StatelessWidget {
  const ControlLayerView({
    super.key,
    required this.style,
    this.width,
    this.height,
    this.borderRadius,
  });

  final ControlLayerStyle style;

  /// Shape width. Null expands to the incoming max width.
  final double? width;

  /// Shape height. Null expands to the incoming max height.
  final double? height;

  /// Caller shape. Not a Controls token.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ControlLayerPainter(style: style, borderRadius: borderRadius),
      child: SizedBox(width: width, height: height),
    );
  }
}

/// Idle body, then Clicked - Shadow, then Clicked - Glow.
///
/// Sketch does not say which clicked layer is on top. Shadow under glow is
/// this painter’s order and is **待核验**. Dark idle is omitted when the
/// catalog has no idle style; pass [clicked] to still draw the rings.
///
/// The stack does not clip. Blur 36 and the outside glow extend past
/// [width] and [height]; the caller leaves room if those must stay visible.
///
/// Dark clicked borders are black. On a black canvas they leave no pixel,
/// so a slider that passes [showRingOnBlack] keeps that same alpha and
/// paints it white. The disk stays empty. That is not an idle fill.
class ControlKnobStack extends StatelessWidget {
  const ControlKnobStack({
    super.key,
    required this.brightness,
    required this.width,
    required this.height,
    this.clicked = false,
    this.borderRadius,
    this.showRingOnBlack = false,
  });

  final Brightness brightness;
  final double width;
  final double height;
  final bool clicked;
  final BorderRadius? borderRadius;

  /// Dark pressed only. See the class dartdoc. Ignored when an idle knob
  /// exists, and ignored while [clicked] is false.
  final bool showRingOnBlack;

  @override
  Widget build(BuildContext context) {
    final catalog = ControlLayerCatalog.forBrightness(brightness);
    final layers = <ControlLayerStyle>[
      if (catalog.knob(ControlKnobLayer.idle) case final idle?) idle,
      if (clicked) ...[catalog.knobClickedShadow, catalog.knobClickedGlow],
    ];
    final plate = SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        // Idle blur is 36. A hard clip at the shape leaves only the 3pt
        // offset, which reads as no shadow.
        clipBehavior: Clip.none,
        children: [
          for (final style in layers)
            ControlLayerView(style: style, borderRadius: borderRadius),
        ],
      ),
    );
    if (showRingOnBlack && clicked && catalog.knobIdle == null) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
        child: plate,
      );
    }
    return plate;
  }
}

class _ControlLayerPainter extends CustomPainter {
  _ControlLayerPainter({required this.style, required this.borderRadius});

  final ControlLayerStyle style;
  final BorderRadius? borderRadius;

  /// Flutter [BoxShadow.convertRadiusToSigma]. Not a Sketch sigma.
  static double radiusToSigma(double radius) {
    return radius > 0 ? radius * 0.57735 + 0.5 : 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final shape = (borderRadius ?? BorderRadius.zero).toRRect(
      Offset.zero & size,
    );
    for (final shadow in style.shadows) {
      final paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          radiusToSigma(shadow.blurRadius),
        );
      canvas.drawRRect(
        shape.shift(shadow.offset).inflate(shadow.spread),
        paint,
      );
    }

    void drawBody(Canvas target) {
      for (final fill in style.fills) {
        target.drawRRect(shape, Paint()..color = fill);
      }
      for (final border in style.borders) {
        final delta = border.position == ControlBorderPosition.inside
            ? border.thickness / 2
            : -border.thickness / 2;
        target.drawRRect(
          shape.deflate(delta),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = border.thickness
            ..color = border.color,
        );
      }
    }

    final radius = style.gaussianRadius;
    if (radius == null || radius <= 0) {
      drawBody(canvas);
      return;
    }
    final sigma = radiusToSigma(radius);
    canvas.saveLayer(
      shape.outerRect.inflate(radius * 3),
      Paint()..imageFilter = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    );
    drawBody(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ControlLayerPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.borderRadius != borderRadius;
  }
}
