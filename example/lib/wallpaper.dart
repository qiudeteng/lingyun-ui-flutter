import 'package:flutter/material.dart';

/// Restrained, system-like wallpaper so glass reads like Apple kit
/// previews — muted gradients, not a neon marketing poster.
class SystemWallpaper extends StatelessWidget {
  const SystemWallpaper({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  Color(0xFF1B1C22),
                  Color(0xFF232833),
                  Color(0xFF1A2230),
                  Color(0xFF16181E),
                ]
              : const [
                  Color(0xFFE7EEF4),
                  Color(0xFFF4F0E8),
                  Color(0xFFD9E3EE),
                  Color(0xFFE8E4DC),
                ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _MutedWashPainter(dark: dark),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MutedWashPainter extends CustomPainter {
  const _MutedWashPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = dark ? const Color(0x332A3344) : const Color(0x33B7C6D6);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.22),
      size.shortestSide * 0.42,
      paint,
    );

    paint.color = dark ? const Color(0x28363A32) : const Color(0x2ED4C8B4);
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.28),
      size.shortestSide * 0.38,
      paint,
    );

    paint.color = dark ? const Color(0x2424303C) : const Color(0x29C5D0C8);
    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.82),
      size.shortestSide * 0.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MutedWashPainter oldDelegate) =>
      oldDelegate.dark != dark;
}
