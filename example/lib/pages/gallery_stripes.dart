import 'package:material_ui/material_ui.dart';

/// Vertical bands. Same colors as the Materials page stripe field, not a token.
class GalleryStripes extends StatelessWidget {
  const GalleryStripes({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _GalleryStripePainter(),
      child: SizedBox.expand(),
    );
  }
}

class _GalleryStripePainter extends CustomPainter {
  const _GalleryStripePainter();

  static const List<Color> bands = [
    Color(0xFF5C5C60),
    Color(0xFF7A7A7E),
    Color(0xFF9A9A9E),
    Color(0xFFB4B4B8),
    Color(0xFFC8C8CC),
    Color(0xFFD8D8DC),
    Color(0xFFE8E8EC),
    Color(0xFFF4F4F6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final band = size.width / bands.length;
    final paint = Paint();
    for (var i = 0; i < bands.length; i++) {
      paint.color = bands[i];
      canvas.drawRect(
        Rect.fromLTWH(i * band, 0, band + 0.5, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GalleryStripePainter oldDelegate) => false;
}
