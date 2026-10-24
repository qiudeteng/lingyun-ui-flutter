import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// **B. Liquid Glass** — Clear / Regular S·M·L / Dock / Widget Glass +
/// [GlassButton] (Glass, Clear, Destructive, Glass Prominent, Symbol).
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
          'Dock / Widget Glass. GlassButton default material is Regular '
          'Small (Style Glass), not Materials Thick. The control size '
          'default is Small. Clear sits over rich media. Labels — Liquid '
          'Glass: Light Primary #1A1A1A, Dark Primary #EDEDED. Filled '
          'Glass Prominent uses a white label.',
          style: textTheme.bodyMedium?.copyWith(color: label),
        ),
        const SizedBox(height: 20),
        Text(
          'GlassButton',
          key: const Key('glass-button-heading'),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'One component. Capsule, not the unverified panel radii. '
          'Sizes Small / Medium / Large. Hold a live button to see '
          'Pressed; the Pressed chips are pinned. The press wash is an '
          'approximation, not a kit value.',
          style: textTheme.bodySmall?.copyWith(color: label),
        ),
        const SizedBox(height: 16),
        Text(
          'Sizes',
          key: const Key('glass-button-sizes'),
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _Specimen(
              caption: 'Regular Small',
              button: GlassButton.label(
                key: const Key('glass-button-regular-small'),
                label: 'Small',
                onPressed: _noop,
              ),
            ),
            _Specimen(
              caption: 'Medium',
              button: GlassButton.label(
                key: const Key('glass-button-medium'),
                label: 'Medium',
                size: GlassButtonSize.medium,
                onPressed: _noop,
              ),
            ),
            _Specimen(
              caption: 'Large',
              button: GlassButton.label(
                key: const Key('glass-button-large'),
                label: 'Large',
                size: GlassButtonSize.large,
                onPressed: _noop,
              ),
            ),
            _Specimen(
              caption: 'Symbol',
              button: GlassButton.icon(
                key: const Key('glass-button-symbol'),
                icon: Icons.add,
                semanticLabel: 'Add',
                onPressed: _noop,
              ),
            ),
            _Specimen(
              caption: 'Symbol Large',
              button: GlassButton.icon(
                key: const Key('glass-button-symbol-large'),
                icon: Icons.add,
                semanticLabel: 'Add large',
                size: GlassButtonSize.large,
                prominence: GlassButtonProminence.prominent,
                onPressed: _noop,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'States',
          key: const Key('glass-button-states'),
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassButton.label(
              key: const Key('glass-button-default'),
              label: 'Default',
              icon: Icons.auto_awesome,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-pressed'),
              label: 'Pressed',
              forcePressed: true,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-disabled'),
              label: 'Disabled',
              onPressed: null,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent-pressed'),
              label: 'Prominent Pressed',
              prominence: GlassButtonProminence.prominent,
              forcePressed: true,
              onPressed: _noop,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Variants',
          key: const Key('glass-button-variants'),
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Regular Small (Glass) · Clear · Destructive · Glass Prominent '
          '(White Backing + System Blue). Prominent Disabled keeps the '
          'fill at about 50% opacity.',
          style: textTheme.bodySmall?.copyWith(color: label),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const _ClearOnMedia(),
            GlassButton.label(
              key: const Key('glass-button-destructive'),
              label: 'Destructive',
              role: GlassButtonRole.destructive,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-destructive-disabled'),
              label: 'Destructive Off',
              role: GlassButtonRole.destructive,
              onPressed: null,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent'),
              label: 'Glass Prominent',
              prominence: GlassButtonProminence.prominent,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent-destructive'),
              label: 'Prominent Destructive',
              role: GlassButtonRole.destructive,
              prominence: GlassButtonProminence.prominent,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent-disabled'),
              label: 'Prominent Disabled',
              prominence: GlassButtonProminence.prominent,
              onPressed: null,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent-large'),
              label: 'Prominent Large',
              size: GlassButtonSize.large,
              prominence: GlassButtonProminence.prominent,
              onPressed: _noop,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Live',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 8),
        const _ButtonPlayground(),
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

class _Specimen extends StatelessWidget {
  const _Specimen({required this.caption, required this.button});

  final String caption;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    final label = LiquidGlassLabels.primaryOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          caption,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: label,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Liquid Glass · ${style.kitName}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: label),
          ),
          const SizedBox(height: 12),
          Text(
            style.usage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: label),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

/// Clear over a muted media plate.
///
/// The plate is gallery context so [LiquidGlassStyle.clear] stays
/// readable. It is not a focus ring and not the button rim — Clear keeps
/// the shared ~0.5px hairline and the button capsule.
class _ClearOnMedia extends StatelessWidget {
  const _ClearOnMedia();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7F97AB), Color(0xFFC3B09A), Color(0xFF8EA396)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: GlassButton.label(
          key: const Key('glass-button-clear'),
          label: 'Clear',
          icon: Icons.wb_sunny_outlined,
          style: LiquidGlassStyle.clear,
          onPressed: _noop,
        ),
      ),
    );
  }
}

class _ButtonPlayground extends StatefulWidget {
  const _ButtonPlayground();

  @override
  State<_ButtonPlayground> createState() => _ButtonPlaygroundState();
}

class _ButtonPlaygroundState extends State<_ButtonPlayground> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    final label = LiquidGlassLabels.primaryOf(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GlassButton.label(
          key: const Key('glass-button-live'),
          label: 'Tap me',
          icon: Icons.touch_app_outlined,
          onPressed: () => setState(() => _taps += 1),
        ),
        GlassButton.label(
          key: const Key('glass-button-live-prominent'),
          label: 'Continue',
          prominence: GlassButtonProminence.prominent,
          onPressed: () => setState(() => _taps += 1),
        ),
        GlassButton.label(
          key: const Key('glass-button-live-destructive'),
          label: 'Delete',
          role: GlassButtonRole.destructive,
          onPressed: () => setState(() => _taps += 1),
        ),
        Text(
          _taps == 0 ? 'Hold to see Pressed' : 'Tapped $_taps',
          key: const Key('glass-button-live-count'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: label,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
