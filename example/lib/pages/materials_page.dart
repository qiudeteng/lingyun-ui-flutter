import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Thin / regular / thick glass on the colorful wallpaper.
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
          'Three Liquid Glass tiers. Same API on iPhone, Duo, iPad, and macOS. '
          'Specular wash is top-leading; refraction is the inner rim.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        for (final tier in GlassMaterialTier.values) ...[
          _MaterialCard(tier: tier),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.tier});

  final GlassMaterialTier tier;

  @override
  Widget build(BuildContext context) {
    final tokens = LiquidGlassTheme.tokensOf(context, tier: tier);
    return GlassSurface(
      key: Key('material-${tier.name}'),
      material: tier,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tier.name.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'blur ${tokens.blurSigma.toStringAsFixed(0)}  ·  '
            'sat ${tokens.saturation.toStringAsFixed(2)}  ·  '
            'refraction ${tokens.refractionWidth}px',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(switch (tier) {
            GlassMaterialTier.thin =>
              'Light frost for compact chrome and inline chips.',
            GlassMaterialTier.regular => 'Default cards and panels.',
            GlassMaterialTier.thick =>
              'Elevated sheets, sidebars, and dense desktop chrome.',
          }, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
