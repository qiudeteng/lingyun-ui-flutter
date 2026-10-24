import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Text styles gallery. Large content size only.
class TextStylesPage extends StatelessWidget {
  const TextStylesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.of(context).colors;
    final label = colors.labels.primary;
    final secondary = colors.labels.secondary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      children: [
        Text(
          '文本样式',
          key: const Key('text-styles-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: label),
        ),
        const SizedBox(height: 8),
        Text(
          '这里是大号内容尺寸的文本样式。系统字体没有打进安装包。导出的字距是 0。'
          '除大号以外的动态字号，以及设计文件里的文本页，仍待核验。'
          '标签栏的 10 点半粗说明文字不在本批。',
          style: LingyunTextStyles.body(color: label),
        ),
        const SizedBox(height: 20),
        for (final role in LingyunTextRole.values) ...[
          _RoleRow(role: role, label: label, secondary: secondary),
          const SizedBox(height: 16),
        ],
        Text('正文行距', style: LingyunTextStyles.headline(color: label)),
        const SizedBox(height: 8),
        for (final leading in LingyunLeading.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '正文 ${_leadingName(leading)}  '
              '${LingyunTextStyles.metrics[LingyunTextRole.body]!.heightFor(leading).toStringAsFixed(0)}',
              style: LingyunTextStyles.body(leading: leading, color: label),
            ),
          ),
      ],
    );
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.role,
    required this.label,
    required this.secondary,
  });

  final LingyunTextRole role;
  final Color label;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    final metrics = LingyunTextStyles.metrics[role]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_title(role)}  ${metrics.fontSize.toStringAsFixed(0)} / '
          '${metrics.lineHeight.toStringAsFixed(0)}  '
          '字重 ${metrics.weight.value} → ${metrics.emphasizedWeight.value}',
          key: Key('text-role-${role.name}'),
          style: LingyunTextStyles.caption1(emphasized: true, color: secondary),
        ),
        const SizedBox(height: 4),
        Text('凌云界面', style: LingyunTextStyles.style(role, color: label)),
        Text(
          '凌云界面',
          style: LingyunTextStyles.style(role, emphasized: true, color: label),
        ),
      ],
    );
  }
}

String _title(LingyunTextRole role) {
  return switch (role) {
    LingyunTextRole.largeTitle => '大标题',
    LingyunTextRole.title1 => '标题 1',
    LingyunTextRole.title2 => '标题 2',
    LingyunTextRole.title3 => '标题 3',
    LingyunTextRole.headline => '头条',
    LingyunTextRole.body => '正文',
    LingyunTextRole.callout => '标注',
    LingyunTextRole.subheadline => '副标题',
    LingyunTextRole.footnote => '脚注',
    LingyunTextRole.caption1 => '说明文字 1',
    LingyunTextRole.caption2 => '说明文字 2',
  };
}

String _leadingName(LingyunLeading leading) {
  return switch (leading) {
    LingyunLeading.standard => '标准',
    LingyunLeading.loose => '宽松',
    LingyunLeading.tight => '紧凑',
  };
}
