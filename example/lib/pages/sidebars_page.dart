import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart' show Icons, Theme;

import 'gallery_stripes.dart';

/// Formal sidebar gallery. Copy on this page is Simplified Chinese.
///
/// Each specimen is one ambient brightness. The column is Materials Thick
/// over stripes. The Dock rail demo stays Dock.
class SidebarsPage extends StatefulWidget {
  const SidebarsPage({
    super.key,
    this.brightness = Brightness.light,
    this.onBrightnessChanged,
  });

  final Brightness brightness;
  final ValueChanged<Brightness>? onBrightnessChanged;

  @override
  State<SidebarsPage> createState() => _SidebarsPageState();
}

class _SidebarsPageState extends State<SidebarsPage> {
  static const _specimenSections = [
    LingyunSidebarSection(
      header: '邮箱',
      items: [
        LingyunSidebarItem(label: '收件箱', icon: Icons.inbox_outlined),
        LingyunSidebarItem(label: '已发送', icon: Icons.send_outlined),
      ],
    ),
  ];

  static const _sections = [
    LingyunSidebarSection(
      header: '邮箱',
      items: [
        LingyunSidebarItem(
          key: Key('sidebar-live-inbox'),
          label: '收件箱',
          icon: Icons.inbox_outlined,
        ),
        LingyunSidebarItem(label: '已发送', icon: Icons.send_outlined),
        LingyunSidebarItem(
          label: '已归档',
          icon: Icons.archive_outlined,
          enabled: false,
        ),
      ],
    ),
    LingyunSidebarSection(
      header: '资料',
      items: [
        LingyunSidebarItem(label: '文稿', icon: Icons.description_outlined),
        LingyunSidebarItem(label: '图片', icon: Icons.image_outlined),
      ],
    ),
  ];

  int _selected = 0;
  bool _expanded = true;
  bool _toolbarVisible = true;
  bool _rail = false;
  int _railIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunColors.forBrightness(widget.brightness);
    return ListView(
      key: const Key('sidebar-gallery-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          '侧栏',
          key: const Key('sidebar-title'),
          style: LingyunTextStyles.title1(
            emphasized: true,
            color: colors.labels.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '正式侧栏的外壳是 Materials Thick，和工作表同一套装配：条纹在下，'
          'GlassSurface 只写 material: MaterialTier.thick，直盖在上面。'
          '整列跟随当前外观，不在同一块表面上切浅色和深色。'
          '下面两块样张各自完整。',
          key: const Key('sidebar-thick-note'),
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 6),
        Text(
          '它不是 LingyunPage 的玻璃 rail（GlassTabBarStyle.sidebar，液态玻璃 Dock，'
          '宽 96，待核验），也不是 iOS 27.1 竖向系统 Toolbar。'
          'Tab 与玻璃轨的流动仍是 Dock，不把 Thick 卷进去。原生竖向 chrome 在 ios/。',
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 6),
        Text(
          '展开和收起用系统页面过渡的同一条曲线（fastEaseInToSlowEaseOut），'
          '时长用已有的 emphasized 档。不新造弹簧 token。'
          '侧栏弹簧未公布，对照官方观感，待核验。'
          '选中项用 quick 档滑过去。行按压是系统列表行。'
          '减少动态效果时时长为 0。宽度 320、圆角 34 待核验。',
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 8),
        CupertinoSlidingSegmentedControl<Brightness>(
          groupValue: widget.brightness,
          children: const {
            Brightness.light: Text('浅色', key: Key('sidebar-theme-light')),
            Brightness.dark: Text('深色', key: Key('sidebar-theme-dark')),
          },
          onValueChanged: (value) {
            if (value != null) widget.onBrightnessChanged?.call(value);
          },
        ),
        const SizedBox(height: 12),
        _pair(),
        const SizedBox(height: 12),
        Text(
          '与分栏共存',
          style: LingyunTextStyles.headline(color: colors.labels.primary),
        ),
        const SizedBox(height: 4),
        Text(
          '详情列里的横条是 Flutter 工具栏，不是竖向系统条。'
          '收起后列宽回到 0。已归档不可点。',
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 460, child: _live(colors)),
        const SizedBox(height: 16),
        Text(
          '玻璃轨（不是正式侧栏）',
          key: const Key('sidebar-rail-note'),
          style: LingyunTextStyles.headline(color: colors.labels.primary),
        ),
        const SizedBox(height: 4),
        Text(
          '对照 WWDC 的 Tab 与 Sidebar 流动：位置在底栏和前缘之间移动，'
          '材质始终是 Dock。这是 Flutter 示意，不是 UIKit 流体过渡，'
          '也不改成 Thick。',
          style: LingyunTextStyles.footnote(color: colors.labels.secondary),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          key: const Key('sidebar-rail-toggle'),
          padding: EdgeInsets.zero,
          onPressed: () => setState(() => _rail = !_rail),
          child: Text(_rail ? '回到底栏' : '收到玻璃轨'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          key: const Key('sidebar-rail-stage'),
          height: 280,
          child: _railStage(),
        ),
      ],
    );
  }

  Widget _pair() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final light = _specimen(
          Brightness.light,
          const Key('sidebar-stage-light'),
        );
        final dark = _specimen(
          Brightness.dark,
          const Key('sidebar-stage-dark'),
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
    final colors = LingyunColors.forBrightness(brightness);
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
          height: 360,
          child: _ambient(
            brightness,
            Stack(
              fit: StackFit.expand,
              children: [
                const GalleryStripes(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: LingyunSidebarMetrics.preferredWidth,
                    child: LingyunSidebar(
                      title: '资料库',
                      subtitle: '整列一个外观',
                      sections: _specimenSections,
                      selectedIndex: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Thick · ${brightness == Brightness.dark ? '深' : '浅'}',
          style: LingyunTextStyles.caption2(color: colors.labels.secondary),
        ),
      ],
    );
  }

  Widget _live(LingyunColors colors) {
    final label = _sections.fold<List<String>>([], (labels, section) {
      return [...labels, for (final item in section.items) item.label];
    })[_selected];
    return DecoratedBox(
      key: const Key('sidebar-live'),
      decoration: BoxDecoration(
        border: Border.all(color: colors.separators.nonOpaque),
      ),
      child: LingyunSidebarLayout(
        expanded: _expanded,
        title: '资料库',
        sections: _sections,
        selectedIndex: _selected,
        onSelected: (index) => setState(() => _selected = index),
        backdrop: const GalleryStripes(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LingyunToolbar(
              visible: _toolbarVisible,
              title: Text(label),
              leading: LingyunToolbarActionButton(
                action: LingyunToolbarAction(
                  icon: Icons.menu,
                  label: '展开或收起侧栏',
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ),
              actions: [
                LingyunToolbarAction(
                  icon: _toolbarVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  label: '显示或隐藏工具栏',
                  onPressed: () =>
                      setState(() => _toolbarVisible = !_toolbarVisible),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '当前：$label',
                  key: const Key('sidebar-live-selection'),
                  style: LingyunTextStyles.body(color: colors.labels.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _railStage() {
    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.standard,
    );
    final curve = LiquidGlassMotion.curveOf(
      context,
      Curves.fastEaseInToSlowEaseOut,
    );
    const items = [
      GlassTabBarItem(icon: Icons.inbox_outlined, label: '收件'),
      GlassTabBarItem(icon: Icons.send_outlined, label: '发出'),
      GlassTabBarItem(icon: Icons.description_outlined, label: '文稿'),
    ];
    return Stack(
      fit: StackFit.expand,
      children: [
        const GalleryStripes(),
        AnimatedAlign(
          alignment: _rail ? Alignment.centerLeft : Alignment.bottomCenter,
          duration: duration,
          curve: curve,
          child: GlassTabBar(
            key: const Key('sidebar-rail-bar'),
            style: _rail
                ? GlassTabBarStyle.sidebar
                : GlassTabBarStyle.floatingPill,
            glassStyle: LiquidGlassStyle.dock,
            items: items,
            currentIndex: _railIndex,
            onChanged: (index) => setState(() => _railIndex = index),
          ),
        ),
      ],
    );
  }
}

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
