import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Sketch **Menus** gallery.
///
/// Resting bubbles are Liquid Glass Regular Large (hypothesis, 待核验).
/// The live control morphs that bubble out of the button and back.
/// Copy on this page is Simplified Chinese.
class MenusPage extends StatefulWidget {
  /// [brightness] follows the gallery light / dark toggle.
  const MenusPage({
    super.key,
    this.brightness = Brightness.light,
    this.onBrightnessChanged,
  });

  /// Theme brightness for the plates and the live menu.
  final Brightness brightness;

  /// Asks the gallery shell to switch light / dark.
  final ValueChanged<Brightness>? onBrightnessChanged;

  @override
  State<MenusPage> createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> {
  String _result = '尚未弹出';

  Future<void> _open(BuildContext anchorContext) async {
    final value = await showLingyunMenu(
      anchorContext,
      anchor: lingyunMenuAnchorOf(anchorContext),
      backLabel: '返回',
      barrierLabel: '关闭菜单',
      sections: _liveSections,
    );
    if (!mounted) return;
    setState(() => _result = value == null ? '已关闭' : _labelFor(value));
  }

  String _labelFor(LingyunMenuResult result) {
    var sections = _liveSections;
    LingyunMenuAction? action;
    for (final index in result.path) {
      final flat = lingyunMenuFlatten(sections);
      if (index < 0 || index >= flat.length) return '已选择';
      action = flat[index];
      if (action.hasChildren) {
        sections = [LingyunMenuSection(actions: action.children!)];
      }
    }
    return action?.label ?? '已选择';
  }

  @override
  Widget build(BuildContext context) {
    final colors = LingyunColors.forBrightness(widget.brightness);
    final label = colors.labels.primary;
    final secondary = colors.labels.secondary;
    return LingyunTheme(
      brightness: widget.brightness,
      child: CupertinoTheme(
        data: LingyunTheme.cupertinoThemeFor(widget.brightness),
        child: ListView(
          key: const Key('menu-gallery-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              '菜单',
              key: const Key('menu-title'),
              style: LingyunTextStyles.title1(emphasized: true, color: label),
            ),
            const SizedBox(height: 4),
            Text(
              '液态玻璃。点按钮后气泡从按钮形变打开，再缩回去。'
              '按住一行会轻轻缩放并亮一下。减少动态效果时直接出现，不再形变、不再缩放。'
              '不是厚材质，不是动作表，也不是弹出框。'
              '静止盘子用 Regular Large（放大后的玻璃，假设，待核验）。',
              key: const Key('menu-scope'),
              style: LingyunTextStyles.footnote(color: secondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CupertinoSlidingSegmentedControl<Brightness>(
                  groupValue: widget.brightness,
                  children: const {
                    Brightness.light: Text('浅色', key: Key('menu-theme-light')),
                    Brightness.dark: Text('深色', key: Key('menu-theme-dark')),
                  },
                  onValueChanged: (value) {
                    if (value != null) widget.onBrightnessChanged?.call(value);
                  },
                ),
                Builder(
                  builder: (context) {
                    return GlassButton(
                      key: const Key('menu-open'),
                      onPressed: () => _open(context),
                      child: const Text('打开菜单'),
                    );
                  },
                ),
                Text(
                  '上次结果：$_result',
                  key: const Key('menu-result'),
                  style: LingyunTextStyles.footnote(color: label),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [for (final plate in _plates) _Plate(spec: plate)],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlateSpec {
  const _PlateSpec({
    required this.keyName,
    required this.label,
    required this.child,
  });

  final String keyName;
  final String label;
  final Widget child;
}

class _Plate extends StatelessWidget {
  const _Plate({required this.spec});

  final _PlateSpec spec;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    return SizedBox(
      width: 300,
      child: KeyedSubtree(
        key: Key('menu-stage-${spec.keyName}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              spec.label,
              style: LingyunTextStyles.caption1(
                emphasized: true,
                color: colors.labels.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                const Positioned.fill(child: CustomPaint(painter: _Stripes())),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  child: spec.child,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final _plates = <_PlateSpec>[
  _PlateSpec(
    keyName: 'grouped',
    label: '分组与破坏性',
    child: LingyunMenu(
      interactive: false,
      showKeys: false,
      sections: [
        LingyunMenuSection(
          actions: [
            LingyunMenuAction(
              label: '拷贝',
              leading: Icon(CupertinoIcons.doc_on_doc),
            ),
            LingyunMenuAction(
              label: '复制',
              leading: Icon(CupertinoIcons.square_on_square),
            ),
            LingyunMenuAction(
              label: '粘贴',
              leading: Icon(CupertinoIcons.doc_on_clipboard),
            ),
          ],
        ),
        LingyunMenuSection(
          actions: [
            LingyunMenuAction(label: '分享', leading: Icon(CupertinoIcons.share)),
            LingyunMenuAction.destructive(
              label: '删除',
              leading: Icon(CupertinoIcons.trash),
            ),
          ],
        ),
      ],
    ),
  ),
  const _PlateSpec(
    keyName: 'selected',
    label: '选中',
    child: LingyunMenu(
      interactive: false,
      showKeys: false,
      sections: [
        LingyunMenuSection(
          actions: [
            LingyunMenuAction(label: '最新'),
            LingyunMenuAction(label: '名称', selected: true),
            LingyunMenuAction(label: '大小'),
          ],
        ),
      ],
    ),
  ),
  const _PlateSpec(
    keyName: 'disabled',
    label: '禁用',
    child: LingyunMenu(
      interactive: false,
      showKeys: false,
      sections: [
        LingyunMenuSection(
          actions: [
            LingyunMenuAction(label: '回复'),
            LingyunMenuAction(label: '转发', enabled: false),
          ],
        ),
      ],
    ),
  ),
  const _PlateSpec(
    keyName: 'pressed',
    label: '按下',
    child: LingyunMenu(
      interactive: false,
      showKeys: false,
      forcePressedIndex: 0,
      sections: [
        LingyunMenuSection(
          actions: [
            LingyunMenuAction(label: '拷贝'),
            LingyunMenuAction(label: '复制'),
          ],
        ),
      ],
    ),
  ),
  const _PlateSpec(
    keyName: 'submenu',
    label: '子菜单',
    child: LingyunMenu(
      interactive: false,
      showKeys: false,
      sections: [
        LingyunMenuSection(
          actions: [
            LingyunMenuAction(label: '拷贝'),
            LingyunMenuAction(
              label: '更多',
              children: [LingyunMenuAction(label: '拷贝链接')],
            ),
          ],
        ),
      ],
    ),
  ),
  _PlateSpec(
    keyName: 'anchor',
    label: '锚点',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GlassButton(onPressed: _noop, child: Text('排序')),
        const SizedBox(height: LingyunMenuLayout.anchorGap),
        LingyunMenu(
          interactive: false,
          showKeys: false,
          sections: _anchorSections,
        ),
      ],
    ),
  ),
];

void _noop() {}

const _anchorSections = <LingyunMenuSection>[
  LingyunMenuSection(
    actions: [
      LingyunMenuAction(label: '最新', selected: true),
      LingyunMenuAction(label: '名称'),
      LingyunMenuAction(label: '大小'),
    ],
  ),
];

final _liveSections = <LingyunMenuSection>[
  LingyunMenuSection(
    actions: [
      LingyunMenuAction(label: '拷贝', leading: Icon(CupertinoIcons.doc_on_doc)),
      LingyunMenuAction(
        label: '更多',
        children: [
          LingyunMenuAction(label: '拷贝链接'),
          LingyunMenuAction(label: '共享图像'),
        ],
      ),
    ],
  ),
  LingyunMenuSection(
    actions: [
      LingyunMenuAction.destructive(
        label: '删除',
        leading: Icon(CupertinoIcons.trash),
      ),
    ],
  ),
];

/// Vertical bands so the bubble has something to lens. Not a token.
/// Same colors as the sheet stripe field.
class _Stripes extends CustomPainter {
  const _Stripes();

  static const List<Color> bands = [
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
    if (size.width <= 0 || size.height <= 0) return;
    final band = size.width / bands.length;
    final paint = Paint();
    for (var i = 0; i < bands.length; i++) {
      paint.color = bands[i];
      canvas.drawRect(
        Rect.fromLTWH(i * band, 0, band + 0.5, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Stripes oldDelegate) => false;
}
