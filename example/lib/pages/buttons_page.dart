import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Glass buttons. Standalone leaf (`?page=buttons`, also `button`).
///
/// Not the style swatches on [GlassPage]. Default material is Regular Small,
/// not Materials Thick.
class ButtonsPage extends StatelessWidget {
  const ButtonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = LiquidGlassLabels.primaryOf(context);
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          '玻璃按钮',
          key: const Key('buttons-title'),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: label,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '只有这一个组件。外形是胶囊，不是尚未核验的面板圆角。'
          '默认材质是常规小，不是材质厚。控件默认尺寸是小。'
          '尺寸分小、中、大。按住可点的按钮能看到按下；按下样例是钉住的。'
          '按下的罩色是近似，不是套件数值。'
          '清透铺在丰富媒体上。填充的突出玻璃用白字。',
          style: textTheme.bodyMedium?.copyWith(color: label),
        ),
        const SizedBox(height: 20),
        Text(
          '尺寸',
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
              caption: '常规小',
              button: GlassButton.label(
                key: const Key('glass-button-regular-small'),
                label: '小',
                onPressed: _noop,
              ),
            ),
            _Specimen(
              caption: '中',
              button: GlassButton.label(
                key: const Key('glass-button-medium'),
                label: '中',
                size: GlassButtonSize.medium,
                onPressed: _noop,
              ),
            ),
            _Specimen(
              caption: '大',
              button: GlassButton.label(
                key: const Key('glass-button-large'),
                label: '大',
                size: GlassButtonSize.large,
                onPressed: _noop,
              ),
            ),
            _Specimen(
              caption: '符号',
              button: GlassButton.icon(
                key: const Key('glass-button-symbol'),
                icon: Icons.add,
                semanticLabel: '添加',
                onPressed: _noop,
              ),
            ),
            _Specimen(
              caption: '大号符号',
              button: GlassButton.icon(
                key: const Key('glass-button-symbol-large'),
                icon: Icons.add,
                semanticLabel: '添加大号',
                size: GlassButtonSize.large,
                prominence: GlassButtonProminence.prominent,
                onPressed: _noop,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '状态',
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
              label: '默认',
              icon: Icons.auto_awesome,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-pressed'),
              label: '按下',
              forcePressed: true,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-disabled'),
              label: '禁用',
              onPressed: null,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent-pressed'),
              label: '突出按下',
              prominence: GlassButtonProminence.prominent,
              forcePressed: true,
              onPressed: _noop,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '变体',
          key: const Key('glass-button-variants'),
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '常规小（玻璃）、清透、破坏性、突出玻璃（白底加系统蓝）。'
          '禁用的突出玻璃大约保留一半填充透明度。',
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
              label: '破坏性',
              role: GlassButtonRole.destructive,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-destructive-disabled'),
              label: '破坏性关闭',
              role: GlassButtonRole.destructive,
              onPressed: null,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent'),
              label: '突出玻璃',
              prominence: GlassButtonProminence.prominent,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent-destructive'),
              label: '突出破坏性',
              role: GlassButtonRole.destructive,
              prominence: GlassButtonProminence.prominent,
              onPressed: _noop,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent-disabled'),
              label: '突出禁用',
              prominence: GlassButtonProminence.prominent,
              onPressed: null,
            ),
            GlassButton.label(
              key: const Key('glass-button-prominent-large'),
              label: '突出大号',
              size: GlassButtonSize.large,
              prominence: GlassButtonProminence.prominent,
              onPressed: _noop,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '可点',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: label,
          ),
        ),
        const SizedBox(height: 8),
        const _ButtonPlayground(),
        const SizedBox(height: 24),
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
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: label, fontWeight: FontWeight.w600),
        ),
      ],
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
          label: '清透',
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
          label: '点我',
          icon: Icons.touch_app_outlined,
          onPressed: () => setState(() => _taps += 1),
        ),
        GlassButton.label(
          key: const Key('glass-button-live-prominent'),
          label: '继续',
          prominence: GlassButtonProminence.prominent,
          onPressed: () => setState(() => _taps += 1),
        ),
        GlassButton.label(
          key: const Key('glass-button-live-destructive'),
          label: '删除',
          role: GlassButtonRole.destructive,
          onPressed: () => setState(() => _taps += 1),
        ),
        Text(
          _taps == 0 ? '按住可看按下' : '已点 $_taps',
          key: const Key('glass-button-live-count'),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: label, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
