import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/lingyun_theme.dart';
import '../tokens/liquid_glass_motion.dart';
import 'glass_cupertino_host.dart';

/// Linear bar or circular indicator.
enum GlassProgressKind {
  /// [CupertinoLinearActivityIndicator] when [GlassProgressIndicator.value]
  /// is set. Indeterminate linear is a sliding segment — cupertino_ui has
  /// no indeterminate linear — on a Tertiary track.
  linear,

  /// Determinate is a ring (tertiary track + tinted arc). Indeterminate
  /// is [CupertinoActivityIndicator] — the system activity spinner, not
  /// a short tick and not a linear bar.
  circular,
}

/// Determinate and indeterminate progress.
///
/// Tint defaults to System Blue from [LingyunTheme]. The indicator is
/// not a Materials fill and not Liquid Glass chrome; the track and the
/// spinner sit in the content layer.
///
/// * Linear determinate — [CupertinoLinearActivityIndicator]. The package
///   paints the track with its system fill (no track-color parameter).
/// * Linear indeterminate — Tertiary track (`#BFBFBF` / `#404040`) and a
///   tinted segment. The cycle duration is an implementation approximation,
///   not a kit token. Reduce motion holds a static segment.
/// * Circular determinate — a ring. The track is liquid-glass Tertiary.
///   The arc uses [tint]. [radius] is the ring's outer radius, so the
///   box is `radius * 2` on each side (not an ~18px activity tick).
/// * Circular indeterminate — [CupertinoActivityIndicator], tinted.
///   Reduce motion stops the spin (`animating: false`).
class GlassProgressIndicator extends StatelessWidget {
  const GlassProgressIndicator({
    super.key,
    this.value,
    this.kind = GlassProgressKind.linear,
    this.tint,
    this.height = 4.5,
    this.radius = 10,
    this.semanticLabel,
    this.semanticValue,
  });

  /// Progress from 0 to 1. Null is indeterminate.
  final double? value;

  final GlassProgressKind kind;

  /// Fill / spinner color. Defaults to System Blue.
  final Color? tint;

  /// Linear thickness. Matches [CupertinoLinearActivityIndicator]'s 4.5.
  final double height;

  /// Circular size.
  ///
  /// Determinate: outer radius of the ring. Indeterminate: radius passed
  /// to [CupertinoActivityIndicator] (its default is 10).
  final double radius;

  final String? semanticLabel;

  /// Overrides the spoken value. Determinate defaults to a percent.
  /// Indeterminate defaults to `indeterminate`.
  final String? semanticValue;

  bool get determinate => value != null;

  /// Clamps a determinate value onto 0…1 for the Cupertino indicators.
  static double clampProgress(double value) => value.clamp(0.0, 1.0);

  static Color resolveTint({required Color systemBlue, Color? tint}) {
    return tint ?? systemBlue;
  }

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    final tint = resolveTint(systemBlue: colors.system.blue, tint: this.tint);
    final reduceMotion = LiquidGlassMotion.reduceMotionOf(context);
    final progress = value == null ? null : clampProgress(value!);
    final label = semanticLabel ?? 'Progress';
    final semanticsValue =
        semanticValue ??
        (progress == null ? 'indeterminate' : '${(progress * 100).round()}%');

    final Widget indicator = switch (kind) {
      GlassProgressKind.linear when progress != null =>
        CupertinoLinearActivityIndicator(
          progress: progress,
          height: height,
          color: tint,
        ),
      GlassProgressKind.linear => _IndeterminateLinear(
        tint: tint,
        track: colors.liquidGlassLabels.tertiary,
        height: height,
        reduceMotion: reduceMotion,
      ),
      GlassProgressKind.circular when progress != null => _DeterminateRing(
        progress: progress,
        tint: tint,
        track: colors.liquidGlassLabels.tertiary,
        radius: radius,
      ),
      GlassProgressKind.circular => CupertinoActivityIndicator(
        radius: radius,
        color: tint,
        animating: !reduceMotion,
      ),
    };

    return Semantics(
      label: label,
      value: semanticsValue,
      child: GlassCupertinoHost(child: indicator),
    );
  }
}

class _IndeterminateLinear extends StatefulWidget {
  const _IndeterminateLinear({
    required this.tint,
    required this.track,
    required this.height,
    required this.reduceMotion,
  });

  final Color tint;
  final Color track;
  final double height;
  final bool reduceMotion;

  @override
  State<_IndeterminateLinear> createState() => _IndeterminateLinearState();
}

class _IndeterminateLinearState extends State<_IndeterminateLinear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Sliding cycle. Implementation approximation — not a Design Token.
  static const Duration _cycle = Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycle);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_IndeterminateLinear oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final still =
        widget.reduceMotion ||
        LiquidGlassMotion.reduceMotionOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    if (still) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final still =
              widget.reduceMotion || !TickerMode.valuesOf(context).enabled;
          final t = still ? 0.0 : _controller.value;
          return CustomPaint(
            painter: _IndeterminateLinearPainter(
              tint: widget.tint,
              track: widget.track,
              start: still ? 0.0 : -0.34 + t * 1.34,
              extent: still ? 0.4 : 0.34,
            ),
          );
        },
      ),
    );
  }
}

class _IndeterminateLinearPainter extends CustomPainter {
  const _IndeterminateLinearPainter({
    required this.tint,
    required this.track,
    required this.start,
    required this.extent,
  });

  final Color tint;
  final Color track;
  final double start;
  final double extent;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = track,
    );
    final left = start * size.width;
    final width = extent * size.width;
    final visibleLeft = left.clamp(0.0, size.width);
    final visibleRight = (left + width).clamp(0.0, size.width);
    final visible = visibleRight - visibleLeft;
    if (visible <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(visibleLeft, 0, visible, size.height),
        radius,
      ),
      Paint()..color = tint,
    );
  }

  @override
  bool shouldRepaint(_IndeterminateLinearPainter oldDelegate) {
    return oldDelegate.tint != tint ||
        oldDelegate.track != track ||
        oldDelegate.start != start ||
        oldDelegate.extent != extent;
  }
}

/// Determinate circular progress: a full tertiary track and a tinted arc.
///
/// Not [CupertinoActivityIndicator.partiallyRevealed] — that draws spinner
/// ticks, which collapse to a short dash at the default radius.
class _DeterminateRing extends StatelessWidget {
  const _DeterminateRing({
    required this.progress,
    required this.tint,
    required this.track,
    required this.radius,
  });

  final double progress;
  final Color tint;
  final Color track;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final stroke = (radius * 0.2).clamp(2.5, 4.0);
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          tint: tint,
          track: track,
          strokeWidth: stroke,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.tint,
    required this.track,
    required this.strokeWidth,
  });

  final double progress;
  final Color tint;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    if (rect.width <= 0 || rect.height <= 0) return;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    if (progress <= 0) return;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = progress >= 1 ? StrokeCap.butt : StrokeCap.round
      ..color = tint;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tint != tint ||
        oldDelegate.track != track ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
