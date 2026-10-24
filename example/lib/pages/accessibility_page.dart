import 'package:material_ui/material_ui.dart';
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
          '辅助功能',
          key: const Key('a11y-title'),
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          '降低透明度或打开高对比时，玻璃改为不透明兜底。'
          '减弱动态会把 LiquidGlassMotion 的时长收成零'
          '（也会跟随 MediaQuery.disableAnimations）。',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('降低透明度'),
                subtitle: const Text('玻璃改为不透明兜底'),
                value: reduceTransparency,
                onChanged: onReduceTransparency,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('减弱动态'),
                subtitle: const Text('时长为零，曲线改为线性'),
                value: reduceMotion,
                onChanged: onReduceMotion,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('高对比'),
                subtitle: const Text('与媒体查询相同的不透明兜底'),
                value: highContrast,
                onChanged: onHighContrast,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassSurface(
          material: MaterialTier.regular,
          padding: const EdgeInsets.all(20),
          child: Text(
            reduceTransparency || highContrast
                ? '不透明兜底已生效。'
                : '正在使用磨砂玻璃。在桌面上悬停可加强高光。',
            style: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
