import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Sketch **Action Sheets** gallery.
///
/// Each plate is a `cupertino_ui` [LingyunActionSheet] on the system barrier
/// color. Live buttons call [showLingyunActionSheet]. Nothing here is a
/// custom Liquid Glass drawing or a Materials Thick sheet.
class ActionSheetsPage extends StatefulWidget {
  /// [brightness] follows the gallery light / dark toggle.
  const ActionSheetsPage({super.key, this.brightness = Brightness.light});

  /// Cupertino theme brightness for the system sheets.
  final Brightness brightness;

  @override
  State<ActionSheetsPage> createState() => _ActionSheetsPageState();
}

class _ActionSheetsPageState extends State<ActionSheetsPage> {
  String _result = '尚未弹出';

  Future<void> _open(_ActionSheetSample stage) async {
    final index = await showLingyunActionSheet(
      context,
      title: stage.title,
      message: stage.message,
      actions: stage.actions,
    );
    if (!mounted) return;
    setState(() {
      _result = index == null ? '已关闭' : stage.actions[index].label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US');
    return CupertinoTheme(
      data: CupertinoThemeData(brightness: widget.brightness),
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
    );
  }

  Widget _buildBody(BuildContext context) {
    final label = CupertinoColors.label.resolveFrom(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    return ListView(
      key: const Key('action-sheet-gallery-scroll'),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      children: [
        Text(
          '操作表',
          key: const Key('action-sheet-title'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: label,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '系统操作表。不是液态玻璃自绘，不是玻璃按钮，不是程序坞，也不是厚材质工作表。'
          '普通操作在上组，取消单独贴在下面。破坏性是系统红。'
          '弹出和收起走系统弹簧；减少动态效果时直接出现、直接消失。按下只换系统底色。',
          key: const Key('action-sheet-scope'),
          style: TextStyle(fontSize: 13, height: 1.35, color: secondary),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1200
                ? 3
                : constraints.maxWidth >= 800
                ? 2
                : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final stage in _stages)
                  SizedBox(width: width, child: _stage(context, stage, label)),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          '实时路由 · 上次结果：$_result',
          key: const Key('action-sheet-result'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: label,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final stage in _stages)
              CupertinoButton(
                key: Key('action-sheet-live-${stage.keyName}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: () => _open(stage),
                child: Text(stage.label),
              ),
          ],
        ),
      ],
    );
  }

  Widget _stage(BuildContext context, _ActionSheetSample stage, Color label) {
    final barrier = CupertinoDynamicColor.resolve(
      kCupertinoModalBarrierColor,
      context,
    );
    final canvas = widget.brightness == Brightness.dark
        ? const Color(0xFF000000)
        : const Color(0xFFD1D1D6);
    return KeyedSubtree(
      key: Key('action-sheet-stage-${stage.keyName}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: label,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 520,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(size: size),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: canvas),
                        ColoredBox(color: barrier),
                        LingyunActionSheet(
                          title: stage.title,
                          message: stage.message,
                          actions: stage.actions,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSheetSample {
  const _ActionSheetSample({
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
  final List<LingyunActionSheetAction> actions;
}

const _sentence = '信息应简短完整。';

final List<_ActionSheetSample> _stages = <_ActionSheetSample>[
  const _ActionSheetSample(
    keyName: 'titled',
    label: '标题和信息',
    title: '短标题最好',
    message: _sentence,
    actions: <LingyunActionSheetAction>[
      LingyunActionSheetAction.confirm(label: '确认'),
      LingyunActionSheetAction.cancel(label: '取消'),
    ],
  ),
  const _ActionSheetSample(
    keyName: 'destructive',
    label: '破坏性',
    title: '删除照片',
    message: '此操作无法撤销。',
    actions: <LingyunActionSheetAction>[
      LingyunActionSheetAction.destructive(label: '删除'),
      LingyunActionSheetAction.cancel(label: '取消'),
    ],
  ),
  const _ActionSheetSample(
    keyName: 'several',
    label: '多项',
    title: '选择操作',
    // 取消写在最前。系统仍把它抽到最下面。
    actions: <LingyunActionSheetAction>[
      LingyunActionSheetAction.cancel(label: '取消'),
      LingyunActionSheetAction.regular(label: '拷贝'),
      LingyunActionSheetAction.confirm(label: '存储'),
      LingyunActionSheetAction.destructive(label: '删除'),
    ],
  ),
  const _ActionSheetSample(
    keyName: 'plain',
    label: '仅操作',
    actions: <LingyunActionSheetAction>[
      LingyunActionSheetAction.regular(label: '打开'),
      LingyunActionSheetAction.cancel(label: '取消'),
    ],
  ),
];
