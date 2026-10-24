import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

import 'colors_page.dart';
import 'text_styles_page.dart';

/// Which specimen the Themes gallery is showing.
enum ThemesPanel { colors, text, samples }

/// Main-gallery Themes page.
///
/// The color swatches and Large text specimens are the default content.
/// Light / dark uses the gallery [ThemeMode]. The sample strip keeps the
/// existing Materials and Glass widgets; only its labels change.
class ThemesPage extends StatefulWidget {
  const ThemesPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.initialPanel = ThemesPanel.colors,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemesPanel initialPanel;

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  late ThemesPanel _panel = widget.initialPanel;

  @override
  void didUpdateWidget(ThemesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPanel != widget.initialPanel) {
      _panel = widget.initialPanel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final margin = LingyunLayout.layoutMarginOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: margin.copyWith(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '主题',
                key: const Key('themes-title'),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '这里看颜色色板和文本字阶。浅色和深色用下面的切换。样条只对照已有材质，不改配方。',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemesPanel>(
                segments: const [
                  ButtonSegment(value: ThemesPanel.colors, label: Text('颜色')),
                  ButtonSegment(value: ThemesPanel.text, label: Text('文本')),
                  ButtonSegment(value: ThemesPanel.samples, label: Text('样条')),
                ],
                selected: {_panel},
                onSelectionChanged: (set) => setState(() => _panel = set.first),
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                key: const Key('themes-brightness'),
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
                  ButtonSegment(value: ThemeMode.system, label: Text('系统')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
                ],
                selected: {widget.themeMode},
                onSelectionChanged: (set) =>
                    widget.onThemeModeChanged(set.first),
              ),
            ],
          ),
        ),
        Expanded(
          child: LingyunTheme(
            brightness: isDark ? Brightness.dark : Brightness.light,
            child: switch (_panel) {
              ThemesPanel.colors => const ColorsPage(),
              ThemesPanel.text => const TextStylesPage(),
              ThemesPanel.samples => _SampleStrip(isDark: isDark),
            },
          ),
        ),
      ],
    );
  }
}

class _SampleStrip extends StatelessWidget {
  const _SampleStrip({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tone = isDark ? '深色' : '浅色';
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Row(
          children: [
            Expanded(
              child: GlassSurface(
                material: MaterialTier.thin,
                padding: const EdgeInsets.all(16),
                child: Text('$tone · 薄材质', style: textTheme.titleMedium),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassSurface(
                material: MaterialTier.thick,
                padding: const EdgeInsets.all(16),
                child: Text('$tone · 厚材质', style: textTheme.titleMedium),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: GlassButton.label(label: '$tone · 常规小号', onPressed: () {}),
        ),
      ],
    );
  }
}
