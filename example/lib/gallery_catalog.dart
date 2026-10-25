import 'package:flutter/foundation.dart';
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
/// The section title is the group name. The list label repeats
/// [GalleryGroup.workbenchTitle]. The rows sit in that list, not in a
/// separate Liquid Glass card.
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
    required this.homeKey,
    required this.icon,
    required this.selectedIcon,
    required this.sections,
  });

  final String id;
  final String label;

  /// `?home=` / `?tab=` value that opens this workbench (level 2).
  ///
  /// Distinct from leaf `?page=` ids. `?home=controls` opens this
  /// workbench. `?page=controls` opens 材质封装 on the Controls anchor.
  final String homeKey;

  final IconData icon;
  final IconData selectedIcon;
  final List<GallerySection> sections;

  /// Page title and the label above every section list in this workbench.
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
/// inset list labeled with the workbench name; the rows are the demos.
/// Leaf order inside a group follows the design tree.
const List<GalleryGroup> galleryGroups = [
  GalleryGroup(
    id: 'basics',
    label: '基础',
    homeKey: 'foundation',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view,
    sections: [
      GallerySection(
        id: 'surface',
        title: '表面',
        entries: [
          GalleryEntry(
            id: 'materials-pack',
            label: '材质封装',
            detail: '控件层、液态玻璃与材质',
            icon: Icons.layers_outlined,
            queries: [
              'materials-pack',
              'materials',
              'glass',
              'knob',
              'controls',
              'track',
            ],
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
    homeKey: 'controls',
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune,
    sections: [
      GallerySection(
        id: 'content',
        title: '内容',
        entries: [
          GalleryEntry(
            id: 'lists',
            label: '列表',
            detail: '常规材质的系统分组',
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
    homeKey: 'overlays',
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
    homeKey: 'chrome',
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

/// Workbench named by `?home=` or `?tab=`, or null when [key] is missing
/// or not one of foundation / controls / overlays / chrome.
GalleryGroup? resolveGalleryWorkbench(String? key) {
  if (key == null || key.isEmpty) return null;
  for (final group in galleryGroups) {
    if (group.homeKey == key) return group;
  }
  return null;
}

/// Query token used by device aliases and `orientation=`.
///
/// Trims, lowercases, and folds `×` / `*` to `x`. Spaces, underscores, and
/// hyphens are removed so `half-fold` and `678×466` share a key shape with
/// the existing `device=` aliases.
String _galleryQueryKey(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  return raw
      .trim()
      .toLowerCase()
      .replaceAll('×', 'x')
      .replaceAll('*', 'x')
      .replaceAll(RegExp(r'[\s_\-]'), '');
}

/// Hardware family for a [GalleryPreviewFrame].
///
/// Picks the vector bezel and the simplified safe-area inset.
enum GalleryPreviewForm { window, phone, pad, duo, desktop }

/// Portrait or landscape for a rotatable preview board.
///
/// `orientation=` accepts `portrait` / `landscape`, `port` / `land`,
/// `vertical` / `horizontal`, and `竖` / `横` / `竖屏` / `横屏`.
/// Desktop macOS / Windows and 「自适应窗口」 ignore it: rotation is not
/// meaningful there. `swap=1` or `rotate=1` flips the canonical
/// orientation when this value is absent. An explicit orientation wins.
enum GalleryPreviewOrientation {
  portrait,
  landscape;

  static GalleryPreviewOrientation? tryParse(String? raw) {
    return switch (_galleryQueryKey(raw)) {
      'portrait' || 'port' || 'vertical' || '竖' || '竖屏' => portrait,
      'landscape' || 'land' || 'horizontal' || '横' || '横屏' => landscape,
      _ => null,
    };
  }
}

/// Preview board for the gallery stage.
///
/// [logicalSize] is the point size of the clipped demo. Null is
/// 「自适应窗口」: the stage fills the window, draws no bezel, and leaves
/// [platform] unset so the host shows through. Every fixed frame injects
/// that size, a [platform], and [safePadding].
///
/// Public sizes:
/// Pro class 402×874, Pro Max 440×956, iPhone Air 420×912,
/// Duo outer 466×678, Duo inner landscape 951×669,
/// Duo inner portrait 669×951,
/// iPad mini 744×1133, iPad Air 11" 820×1180, iPad Pro 11" 834×1210,
/// iPad Air 13" 1024×1366, iPad Pro 13" 1032×1376,
/// macOS 1440×900, Windows 1280×800.
enum GalleryPreviewFrame {
  window('window', '窗口', '自适应窗口', null, [
    'window',
    'adaptive',
    'auto',
    'fit',
  ], form: GalleryPreviewForm.window),
  pro(
    'pro',
    'Pro',
    '18 / 17 / 16 Pro 402×874',
    Size(402, 874),
    [
      'pro',
      '18pro',
      '18-pro',
      '17',
      '17pro',
      '17-pro',
      '16pro',
      '16-pro',
      '402x874',
    ],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.phone,
  ),
  proMax(
    'pro-max',
    'Pro Max',
    'Pro Max 440×956',
    Size(440, 956),
    ['pro-max', 'promax', '440x956'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.phone,
  ),
  air(
    'air',
    'Air',
    'iPhone Air 420×912',
    Size(420, 912),
    ['air', 'iphone-air', 'iphoneair', '420x912'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.phone,
  ),
  duoOuter(
    'duo-outer',
    'Duo 外屏',
    'Duo 外屏 466×678',
    Size(466, 678),
    ['duo-outer', 'duo', 'outer', '466x678'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.duo,
  ),
  duoInnerLandscape(
    'duo-inner-landscape',
    'Duo 内屏横',
    'Duo 内屏横 951×669',
    Size(951, 669),
    ['duo-inner-landscape', 'duo-inner-land', 'duo-landscape', '951x669'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.duo,
  ),
  duoInnerPortrait(
    'duo-inner-portrait',
    'Duo 内屏竖',
    'Duo 内屏竖 669×951',
    Size(669, 951),
    ['duo-inner-portrait', 'duo-inner-port', 'duo-portrait', '669x951'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.duo,
  ),
  ipadMini(
    'ipad-mini',
    'iPad mini',
    'iPad mini 744×1133',
    Size(744, 1133),
    ['ipad-mini', 'ipadmini', 'iPad mini', 'mini', '744x1133'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.pad,
  ),
  ipadAir11(
    'ipad-air-11',
    'iPad Air 11',
    'iPad Air 11" 820×1180',
    Size(820, 1180),
    ['ipad-air-11', 'ipadair11', 'iPad Air 11', 'air11', '820x1180'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.pad,
  ),
  ipadPro11(
    'ipad-pro-11',
    'iPad Pro 11',
    'iPad Pro 11" 834×1210',
    Size(834, 1210),
    ['ipad-pro-11', 'ipadpro11', 'iPad Pro 11', 'pro11', '834x1210'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.pad,
  ),
  ipadAir13(
    'ipad-air-13',
    'iPad Air 13',
    'iPad Air 13" 1024×1366',
    Size(1024, 1366),
    ['ipad-air-13', 'ipadair13', 'iPad Air 13', 'air13', '1024x1366'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.pad,
  ),
  ipadPro13(
    'ipad-pro-13',
    'iPad Pro 13',
    'iPad Pro 13" 1032×1376',
    Size(1032, 1376),
    ['ipad-pro-13', 'ipadpro13', 'iPad Pro 13', 'pro13', '1032x1376'],
    platform: TargetPlatform.iOS,
    form: GalleryPreviewForm.pad,
  ),
  macos(
    'macos',
    'macOS',
    'macOS 1440×900',
    Size(1440, 900),
    ['macos', 'mac', 'osx', 'macbook', '1440x900'],
    platform: TargetPlatform.macOS,
    form: GalleryPreviewForm.desktop,
  ),
  windows(
    'windows',
    'Windows',
    'Windows 1280×800',
    Size(1280, 800),
    ['windows', 'win', 'win32', 'pc', '1280x800'],
    platform: TargetPlatform.windows,
    form: GalleryPreviewForm.desktop,
  );

  const GalleryPreviewFrame(
    this.query,
    this.shortLabel,
    this.label,
    this.logicalSize,
    this.aliases, {
    required this.form,
    this.platform,
  });

  /// Canonical `device=` / `frame=` value.
  final String query;

  /// Chip label.
  final String shortLabel;

  /// Menu label. Simplified Chinese, with the point size.
  final String label;

  /// Clipped stage size. Null fills the window.
  final Size? logicalSize;

  final List<String> aliases;

  /// Bezel and safe-area family. [GalleryPreviewForm.window] has neither.
  final GalleryPreviewForm form;

  /// Platform identity injected into the fixed board. Null follows the host.
  final TargetPlatform? platform;

  /// Phones, iPads, and Duo postures have a clear orientation.
  /// macOS, Windows, and 「自适应窗口」 do not.
  bool get canRotate => switch (form) {
    GalleryPreviewForm.window || GalleryPreviewForm.desktop => false,
    GalleryPreviewForm.phone ||
    GalleryPreviewForm.pad ||
    GalleryPreviewForm.duo => true,
  };

  /// Status and home inset inside the logical board.
  ///
  /// Phone uses a Dynamic Island band and a home indicator. Pad uses a
  /// status bar and a shorter home indicator. Duo uses a short status band
  /// and a small gesture inset. Desktop and 「自适应窗口」 stay zero.
  EdgeInsets get safePadding => switch (form) {
    GalleryPreviewForm.window || GalleryPreviewForm.desktop => EdgeInsets.zero,
    GalleryPreviewForm.phone => const EdgeInsets.only(top: 59, bottom: 34),
    GalleryPreviewForm.pad => const EdgeInsets.only(top: 24, bottom: 20),
    GalleryPreviewForm.duo => const EdgeInsets.only(top: 24, bottom: 12),
  };

  /// [logicalSize] after [orientation] / [swap].
  ///
  /// Null orientation and `swap: false` keep the canonical size. An
  /// explicit [orientation] wins over [swap]. Frames that cannot rotate
  /// ignore both and keep [logicalSize].
  Size? logicalSizeFor(
    GalleryPreviewOrientation? orientation, {
    bool swap = false,
  }) {
    final size = logicalSize;
    if (size == null || !canRotate) return size;
    final canonicalLandscape = size.width > size.height;
    final wantLandscape = switch (orientation) {
      GalleryPreviewOrientation.landscape => true,
      GalleryPreviewOrientation.portrait => false,
      null => swap ? !canonicalLandscape : canonicalLandscape,
    };
    if (wantLandscape == canonicalLandscape) return size;
    return Size(size.height, size.width);
  }

  /// Safe inset for [logicalSizeFor].
  ///
  /// A rotated phone moves the Dynamic Island to the side, so the inset
  /// follows that edge. Pad and Duo cameras sit in the bezel; their status
  /// band stays on the top of the logical rect.
  EdgeInsets safePaddingFor(
    GalleryPreviewOrientation? orientation, {
    bool swap = false,
  }) {
    final size = logicalSize;
    final oriented = logicalSizeFor(orientation, swap: swap);
    if (size == null || oriented == null || oriented.width == size.width) {
      return safePadding;
    }
    if (form == GalleryPreviewForm.phone) {
      return const EdgeInsets.fromLTRB(59, 0, 59, 21);
    }
    return safePadding;
  }

  /// True when the oriented board is wider than it is tall.
  bool showsLandscape(
    GalleryPreviewOrientation? orientation, {
    bool swap = false,
  }) {
    final size = logicalSizeFor(orientation, swap: swap);
    if (size == null) return false;
    return size.width > size.height;
  }

  /// Menu label. The trailing point size follows [orientation].
  String labelFor(GalleryPreviewOrientation? orientation, {bool swap = false}) {
    final size = logicalSize;
    final oriented = logicalSizeFor(orientation, swap: swap);
    if (size == null || oriented == null || oriented.width == size.width) {
      return label;
    }
    return label.replaceFirst(RegExp(r'\d+×\d+$'), _points(oriented));
  }

  /// Chip label. Canonical boards keep [shortLabel]. A swapped board appends
  /// the oriented point size.
  String shortLabelFor(
    GalleryPreviewOrientation? orientation, {
    bool swap = false,
  }) {
    final size = logicalSize;
    final oriented = logicalSizeFor(orientation, swap: swap);
    if (size == null || oriented == null || oriented.width == size.width) {
      return shortLabel;
    }
    return '$shortLabel ${_points(oriented)}';
  }

  static String _points(Size size) =>
      '${size.width.round()}×${size.height.round()}';

  static final Map<String, GalleryPreviewFrame> _byQuery = () {
    final map = <String, GalleryPreviewFrame>{};
    for (final frame in GalleryPreviewFrame.values) {
      for (final alias in [frame.query, ...frame.aliases]) {
        final key = _galleryQueryKey(alias);
        final existing = map[key];
        if (existing != null && existing != frame) {
          throw StateError('Duplicate preview frame alias $key');
        }
        map[key] = frame;
      }
    }
    return map;
  }();

  /// Known [raw] value, or null when it is missing or not a frame id.
  static GalleryPreviewFrame? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return _byQuery[_galleryQueryKey(raw)];
  }

  /// `device` wins when it names a frame. Otherwise `frame`.
  /// Unknown or missing values are [GalleryPreviewFrame.window].
  static GalleryPreviewFrame resolve(String? device, String? frame) {
    return tryParse(device) ?? tryParse(frame) ?? GalleryPreviewFrame.window;
  }
}

/// Publishes [platform] as [defaultTargetPlatform] for a debug preview board.
///
/// [Theme.platform] and the board [MediaQuery] are the scoped signals and
/// apply on every build. [debugDefaultTargetPlatformOverride] is only a
/// debug-mode stand-in for widgets that still read the global (alerts,
/// native shells). The setter throws outside debug mode, which includes
/// `flutter build web`, so release and profile builds — web included —
/// skip it and keep [Theme.platform] plus [MediaQuery]. Web debug honors
/// the override. Null clears it and the host platform shows through.
void bindGalleryFramePlatform(TargetPlatform? platform) {
  if (!kDebugMode) return;
  debugDefaultTargetPlatformOverride = platform;
}

/// Launch query and `GALLERY_*` environment values.
///
/// A query parameter wins over the matching environment value.
@immutable
class GalleryLaunch {
  const GalleryLaunch({
    this.page,
    this.home,
    this.tab,
    this.theme,
    this.chrome,
    this.background,
    this.panel,
    this.reduceTransparency = false,
    this.device = GalleryPreviewFrame.window,
    this.orientation,
    this.swapOrientation = false,
  });

  final String? page;

  /// `?home=foundation|controls|overlays|chrome`. Opens that workbench.
  final String? home;

  /// Same values as [home]. A known [tab] wins over [home].
  final String? tab;

  /// `theme=light|dark|system`.
  final String? theme;
  final String? chrome;
  final String? background;
  final String? panel;

  /// `reduceTransparency=` or `a11y=`. Switch only, no slider.
  final bool reduceTransparency;

  /// `device=` or `frame=`. See [GalleryPreviewFrame].
  final GalleryPreviewFrame device;

  /// `orientation=`. Null keeps the board's canonical orientation.
  /// Desktop and 「自适应窗口」 ignore it. See [GalleryPreviewOrientation].
  final GalleryPreviewOrientation? orientation;

  /// `swap=` or `rotate=`. Flips the canonical orientation when
  /// [orientation] is null. An explicit [orientation] wins.
  final bool swapOrientation;

  /// Level-2 target. A known [page] is a leaf and is not applied here.
  GalleryGroup? get workbench =>
      resolveGalleryWorkbench(tab) ?? resolveGalleryWorkbench(home);

  bool get bare => chrome == '0';

  ThemeMode get themeMode => switch (theme?.toLowerCase()) {
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
    const envDevice = String.fromEnvironment('GALLERY_DEVICE');
    const envFrame = String.fromEnvironment('GALLERY_FRAME');
    const envOrientation = String.fromEnvironment('GALLERY_ORIENTATION');
    const envSwap = String.fromEnvironment('GALLERY_SWAP');
    const envRotate = String.fromEnvironment('GALLERY_ROTATE');
    const envReduce = String.fromEnvironment('GALLERY_REDUCE_TRANSPARENCY');
    const envA11y = String.fromEnvironment('GALLERY_A11Y');
    final query = uri.queryParameters;
    final page = _first(query['page'], envPage);
    return GalleryLaunch(
      page: page,
      home: query['home'],
      tab: query['tab'],
      theme: _first(query['theme'], envTheme),
      chrome: _first(query['chrome'], envChrome),
      background: _first(query['bg'], envBg),
      panel: page == 'text' ? 'text' : query['panel'],
      reduceTransparency: _readReduceTransparency(
        query,
        envReduce: envReduce,
        envA11y: envA11y,
      ),
      device: GalleryPreviewFrame.resolve(
        _first(query['device'], envDevice),
        _first(query['frame'], envFrame),
      ),
      orientation: GalleryPreviewOrientation.tryParse(
        _first(query['orientation'], envOrientation),
      ),
      swapOrientation: _readSwap(query, envSwap: envSwap, envRotate: envRotate),
    );
  }

  /// Explicit `swap` wins over `rotate`. Truthy tokens match the a11y switch.
  static bool _readSwap(
    Map<String, String> query, {
    required String envSwap,
    required String envRotate,
  }) {
    if (query.containsKey('swap')) return _toggleOn(query['swap']);
    if (query.containsKey('rotate')) return _toggleOn(query['rotate']);
    if (envSwap.isNotEmpty) return _toggleOn(envSwap);
    if (envRotate.isNotEmpty) return _toggleOn(envRotate);
    return false;
  }

  static String? _first(String? query, String env) {
    if (query != null) return query;
    if (env.isEmpty) return null;
    return env;
  }

  /// Explicit `reduceTransparency` wins over `a11y`.
  ///
  /// Truthy tokens: `1`, `true`, `on`, `yes`. `a11y` also accepts
  /// `reduceTransparency`, `reduce-transparency`, and `transparency`.
  static bool _readReduceTransparency(
    Map<String, String> query, {
    required String envReduce,
    required String envA11y,
  }) {
    if (query.containsKey('reduceTransparency')) {
      return _toggleOn(query['reduceTransparency']);
    }
    if (query.containsKey('a11y')) {
      return _a11yOn(query['a11y']);
    }
    if (envReduce.isNotEmpty) return _toggleOn(envReduce);
    if (envA11y.isNotEmpty) return _a11yOn(envA11y);
    return false;
  }

  static bool _toggleOn(String? raw) {
    return switch (_token(raw)) {
      '1' || 'true' || 'on' || 'yes' => true,
      _ => false,
    };
  }

  static bool _a11yOn(String? raw) {
    return switch (_token(raw)) {
      '1' ||
      'true' ||
      'on' ||
      'yes' ||
      'reducetransparency' ||
      'reduce-transparency' ||
      'transparency' => true,
      _ => false,
    };
  }

  static String _token(String? raw) {
    return (raw ?? '').trim().toLowerCase().replaceAll('_', '-');
  }
}
