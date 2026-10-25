import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart' show Icons, Theme;

import 'gallery_stripes.dart';

/// Flutter toolbar gallery. Copy on this page is Simplified Chinese.
///
/// Groups are Liquid Glass Regular Medium. Not Dock, not Materials Thick,
/// not the native vertical toolbar.
class ToolbarsPage extends StatefulWidget {
  const ToolbarsPage({
    super.key,
    this.brightness = Brightness.light,
    this.onBrightnessChanged,
  });

  final Brightness brightness;
  final ValueChanged<Brightness>? onBrightnessChanged;

  @override
  State<ToolbarsPage> createState() => _ToolbarsPageState();
}

class _ToolbarsPageState extends State<ToolbarsPage> {
  bool _visible = true;
  int _shares = 0;
  LingyunToolbarPlacement _placement = LingyunToolbarPlacement.top;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunColors.forBrightness(widget.brightness);
    return ListView(
      key: const Key('toolbar-gallery-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          '工具栏',
          key: const Key('toolbar-title'),
          style: LingyunTextStyles.title1(
            emphasized: true,
            color: colors.labels.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '这是 Flutter 横条，不是 ios/ 里的竖向系统 Toolbar。'
          '对照 WWDC 的悬浮玻璃分组：leading 和 trailing 各自一块液态玻璃，'
          '默认 Regular Medium。不是一整条 Materials Thick，也不是标签栏的 Dock。'
          '一组一块外观，不在同一块玻璃上切浅深。'
          '模糊和饱和度仍是目录里的近似，待核验。',
          key: const Key('toolbar-glass-note'),
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 6),
        Text(
          '按压缩放到 0.97，和玻璃按钮已有的近似相同，不是新 token，时长 quick。'
          '显隐用 standard 档，带一小段滑动。'
          '弹簧数值没有写进 token。对照官方观感，待核验。'
          '减少动态效果时时长为 0。'
          'Duo 竖向 chrome 只对齐安全区和可选的中缝留白，不画成系统竖条。',
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 8),
        CupertinoSlidingSegmentedControl<Brightness>(
          groupValue: widget.brightness,
          children: const {
            Brightness.light: Text('浅色', key: Key('toolbar-theme-light')),
            Brightness.dark: Text('深色', key: Key('toolbar-theme-dark')),
          },
          onValueChanged: (value) {
            if (value != null) widget.onBrightnessChanged?.call(value);
          },
        ),
        const SizedBox(height: 12),
        _pair(),
        const SizedBox(height: 16),
        Text(
          '按压与显隐',
          style: LingyunTextStyles.headline(color: colors.labels.primary),
        ),
        const SizedBox(height: 8),
        _live(colors),
        const SizedBox(height: 16),
        Text(
          '宽而扁',
          style: LingyunTextStyles.headline(color: colors.labels.primary),
        ),
        const SizedBox(height: 4),
        Text(
          '下面这块把窗口看成 800×400。打开中缝留白后，分组会离左右远一点。'
          '这是 Flutter 留白，不是竖向系统工具栏。',
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 8),
        _hinge(),
      ],
    );
  }

  Widget _pair() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final light = _specimen(
          Brightness.light,
          const Key('toolbar-stage-light'),
        );
        final dark = _specimen(
          Brightness.dark,
          const Key('toolbar-stage-dark'),
        );
        if (constraints.maxWidth < 720) {
          return Column(children: [light, const SizedBox(height: 12), dark]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: light),
            const SizedBox(width: 12),
            Expanded(child: dark),
          ],
        );
      },
    );
  }

  Widget _specimen(Brightness brightness, Key key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          brightness == Brightness.dark ? '深色' : '浅色',
          style: LingyunTextStyles.caption1(
            emphasized: true,
            color: LingyunColors.forBrightness(widget.brightness)
                .labels
                .secondary,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          key: key,
          height: 148,
          child: _ambient(
            brightness,
            const Stack(
              fit: StackFit.expand,
              children: [
                GalleryStripes(),
                Align(
                  alignment: Alignment.topCenter,
                  child: LingyunToolbar(
                    title: Text('浏览'),
                    leading: LingyunToolbarActionButton(
                      action: LingyunToolbarAction(
                        icon: Icons.arrow_back_ios_new,
                        label: '返回',
                        onPressed: _noop,
                      ),
                    ),
                    actions: [
                      LingyunToolbarAction(
                        icon: Icons.share_outlined,
                        label: '分享',
                        onPressed: _noop,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _live(LingyunColors colors) {
    return DecoratedBox(
      key: const Key('toolbar-live'),
      decoration: BoxDecoration(
        border: Border.all(color: colors.separators.nonOpaque),
      ),
      child: SizedBox(
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const GalleryStripes(),
            Column(
              children: [
                if (_placement == LingyunToolbarPlacement.top) _bar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '已分享 $_shares 次',
                      key: const Key('toolbar-share-count'),
                      style: LingyunTextStyles.body(
                        color: colors.labels.primary,
                      ),
                    ),
                  ),
                ),
                if (_placement == LingyunToolbarPlacement.bottom) _bar(),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    CupertinoButton(
                      key: const Key('toolbar-visibility'),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      onPressed: () => setState(() => _visible = !_visible),
                      child: Text(_visible ? '隐藏' : '显示'),
                    ),
                    CupertinoButton(
                      key: const Key('toolbar-placement'),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      onPressed: () => setState(() {
                        _placement = _placement == LingyunToolbarPlacement.top
                            ? LingyunToolbarPlacement.bottom
                            : LingyunToolbarPlacement.top;
                      }),
                      child: Text(
                        _placement == LingyunToolbarPlacement.top
                            ? '改到底边'
                            : '改到顶边',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar() {
    return LingyunToolbar(
      visible: _visible,
      placement: _placement,
      title: const Text('浏览'),
      leading: LingyunToolbarActionButton(
        key: const Key('toolbar-live-back'),
        action: const LingyunToolbarAction(
          icon: Icons.arrow_back_ios_new,
          label: '返回',
          onPressed: _noop,
        ),
      ),
      actions: [
        LingyunToolbarAction(
          key: const Key('toolbar-live-share'),
          icon: Icons.share_outlined,
          label: '分享',
          onPressed: () => setState(() => _shares += 1),
        ),
      ],
    );
  }

  Widget _hinge() {
    return SizedBox(
      key: const Key('toolbar-hinge-stage'),
      height: 120,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800, 400)),
        child: const Stack(
          fit: StackFit.expand,
          children: [
            GalleryStripes(),
            Align(
              alignment: Alignment.topCenter,
              child: LingyunToolbar(
                avoidHinge: true,
                title: Text('留白'),
                actions: [
                  LingyunToolbarAction(
                    icon: Icons.share_outlined,
                    label: '分享',
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}

Widget _ambient(Brightness brightness, Widget child) {
  final glass = brightness == Brightness.dark
      ? LiquidGlassTheme.dark
      : LiquidGlassTheme.light;
  return Theme(
    data: LingyunMaterialTheme.themeData(brightness)
        .copyWith(extensions: [glass]),
    child: LingyunTheme(brightness: brightness, child: child),
  );
}
