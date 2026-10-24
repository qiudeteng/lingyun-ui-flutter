import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// **A. Materials** — Ultrathin / Thin / Regular / Thick.
///
/// Not Liquid Glass styles. No raw blur / saturation numbers (those are
/// implementation approximations, not official Design Tokens).
class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          'Materials',
          key: const Key('materials-title'),
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'A. Materials = translucent fills: Ultrathin / Thin / Regular / '
          'Thick × Light / Dark. These are not Liquid Glass styles. '
          'Thick is Sheet / Sidebar chrome — not the default button, and '
          'not Tab Bar chrome (that is Liquid Glass Dock). The stripes '
          'behind each plate are the specimen field from the Figma '
          'Materials page, not a token. Frost / Depth on that page are '
          'design tiers, not a blur amount.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        for (final tier in MaterialTier.values) ...[
          _MaterialCard(tier: tier),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        Text(
          'Radius scale',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '18 / 26 / 34 are 待核验 (unverified vs Sketch) until measured in '
          'the official Sketch UI Kit. Independent of Materials tiers.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final scale in GlassRadiusScale.values)
              _RadiusChip(scale: scale),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.tier});

  final MaterialTier tier;

  @override
  Widget build(BuildContext context) {
    final label = LiquidGlassLabels.primaryOf(context);
    final text = Theme.of(context).textTheme;
    final swatch = _StripeField(
      child: GlassSurface(
        key: Key('material-${tier.name}'),
        material: tier,
        radiusScale: GlassRadiusScale.large,
        child: const SizedBox.expand(),
      ),
    );
    final caption = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tier.kitName.toUpperCase(),
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Materials · ${tier.kitName}',
          style: text.bodySmall?.copyWith(color: label),
        ),
        const SizedBox(height: 6),
        Text(tier.usage, style: text.bodyMedium?.copyWith(color: label)),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [swatch, const SizedBox(height: 8), caption],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 3, child: swatch),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: caption),
          ],
        );
      },
    );
  }
}

/// Vertical gray bands, same job as the Figma Materials stripe field:
/// a known backdrop so frost level is visible on the flat design canvas.
/// Not a Design Token.
class _StripeField extends StatelessWidget {
  const _StripeField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _MaterialStripePainter()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MaterialStripePainter extends CustomPainter {
  const _MaterialStripePainter();

  static const List<Color> _bands = [
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
    final band = size.width / _bands.length;
    for (var i = 0; i < _bands.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * band, 0, band + 0.5, size.height),
        Paint()..color = _bands[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MaterialStripePainter oldDelegate) => false;
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.scale});

  final GlassRadiusScale scale;

  @override
  Widget build(BuildContext context) {
    final r = LiquidGlassRadii.value(scale);
    return GlassSurface(
      key: Key('radius-${scale.name}'),
      material: MaterialTier.regular,
      radiusScale: scale,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        '${scale.name}  ${r.toStringAsFixed(0)}  待核验',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
