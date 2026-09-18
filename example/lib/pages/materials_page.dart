import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Thin / regular / thick glass plus Large / Medium / Small radius.
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
          'Three Liquid Glass tiers on a muted system wallpaper. '
          'Same API on iPhone, Duo, iPad, and macOS. '
          'Sketch-adjacent labels (Clear / Regular Large / Widget Glass) '
          'are comments only — not an official API.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        for (final tier in GlassMaterialTier.values) ...[
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
          'Large / Medium / Small corners (Regular Large measures 34pt in '
          'the iOS 27 kit). Independent of thin / regular / thick.',
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

  final GlassMaterialTier tier;

  @override
  Widget build(BuildContext context) {
    final tokens = LiquidGlassTheme.tokensOf(context, tier: tier);
    final sketch = switch (tier) {
      GlassMaterialTier.thin => 'Clear / Regular Small',
      GlassMaterialTier.regular => 'Regular Large',
      GlassMaterialTier.thick => 'Widget Glass / chrome',
    };
    return GlassSurface(
      key: Key('material-${tier.name}'),
      material: tier,
      radiusScale: GlassRadiusScale.large,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tier.name.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            'blur ${tokens.blurSigma.toStringAsFixed(0)}  ·  '
            'sat ${tokens.saturation.toStringAsFixed(2)}  ·  '
            'rim ${tokens.refractionWidth}px  ·  '
            'Sketch-adjacent: $sketch',
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

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.scale});

  final GlassRadiusScale scale;

  @override
  Widget build(BuildContext context) {
    final r = LiquidGlassRadii.value(scale);
    return GlassSurface(
      key: Key('radius-${scale.name}'),
      material: GlassMaterialTier.regular,
      radiusScale: scale,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        '${scale.name}  ${r.toStringAsFixed(0)}',
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
