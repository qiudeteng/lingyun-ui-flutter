import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// [GlassTextField] 的默认、聚焦、错误、禁用、密文与实时编辑。可见文案为简体中文。
class TextFieldsPage extends StatefulWidget {
  const TextFieldsPage({super.key});

  @override
  State<TextFieldsPage> createState() => _TextFieldsPageState();
}

class _TextFieldsPageState extends State<TextFieldsPage> {
  late final TextEditingController _focused;
  late final TextEditingController _error;
  late final TextEditingController _disabled;
  late final TextEditingController _secure;
  late final TextEditingController _live;
  int _edits = 0;

  @override
  void initState() {
    super.initState();
    _focused = TextEditingController(text: '凌云');
    _error = TextEditingController(text: '无效邮箱');
    _disabled = TextEditingController(text: '凌云');
    _secure = TextEditingController(text: '示例密码');
    _live = TextEditingController();
  }

  @override
  void dispose() {
    _focused.dispose();
    _error.dispose();
    _disabled.dispose();
    _secure.dispose();
    _live.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = LingyunTheme.colorsOf(context).liquidGlassLabels.primary;
    final fields = <Widget>[
      const GlassTextField(
        key: Key('field-default'),
        label: '姓名',
        placeholder: '必填',
        helperText: '显示在个人资料中',
      ),
      GlassTextField(
        key: const Key('field-focused'),
        controller: _focused,
        label: '显示名称',
        forceFocused: true,
        clearButtonMode: OverlayVisibilityMode.always,
      ),
      GlassTextField(
        key: const Key('field-error'),
        controller: _error,
        label: '电子邮件',
        placeholder: '请输入邮箱',
        errorText: '请输入有效的电子邮件',
        keyboardType: TextInputType.emailAddress,
        clearButtonMode: OverlayVisibilityMode.always,
      ),
      GlassTextField(
        key: const Key('field-disabled'),
        controller: _disabled,
        label: '用户名',
        enabled: false,
      ),
      GlassTextField(
        key: const Key('field-secure'),
        controller: _secure,
        label: '密码',
        placeholder: '必填',
        obscureText: true,
        obscureToggle: true,
        showSecretLabel: '显示密码',
        hideSecretLabel: '隐藏密码',
        helperText: '至少 8 个字符',
      ),
      GlassTextField(
        key: const Key('field-live'),
        controller: _live,
        label: '实时',
        placeholder: '输入即可编辑',
        helperText: '已编辑 $_edits 次',
        onChanged: (_) => setState(() => _edits += 1),
      ),
    ];

    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          '文本框',
          key: const Key('fields-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: primary),
        ),
        const SizedBox(height: 8),
        Text(
          '输入区域放在小尺寸液态玻璃托盘中，并去掉系统默认的白底或黑底。'
          '上方标签为主色，占位符和辅助说明为三级色，错误提示为系统红。'
          '聚焦与错误使用约 0.5 像素发丝描边。托盘不是厚材质。',
          style: LingyunTextStyles.body(color: primary),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    fields[i],
                  ],
                ],
              );
            }
            return Wrap(
              spacing: 28,
              runSpacing: 16,
              children: [
                for (final field in fields)
                  SizedBox(
                    width: (constraints.maxWidth - 28) / 2,
                    child: field,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
