import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Colors gallery. Swatches are [LingyunColors], not Materials or glass recipes.
class ColorsPage extends StatelessWidget {
  const ColorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LingyunTheme.of(context);
    final colors = theme.colors;
    final label = colors.labels.primary;
    final groups = <String, List<LingyunSwatch>>{};
    for (final swatch in colors.swatches) {
      groups.putIfAbsent(swatch.group, () => []).add(swatch);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      children: [
        Text(
          '颜色',
          key: const Key('colors-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: label),
        ),
        const SizedBox(height: 8),
        Text(
          '色板来自 iOS 27 设计稿。玻璃上的文字用液态玻璃标签，不用系统标签的主要色。'
          '本页不展示材质配方，也不展示液态玻璃配方。制作用的画布色不收录。'
          '设计文件里的颜色页没有重新核对。',
          style: LingyunTextStyles.body(color: label),
        ),
        const SizedBox(height: 20),
        for (final entry in groups.entries) ...[
          Text(
            _groupName(entry.key),
            style: LingyunTextStyles.headline(color: label),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final swatch in entry.value)
                _Swatch(swatch: swatch, label: label),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Text('配色桥接', style: LingyunTextStyles.headline(color: label)),
        const SizedBox(height: 8),
        Text(
          '主色和错误色取系统蓝、系统红。主色上的字是已验收的填充白。'
          '表面取背景的主要色。表面上的字取标签的主要色，不是玻璃标签。'
          '次要色和三级色重复系统蓝，以免把另一套组件库的紫色当成系统色。'
          '这一重复只是桥接，待核验。',
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.swatch, required this.label});

  final LingyunSwatch swatch;
  final Color label;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.of(context).colors;
    return SizedBox(
      width: 148,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: swatch.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.separators.opaque, width: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _swatchName(swatch.name),
            style: LingyunTextStyles.caption1(emphasized: true, color: label),
          ),
          Text(
            _hex(swatch.color),
            style: LingyunTextStyles.caption2(color: colors.labels.secondary),
          ),
        ],
      ),
    );
  }
}

/// Sketch export order: RRGGBB, or RRGGBBAA when alpha is not opaque.
String _hex(Color color) {
  final a = (color.a * 255).round();
  final r = (color.r * 255).round();
  final g = (color.g * 255).round();
  final b = (color.b * 255).round();
  String channel(int value) {
    return value.toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  final rgb = '${channel(r)}${channel(g)}${channel(b)}';
  if (a == 255) return '#$rgb';
  return '#$rgb${channel(a)}';
}

const _groupNames = <String, String>{
  'System Colors': '系统颜色',
  'Labels': '标签',
  'Labels - Vibrant': '鲜明标签',
  'Labels - Liquid Glass': '液态玻璃标签',
  'Backgrounds': '背景',
  'Backgrounds - Elevated': '高层背景',
  'Backgrounds Grouped': '分组背景',
  'Backgrounds Grouped - Elevated': '高层分组背景',
  'Fills': '填充',
  'Fills - Vibrant': '鲜明填充',
  'Grays': '灰色',
  'Separators': '分隔线',
};

const _swatchNames = <String, String>{
  'Red': '红',
  'Orange': '橙',
  'Yellow': '黄',
  'Green': '绿',
  'Mint': '薄荷',
  'Teal': '青绿',
  'Cyan': '青',
  'Blue': '蓝',
  'Indigo': '靛',
  'Purple': '紫',
  'Pink': '粉',
  'Brown': '褐',
  'Primary': '主要',
  'Secondary': '次要',
  'Tertiary': '三级',
  'Quaternary': '四级',
  'Quinary': '五级',
  'Gray': '灰',
  'Gray 2': '灰 2',
  'Gray 3': '灰 3',
  'Gray 4': '灰 4',
  'Gray 5': '灰 5',
  'Gray 6': '灰 6',
  'Opaque': '不透明',
  'Non-Opaque': '半透明',
  'Vibrant': '鲜明',
};

String _groupName(String group) => _groupNames[group] ?? group;

String _swatchName(String name) => _swatchNames[name] ?? name;
