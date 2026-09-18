import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

class AccessibilityPage extends StatelessWidget {
  const AccessibilityPage({
    super.key,
    required this.reduceTransparency,
    required this.reduceMotion,
    required this.highContrast,
    required this.onReduceTransparency,
    required this.onReduceMotion,
    required this.onHighContrast,
  });

  final bool reduceTransparency;
  final bool reduceMotion;
  final bool highContrast;
  final ValueChanged<bool> onReduceTransparency;
  final ValueChanged<bool> onReduceMotion;
  final ValueChanged<bool> onHighContrast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          'Accessibility',
          key: const Key('a11y-title'),
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Reduce Transparency and high contrast switch glass to an opaque '
          'fallback. Reduce Motion zeroes LiquidGlassMotion durations '
          '(also honors MediaQuery.disableAnimations).',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reduce transparency'),
                subtitle: const Text('Opaque glass fallback'),
                value: reduceTransparency,
                onChanged: onReduceTransparency,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reduce motion'),
                subtitle: const Text('Duration.zero + linear curves'),
                value: reduceMotion,
                onChanged: onReduceMotion,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('High contrast'),
                subtitle: const Text('Same opaque fallback as MediaQuery'),
                value: highContrast,
                onChanged: onHighContrast,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassSurface(
          material: GlassMaterialTier.regular,
          padding: const EdgeInsets.all(20),
          child: Text(
            reduceTransparency || highContrast
                ? 'Opaque fallback is active.'
                : 'Frosted glass is active. Hover on desktop to lift specular.',
            style: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
