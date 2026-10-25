import 'package:material_ui/material_ui.dart';

/// One reachable gallery demo.
///
/// [id] is the canonical `?page=` value. [queries] includes [id] and every
/// legacy alias that must still open this leaf.
@immutable
class GalleryEntry {
  const GalleryEntry({
    required this.id,
    required this.label,
    required this.detail,
    required this.icon,
    required this.queries,
  });

  final String id;

  /// List-row title. Simplified Chinese. Not a root-tab label.
  final String label;

  /// One line under the row title.
  final String detail;

  final IconData icon;

  final List<String> queries;
}

/// One headed group of demos inside a workbench page.
///
/// The section title is not the card label. Every card on a workbench
/// uses [GalleryGroup.workbenchTitle].
@immutable
class GallerySection {
  const GallerySection({
    required this.id,
    required this.title,
    required this.entries,
  });

  final String id;
  final String title;
  final List<GalleryEntry> entries;
}

/// One root tab. The label is the Dock tab, not a demo title.
@immutable
class GalleryGroup {
  const GalleryGroup({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.sections,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final List<GallerySection> sections;

  /// Page title and the label on every card in this workbench.
  String get workbenchTitle => '$label工作台';

  List<GalleryEntry> get entries => [
    for (final section in sections) ...section.entries,
  ];
}

/// Where a known `?page=` value lives.
@immutable
class GallerySelection {
  const GallerySelection({required this.group, required this.entry});

  final GalleryGroup group;
  final GalleryEntry entry;
}

/// Four fixed groups. Wave 3 long-tail demos are not listed.
///
/// Each group is a workbench of several sections. A section holds one
/// card; the card's list rows are the demos. Leaf order inside a group
/// follows the design tree.
const List<GalleryGroup> galleryGroups = [
  GalleryGroup(
    id: 'basics',
    label: '基础',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view,
    sections: [
      GallerySection(
        id: 'surface',
        title: '表面',
        entries: [
          GalleryEntry(
            id: 'materials',
            label: '材质',
            detail: '超薄、薄、常规、厚',
            icon: Icons.layers_outlined,
            queries: ['materials'],
          ),
          GalleryEntry(
            id: 'glass',
            label: '液态玻璃',
            detail: '清透到程序坞的样式',
            icon: Icons.auto_awesome_outlined,
            queries: ['glass'],
          ),
          GalleryEntry(
            id: 'buttons',
            label: '玻璃按钮',
            detail: '尺寸、状态与变体',
            icon: Icons.smart_button_outlined,
            queries: ['buttons', 'button'],
          ),
        ],
      ),
      GallerySection(
        id: 'presentation',
        title: '呈现',
        entries: [
          GalleryEntry(
            id: 'themes',
            label: '主题',
            detail: '颜色与文本字阶',
            icon: Icons.brightness_6_outlined,
            queries: ['themes', 'colors', 'text'],
          ),
          GalleryEntry(
            id: 'layout',
            label: '布局',
            detail: '紧凑、常规、宽屏',
            icon: Icons.devices_outlined,
            queries: ['layout'],
          ),
          GalleryEntry(
            id: 'access',
            label: '辅助功能',
            detail: '透明度、动态、对比',
            icon: Icons.accessibility_new_outlined,
            queries: ['access'],
          ),
        ],
      ),
      GallerySection(
        id: 'host',
        title: '宿主',
        entries: [
          GalleryEntry(
            id: 'native',
            label: '原生',
            detail: 'iOS 页面宿主',
            icon: Icons.phone_iphone_outlined,
            queries: ['native'],
          ),
        ],
      ),
    ],
  ),
  GalleryGroup(
    id: 'controls',
    label: '控件',
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune,
    sections: [
      GallerySection(
        id: 'track',
        title: '轨道',
        entries: [
          GalleryEntry(
            id: 'knob',
            label: '旋钮与轨道',
            detail: '圆形旋钮叠在轨道上',
            icon: Icons.tune_outlined,
            queries: ['knob', 'track', 'controls'],
          ),
        ],
      ),
      GallerySection(
        id: 'content',
        title: '内容',
        entries: [
          GalleryEntry(
            id: 'lists',
            label: '列表',
            detail: '分组列表',
            icon: Icons.list_alt_outlined,
            queries: ['lists'],
          ),
          GalleryEntry(
            id: 'fields',
            label: '文本框',
            detail: '输入与校验',
            icon: Icons.short_text_outlined,
            queries: ['fields'],
          ),
          GalleryEntry(
            id: 'progress',
            label: '进度',
            detail: '直线与圆形',
            icon: Icons.timelapse_outlined,
            queries: ['progress'],
          ),
        ],
      ),
      GallerySection(
        id: 'adjust',
        title: '调节',
        entries: [
          GalleryEntry(
            id: 'toggles',
            label: '开关',
            detail: '开、关与按下',
            icon: Icons.toggle_on_outlined,
            queries: ['toggles', 'toggle'],
          ),
          GalleryEntry(
            id: 'sliders',
            label: '滑杆',
            detail: '轨道上的圆旋钮',
            icon: Icons.linear_scale,
            queries: ['sliders', 'slider'],
          ),
          GalleryEntry(
            id: 'steppers',
            label: '步进器',
            detail: '加减，没有旋钮',
            icon: Icons.exposure,
            queries: ['steppers', 'stepper'],
          ),
          GalleryEntry(
            id: 'segmented',
            label: '分段与页控',
            detail: '分段与页点合在一页',
            icon: Icons.view_week_outlined,
            queries: [
              'segmented',
              'segments',
              'pages',
              'page-controls',
              'pagecontrol',
            ],
          ),
        ],
      ),
    ],
  ),
  GalleryGroup(
    id: 'overlays',
    label: '浮层',
    icon: Icons.flip_to_front_outlined,
    selectedIcon: Icons.flip_to_front,
    sections: [
      GallerySection(
        id: 'modal',
        title: '模态',
        entries: [
          GalleryEntry(
            id: 'alerts',
            label: '提示',
            detail: '系统对话框',
            icon: Icons.notifications_outlined,
            queries: ['alerts'],
          ),
          GalleryEntry(
            id: 'sheets',
            label: '工作表',
            detail: '厚材质工作表',
            icon: Icons.horizontal_split,
            queries: ['sheets'],
          ),
          GalleryEntry(
            id: 'actions',
            label: '操作表',
            detail: '系统操作表',
            icon: Icons.more_horiz,
            queries: ['actions', 'action-sheets'],
          ),
        ],
      ),
      GallerySection(
        id: 'anchor',
        title: '锚定',
        entries: [
          GalleryEntry(
            id: 'popovers',
            label: '弹出框',
            detail: '锚定弹出框',
            icon: Icons.chat_bubble_outline,
            queries: ['popovers', 'popover'],
          ),
          GalleryEntry(
            id: 'menus',
            label: '菜单',
            detail: '玻璃菜单',
            icon: Icons.menu_open_outlined,
            queries: ['menus'],
          ),
        ],
      ),
    ],
  ),
  GalleryGroup(
    id: 'shell',
    label: '导航壳',
    icon: Icons.view_quilt_outlined,
    selectedIcon: Icons.view_quilt,
    sections: [
      GallerySection(
        id: 'bars',
        title: '栏',
        entries: [
          GalleryEntry(
            id: 'tabs',
            label: '标签栏',
            detail: '组件示例，不是这四个分组',
            icon: Icons.view_carousel_outlined,
            queries: ['tabs'],
          ),
          GalleryEntry(
            id: 'sidebars',
            label: '侧栏',
            detail: '厚材质侧栏',
            icon: Icons.view_sidebar_outlined,
            queries: ['sidebars', 'sidebar'],
          ),
        ],
      ),
      GallerySection(
        id: 'tools',
        title: '工具',
        entries: [
          GalleryEntry(
            id: 'toolbars',
            label: '工具栏',
            detail: '悬浮玻璃分组',
            icon: Icons.view_agenda_outlined,
            queries: ['toolbars', 'toolbar'],
          ),
        ],
      ),
    ],
  ),
];

/// Known `?page=` value, or null when [page] is missing or not a demo id.
GallerySelection? resolveGallerySelection(String? page) {
  if (page == null || page.isEmpty) return null;
  for (final group in galleryGroups) {
    for (final entry in group.entries) {
      if (entry.queries.contains(page)) {
        return GallerySelection(group: group, entry: entry);
      }
    }
  }
  return null;
}

/// Launch query and `GALLERY_*` environment values.
///
/// A query parameter wins over the matching environment value.
@immutable
class GalleryLaunch {
  const GalleryLaunch({
    this.page,
    this.theme,
    this.chrome,
    this.background,
    this.panel,
  });

  final String? page;
  final String? theme;
  final String? chrome;
  final String? background;
  final String? panel;

  bool get bare => chrome == '0';

  ThemeMode get themeMode => switch (theme) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };

  /// `?page=text` forces the text specimen, even if [panel] says otherwise.
  String? get themesPanel => page == 'text' ? 'text' : panel;

  static GalleryLaunch fromUri(Uri uri) {
    const envPage = String.fromEnvironment('GALLERY_PAGE');
    const envTheme = String.fromEnvironment('GALLERY_THEME');
    const envChrome = String.fromEnvironment('GALLERY_CHROME');
    const envBg = String.fromEnvironment('GALLERY_BG');
    final query = uri.queryParameters;
    final page = _first(query['page'], envPage);
    return GalleryLaunch(
      page: page,
      theme: _first(query['theme'], envTheme),
      chrome: _first(query['chrome'], envChrome),
      background: _first(query['bg'], envBg),
      panel: page == 'text' ? 'text' : query['panel'],
    );
  }

  static String? _first(String? query, String env) {
    if (query != null) return query;
    if (env.isEmpty) return null;
    return env;
  }
}
