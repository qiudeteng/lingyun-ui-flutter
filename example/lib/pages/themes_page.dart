import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

class ThemesPage extends StatelessWidget {
  const ThemesPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          'Themes',
          key: const Key('themes-title'),
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Light and dark recipes for both systems. Materials fills and '
          'Liquid Glass styles each have Light / Dark. Same APIs on every platform.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark mode'),
                subtitle: Text(isDark ? 'Dark tokens' : 'Light tokens'),
                value: isDark,
                onChanged: (v) =>
                    onThemeModeChanged(v ? ThemeMode.dark : ThemeMode.light),
              ),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {themeMode},
                onSelectionChanged: (set) => onThemeModeChanged(set.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassSurface(
                material: MaterialTier.thin,
                padding: const EdgeInsets.all(16),
                child: Text(
                  isDark ? 'Dark · Materials Thin' : 'Light · Materials Thin',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassSurface(
                material: MaterialTier.thick,
                padding: const EdgeInsets.all(16),
                child: Text(
                  isDark ? 'Dark · Materials Thick' : 'Light · Materials Thick',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: GlassButton.label(
            label: isDark ? 'Dark · Regular Small' : 'Light · Regular Small',
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
