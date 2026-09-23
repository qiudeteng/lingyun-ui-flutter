import 'package:flutter/material.dart';
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
          'Thick is Sheet / Sidebar chrome — not the default button.',
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
    final tokens = LiquidGlassTheme.materialOf(context, tier);
    final fill = Color.alphaBlend(tokens.tintColor, tokens.opaqueFallbackColor);
    final color = LiquidGlassLabels.contrastingOn(fill);
    return GlassSurface(
      key: Key('material-${tier.name}'),
      material: tier,
      radiusScale: GlassRadiusScale.large,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tier.kitName.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Materials · ${tier.kitName}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
          const SizedBox(height: 12),
          Text(
            tier.usage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
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
