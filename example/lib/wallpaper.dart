import 'package:flutter/material.dart';

/// Restrained, system-like wallpaper so glass reads like Apple kit
/// previews — muted photographic washes, not neon orbs.
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
                  Color(0xFF1A2330),
                  Color(0xFF2A3038),
                  Color(0xFF243044),
                  Color(0xFF1C2228),
                ]
              : const [
                  Color(0xFFB9C9D8),
                  Color(0xFFE4D6C4),
                  Color(0xFFC5D0C4),
                  Color(0xFFD2C8BE),
                ],
          stops: const [0.0, 0.32, 0.68, 1.0],
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

    paint.color = dark ? const Color(0x59344A66) : const Color(0x668FA8C0);
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.2),
      size.shortestSide * 0.48,
      paint,
    );

    // Sit behind the material cards so frost / tint can read.
    paint.color = dark ? const Color(0x66405670) : const Color(0x7396B0C6);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.36),
      size.shortestSide * 0.5,
      paint,
    );

    paint.color = dark ? const Color(0x4D4A4034) : const Color(0x5CC4B49A);
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.26),
      size.shortestSide * 0.44,
      paint,
    );

    paint.color = dark ? const Color(0x40384A40) : const Color(0x52A8B8A8);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.86),
      size.shortestSide * 0.56,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MutedWashPainter oldDelegate) =>
      oldDelegate.dark != dark;
}
