import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// 确定与不确定进度，线性与圆形。可见文案为简体中文。
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    final primary = colors.liquidGlassLabels.primary;
    final red = colors.system.red;
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          '进度指示器',
          key: const Key('progress-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: primary),
        ),
        const SizedBox(height: 8),
        Text(
          '默认着色为系统蓝。确定进度的横条使用系统线性指示器，轨道由组件绘制，不是材质填充。'
          '不确定进度的横条使用三级色轨道。圆形使用系统活动指示器。'
          '指示器本身不是液态玻璃，也不是厚材质。',
          style: LingyunTextStyles.body(color: primary),
        ),
        const SizedBox(height: 20),
        Text('线性', style: LingyunTextStyles.headline(color: primary)),
        const SizedBox(height: 12),
        _linear(primary, caption: '0%', value: 0),
        const SizedBox(height: 12),
        _linear(
          primary,
          caption: '35%',
          value: 0.35,
          indicatorKey: const Key('progress-linear'),
        ),
        const SizedBox(height: 12),
        _linear(primary, caption: '100%', value: 1),
        const SizedBox(height: 12),
        _caption(primary, '不确定'),
        const SizedBox(height: 6),
        const GlassProgressIndicator(
          key: Key('progress-linear-indeterminate'),
          semanticLabel: '进度',
          semanticValue: '不确定',
        ),
        const SizedBox(height: 22),
        Text('圆形', style: LingyunTextStyles.headline(color: primary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 28,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _circular(
              primary,
              caption: '35%',
              child: const GlassProgressIndicator(
                key: Key('progress-circular'),
                kind: GlassProgressKind.circular,
                value: 0.35,
                radius: 16,
                semanticLabel: '进度',
                semanticValue: '35%',
              ),
            ),
            _circular(
              primary,
              caption: '不确定',
              child: const GlassProgressIndicator(
                key: Key('progress-circular-indeterminate'),
                kind: GlassProgressKind.circular,
                radius: 16,
                semanticLabel: '进度',
                semanticValue: '不确定',
              ),
            ),
            _circular(
              primary,
              caption: '着色',
              child: GlassProgressIndicator(
                key: const Key('progress-tint'),
                value: 0.6,
                tint: red,
                semanticLabel: '进度',
                semanticValue: '60%',
              ),
            ),
            _circular(
              primary,
              caption: '圆形着色',
              child: GlassProgressIndicator(
                kind: GlassProgressKind.circular,
                value: 0.6,
                radius: 16,
                tint: red,
                semanticLabel: '进度',
                semanticValue: '60%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _linear(
    Color primary, {
    required String caption,
    required double value,
    Key? indicatorKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _caption(primary, caption),
        const SizedBox(height: 6),
        GlassProgressIndicator(
          key: indicatorKey,
          value: value,
          semanticLabel: '进度',
          semanticValue: caption,
        ),
      ],
    );
  }

  Widget _caption(Color color, String text) {
    return Text(
      text,
      style: LingyunTextStyles.footnote(emphasized: true, color: color),
    );
  }

  Widget _circular(
    Color primary, {
    required String caption,
    required Widget child,
  }) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _caption(primary, caption),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
