import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// **B. Liquid Glass** — Clear / Regular S·M·L / Dock / Widget Glass +
/// the first [GlassButton].
class GlassPage extends StatelessWidget {
  const GlassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = LiquidGlassLabels.primaryOf(context);
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          'Liquid Glass',
          key: const Key('glass-title'),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: label,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'B. Liquid Glass = Clear / Regular Small · Medium · Large / '
          'Dock / Widget Glass. Button default is Regular Small (or Clear '
          'over rich media). Labels — Liquid Glass: Light Primary #1A1A1A, '
          'Dark Primary #EDEDED.',
          style: textTheme.bodyMedium?.copyWith(color: label),
        ),
        const SizedBox(height: 20),
        Text(
          'GlassButton',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Default = Liquid Glass Regular Small. Materials Thick is not '
          'a button recipe.',
          style: textTheme.bodySmall?.copyWith(color: label),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GlassButton.label(
              key: const Key('glass-button-default'),
              label: 'Regular Small',
              icon: Icons.auto_awesome,
              onPressed: () {},
            ),
            GlassButton.label(
              key: const Key('glass-button-clear'),
              label: 'Clear',
              icon: Icons.wb_sunny_outlined,
              style: LiquidGlassStyle.clear,
              onPressed: () {},
            ),
            GlassButton.label(
              key: const Key('glass-button-disabled'),
              label: 'Disabled',
              onPressed: null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Kit styles',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Official names only — blur / saturation stay in code as '
          'implementation approximations, not Design Tokens.',
          style: textTheme.bodySmall?.copyWith(color: label),
        ),
        const SizedBox(height: 12),
        for (final style in LiquidGlassStyle.values) ...[
          _GlassStyleCard(style: style),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _GlassStyleCard extends StatelessWidget {
  const _GlassStyleCard({required this.style});

  final LiquidGlassStyle style;

  @override
  Widget build(BuildContext context) {
    final label = LiquidGlassLabels.primaryOf(context);
    return GlassSurface(
      key: Key('glass-${style.name}'),
      style: style,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style.kitName,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, color: label),
          ),
          const SizedBox(height: 8),
          Text(
            'Liquid Glass · ${style.kitName}',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: label),
          ),
          const SizedBox(height: 12),
          Text(
            style.usage,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: label),
          ),
        ],
      ),
    );
  }
}
