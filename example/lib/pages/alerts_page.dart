import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Sketch **Alerts** gallery.
///
/// Each plate is a `cupertino_ui` [LingyunAlertDialog] on the system barrier
/// color. Live buttons call [showLingyunAlert]. Nothing here is Liquid Glass.
/// Page chrome uses [LingyunTextStyles] (ambient face, not a bundled SF Pro).
class AlertsPage extends StatefulWidget {
  /// [brightness] follows the gallery light / dark toggle.
  const AlertsPage({
    super.key,
    this.brightness = Brightness.light,
    this.onBrightnessChanged,
  });

  /// Cupertino theme brightness for the system dialogs.
  final Brightness brightness;

  /// Asks the gallery to switch 浅色 / 深色. Null in the screenshot host.
  final ValueChanged<Brightness>? onBrightnessChanged;

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String _result = '尚未弹出';

  Future<void> _open({
    required String? title,
    required String? message,
    required List<LingyunAlertAction> actions,
  }) async {
    final index = await showLingyunAlert(
      context,
      title: title,
      message: message,
      actions: actions,
    );
    if (!mounted) return;
    setState(() {
      _result = index == null ? '已关闭' : actions[index].label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US');
    return LingyunTheme(
      brightness: widget.brightness,
      child: CupertinoTheme(
        data: LingyunTheme.cupertinoThemeFor(widget.brightness),
        child: Localizations(
          locale: kCupertinoSupportedLanguages.contains(locale.languageCode)
              ? locale
              : const Locale('en', 'US'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: Builder(builder: _buildBody),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = LingyunColors.forBrightness(widget.brightness);
    final label = colors.labels.primary;
    final secondary = colors.labels.secondary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      children: [
        Text(
          '提示',
          key: const Key('alert-title'),
          style: LingyunTextStyles.title1(emphasized: true, color: label),
        ),
        const SizedBox(height: 6),
        Text(
          '系统提示。不是液态玻璃，不是玻璃按钮，不是程序坞，也不是厚材质。'
          '稿面状态：单按钮、双按钮（取消在前）、破坏性、标题加信息、仅信息。'
          '确认和取消是稿面系统蓝。破坏性仍是对话框自己的红。'
          '点开是弹簧进场：从 1.3 缩到 1，同时淡入；关掉只淡出。'
          '按住按钮，底板立刻换色。字由系统对话框绘制；桌面不捆绑 SF Pro。',
          key: const Key('alert-scope'),
          style: LingyunTextStyles.footnote(color: secondary),
        ),
        const SizedBox(height: 10),
        CupertinoSlidingSegmentedControl<Brightness>(
          groupValue: widget.brightness,
          children: const {
            Brightness.light: Text('浅色', key: Key('alert-theme-light')),
            Brightness.dark: Text('深色', key: Key('alert-theme-dark')),
          },
          onValueChanged: (value) {
            if (value != null) widget.onBrightnessChanged?.call(value);
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1080
                ? 3
                : constraints.maxWidth >= 720
                ? 2
                : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final stage in _stages)
                  SizedBox(width: width, child: _stage(stage, label)),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          '实时路由 · 上次结果：$_result',
          key: const Key('alert-result'),
          style: LingyunTextStyles.footnote(emphasized: true, color: label),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final stage in _stages)
              CupertinoButton(
                key: Key('alert-live-${stage.keyName}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: () => _open(
                  title: stage.title,
                  message: stage.message,
                  actions: stage.actions,
                ),
                child: Text(stage.label),
              ),
          ],
        ),
      ],
    );
  }

  Widget _stage(_AlertSample stage, Color label) {
    final barrier = CupertinoDynamicColor.resolve(
      kCupertinoModalBarrierColor,
      context,
    );
    final canvas = widget.brightness == Brightness.dark
        ? const Color(0xFF000000)
        : const Color(0xFFD1D1D6);
    return KeyedSubtree(
      key: Key('alert-stage-${stage.keyName}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage.label,
            style: LingyunTextStyles.footnote(emphasized: true, color: label),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 248,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: canvas),
                  ColoredBox(color: barrier),
                  LingyunAlertDialog(
                    title: stage.title,
                    message: stage.message,
                    actions: stage.actions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertSample {
  const _AlertSample({
    required this.keyName,
    required this.label,
    required this.actions,
    this.title,
    this.message,
  });

  final String keyName;
  final String label;
  final String? title;
  final String? message;
  final List<LingyunAlertAction> actions;
}

const _sentence = '信息应简短完整。';

final List<_AlertSample> _stages = <_AlertSample>[
  const _AlertSample(
    keyName: 'single',
    label: '单按钮',
    title: '已保存',
    actions: <LingyunAlertAction>[LingyunAlertAction.confirm(label: '好')],
  ),
  const _AlertSample(
    keyName: 'dual',
    label: '双按钮',
    title: '短标题最好',
    message: _sentence,
    // 调用方先写确认。系统顺序会把取消放到前面。
    actions: <LingyunAlertAction>[
      LingyunAlertAction.confirm(label: '确认'),
      LingyunAlertAction.cancel(label: '取消'),
    ],
  ),
  const _AlertSample(
    keyName: 'destructive',
    label: '破坏性',
    title: '删除照片',
    message: '此操作无法撤销。',
    actions: <LingyunAlertAction>[
      LingyunAlertAction.destructive(label: '删除'),
      LingyunAlertAction.cancel(label: '取消'),
    ],
  ),
  const _AlertSample(
    keyName: 'title-message',
    label: '标题和信息',
    title: '短标题最好',
    message: _sentence,
    actions: <LingyunAlertAction>[LingyunAlertAction.confirm(label: '好')],
  ),
  const _AlertSample(
    keyName: 'message-only',
    label: '仅信息',
    message: '链接已复制。',
    actions: <LingyunAlertAction>[LingyunAlertAction.confirm(label: '好')],
  ),
];
