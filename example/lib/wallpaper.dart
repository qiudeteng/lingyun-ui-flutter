import 'package:flutter/material.dart';

/// Vibrant multi-stop wallpaper so glass blur / tint / refraction reads clearly.
class ColorfulWallpaper extends StatelessWidget {
  const ColorfulWallpaper({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B9D),
            Color(0xFFC44DFF),
            Color(0xFF5B8DEF),
            Color(0xFF2EE6A6),
            Color(0xFFFFD56B),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: CustomPaint(painter: _BlobPainter(), child: SizedBox.expand()),
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0x66FF8A65);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      size.shortestSide * 0.35,
      paint,
    );

    paint.color = const Color(0x667C4DFF);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.25),
      size.shortestSide * 0.4,
      paint,
    );

    paint.color = const Color(0x6640C4FF);
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.75),
      size.shortestSide * 0.45,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
