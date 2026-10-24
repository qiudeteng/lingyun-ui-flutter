import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// **A. Materials** — 超薄 / 薄 / 常规 / 厚。
///
/// 不是液态玻璃。页面不展示模糊或饱和度数字（那些是实现近似，不是官方设计令牌）。
class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          '材质',
          key: const Key('materials-title'),
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          '材质是内容层的半透明填充：超薄、薄、常规、厚，各有浅色与深色。'
          '它们不是液态玻璃。厚只用于表单和侧栏，不是按钮的默认材质，'
          '也不是标签栏（标签栏是液态玻璃 Dock）。每块板后面的条纹是材质页样张，'
          '不是设计令牌。霜化与景深是设计档位，不是模糊数值。',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        for (final tier in MaterialTier.values) ...[
          _MaterialCard(tier: tier),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        Text(
          '圆角',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '18 / 26 / 34 在对照官方 Sketch 套件量完之前标为待核验。与材质档位无关。',
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
    final label = LiquidGlassLabels.primaryOf(context);
    final text = Theme.of(context).textTheme;
    final swatch = _StripeField(
      child: GlassSurface(
        key: Key('material-${tier.name}'),
        material: tier,
        radiusScale: GlassRadiusScale.large,
        child: const SizedBox.expand(),
      ),
    );
    final caption = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tierTitle(tier),
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '材质 · ${_tierTitle(tier)}',
          style: text.bodySmall?.copyWith(color: label),
        ),
        const SizedBox(height: 6),
        Text(_tierUsage(tier), style: text.bodyMedium?.copyWith(color: label)),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [swatch, const SizedBox(height: 8), caption],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 3, child: swatch),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: caption),
          ],
        );
      },
    );
  }
}

String _tierTitle(MaterialTier tier) => switch (tier) {
  MaterialTier.ultrathin => '超薄',
  MaterialTier.thin => '薄',
  MaterialTier.regular => '常规',
  MaterialTier.thick => '厚',
};

String _tierUsage(MaterialTier tier) => switch (tier) {
  MaterialTier.ultrathin => '最轻的内容填充，条纹和壁纸仍能透出。',
  MaterialTier.thin => '轻霜，用于紧凑内容和行内分组。',
  MaterialTier.regular => '默认的内容层分隔。',
  MaterialTier.thick => '只用于表单和侧栏外壳，不是按钮默认。',
};

/// 竖向灰条，作用与 Figma 材质页的条纹底相同：
/// 在平的设计画布上能看出霜化厚薄。不是设计令牌。
class _StripeField extends StatelessWidget {
  const _StripeField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _MaterialStripePainter()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MaterialStripePainter extends CustomPainter {
  const _MaterialStripePainter();

  static const List<Color> _bands = [
    Color(0xFF5C5C60),
    Color(0xFF7A7A7E),
    Color(0xFF9A9A9E),
    Color(0xFFB4B4B8),
    Color(0xFFC8C8CC),
    Color(0xFFD8D8DC),
    Color(0xFFE8E8EC),
    Color(0xFFF4F4F6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final band = size.width / _bands.length;
    for (var i = 0; i < _bands.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * band, 0, band + 0.5, size.height),
        Paint()..color = _bands[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MaterialStripePainter oldDelegate) => false;
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.scale});

  final GlassRadiusScale scale;

  @override
  Widget build(BuildContext context) {
    final r = LiquidGlassRadii.value(scale);
    final name = switch (scale) {
      GlassRadiusScale.small => '小',
      GlassRadiusScale.medium => '中',
      GlassRadiusScale.large => '大',
    };
    return GlassSurface(
      key: Key('radius-${scale.name}'),
      material: MaterialTier.regular,
      radiusScale: scale,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        '$name  ${r.toStringAsFixed(0)}  待核验',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
