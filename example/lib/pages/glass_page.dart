import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// **B. Liquid Glass** style swatches.
///
/// Clear / Regular S·M·L / Dock / Widget Glass. Glass buttons are the
/// separate `?page=buttons` leaf, not this page.
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
          '液态玻璃',
          key: const Key('glass-title'),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: label,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '液态玻璃包括清透、常规小、常规中、常规大、程序坞和小组件玻璃。'
          '这里只写样式名称。模糊和饱和度留在代码里，是实现近似，不是设计令牌。'
          '液态玻璃标签：浅色主色 #1A1A1A，深色主色 #EDEDED。'
          '玻璃按钮在基础工作台的「玻璃按钮」里，不在这一页。',
          style: textTheme.bodyMedium?.copyWith(color: label),
        ),
        const SizedBox(height: 20),
        Text(
          '套件样式',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
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
            _glassName(style),
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, color: label),
          ),
          const SizedBox(height: 8),
          Text(
            '液态玻璃 · ${_glassName(style)}',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: label),
          ),
          const SizedBox(height: 12),
          Text(
            _glassUsage(style),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: label),
          ),
        ],
      ),
    );
  }
}

/// 画廊展示名。库里的 [LiquidGlassStyleKit.kitName] 仍是英文套件名。
String _glassName(LiquidGlassStyle style) => switch (style) {
  LiquidGlassStyle.clear => '清透',
  LiquidGlassStyle.regularSmall => '常规小',
  LiquidGlassStyle.regularMedium => '常规中',
  LiquidGlassStyle.regularLarge => '常规大',
  LiquidGlassStyle.dock => '程序坞',
  LiquidGlassStyle.widgetGlass => '小组件玻璃',
};

String _glassUsage(LiquidGlassStyle style) => switch (style) {
  LiquidGlassStyle.clear => '铺在丰富媒体上。壁纸需要保持鲜明时，可作按钮备选。',
  LiquidGlassStyle.regularSmall => '默认按钮和紧凑控件玻璃。',
  LiquidGlassStyle.regularMedium => '嵌套玻璃面板和成组控件。',
  LiquidGlassStyle.regularLarge => '大块玻璃面板，不是材质常规。',
  LiquidGlassStyle.dock => '程序坞和浮动条饰条。',
  LiquidGlassStyle.widgetGlass => '主屏幕式的小组件磁贴。',
};
