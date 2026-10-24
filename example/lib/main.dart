import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

import 'pages/accessibility_page.dart';
import 'pages/alerts_page.dart';
import 'pages/controls_page.dart';
import 'pages/form_controls_page.dart';
import 'pages/glass_page.dart';
import 'pages/layout_page.dart';
import 'pages/lists_page.dart';
import 'pages/materials_page.dart';
import 'pages/native_page.dart';
import 'pages/progress_page.dart';
import 'pages/sheets_page.dart';
import 'pages/tab_bar_page.dart';
import 'pages/text_fields_page.dart';
import 'pages/themes_page.dart';
import 'wallpaper.dart';

void main() {
  runApp(const LingyunGlassDemoApp());
}

class LingyunGlassDemoApp extends StatefulWidget {
  const LingyunGlassDemoApp({super.key});

  @override
  State<LingyunGlassDemoApp> createState() => _LingyunGlassDemoAppState();
}

class _LingyunGlassDemoAppState extends State<LingyunGlassDemoApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _reduceTransparency = false;
  bool _reduceMotion = false;
  bool _highContrast = false;
  int _index = 0;
  FormControlPanel _formPanel = FormControlPanel.toggles;
  ThemesPanel _themesPanel = ThemesPanel.colors;
  bool _bare = false;
  GalleryBackground _background = GalleryBackground.canvas;

  @override
  void initState() {
    super.initState();
    final query = Uri.base.queryParameters;
    const envPage = String.fromEnvironment('GALLERY_PAGE');
    const envTheme = String.fromEnvironment('GALLERY_THEME');
    const envChrome = String.fromEnvironment('GALLERY_CHROME');
    const envBg = String.fromEnvironment('GALLERY_BG');
    final page = query['page'] ?? (envPage.isEmpty ? null : envPage);
    final theme = query['theme'] ?? (envTheme.isEmpty ? null : envTheme);
    final chrome = query['chrome'] ?? (envChrome.isEmpty ? null : envChrome);
    final bg = query['bg'] ?? (envBg.isEmpty ? null : envBg);
    _bare = chrome == '0';
    _background = GalleryBackground.fromQuery(bg);
    _formPanel = FormControlPanel.fromQuery(page) ?? FormControlPanel.toggles;
    _index = switch (page) {
      'glass' => 1,
      'tabs' => 2,
      'themes' || 'colors' || 'text' => 3,
      'layout' => 4,
      'access' => 5,
      'native' => 6,
      'alerts' => 7,
      'knob' || 'track' || 'controls' => 8,
      'lists' => 9,
      'fields' => 10,
      'progress' => 11,
      'toggles' ||
      'toggle' ||
      'sliders' ||
      'slider' ||
      'steppers' ||
      'stepper' => 12,
      'sheets' => 13,
      _ => 0,
    };
    final panel = page == 'text' ? 'text' : query['panel'];
    _themesPanel = switch (panel) {
      'text' => ThemesPanel.text,
      'samples' => ThemesPanel.samples,
      _ => ThemesPanel.colors,
    };
    _themeMode = switch (theme) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lingyun-ui-flutter',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF6B7C93),
        extensions: const [LiquidGlassTheme.light],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6B7C93),
        extensions: const [LiquidGlassTheme.dark],
      ),
      home: GalleryBackgroundScope(
        mode: _background,
        child: LingyunAdaptivity(
          reduceTransparency: _reduceTransparency,
          reduceMotion: _reduceMotion,
          highContrast: _highContrast,
          child: DemoHome(
            index: _index,
            formPanel: _formPanel,
            themesPanel: _themesPanel,
            bare: _bare,
            background: _background,
            themeMode: _themeMode,
            reduceTransparency: _reduceTransparency,
            reduceMotion: _reduceMotion,
            highContrast: _highContrast,
            onIndexChanged: (i) => setState(() => _index = i),
            onBackgroundChanged: (mode) => setState(() => _background = mode),
            onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
            onReduceTransparency: (v) =>
                setState(() => _reduceTransparency = v),
            onReduceMotion: (v) => setState(() => _reduceMotion = v),
            onHighContrast: (v) => setState(() => _highContrast = v),
          ),
        ),
      ),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({
    super.key,
    required this.index,
    required this.formPanel,
    required this.themesPanel,
    required this.bare,
    required this.background,
    required this.themeMode,
    required this.reduceTransparency,
    required this.reduceMotion,
    required this.highContrast,
    required this.onIndexChanged,
    required this.onBackgroundChanged,
    required this.onThemeModeChanged,
    required this.onReduceTransparency,
    required this.onReduceMotion,
    required this.onHighContrast,
  });

  final int index;
  final FormControlPanel formPanel;
  final ThemesPanel themesPanel;
  final bool bare;
  final GalleryBackground background;
  final ThemeMode themeMode;
  final bool reduceTransparency;
  final bool reduceMotion;
  final bool highContrast;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<GalleryBackground> onBackgroundChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onReduceTransparency;
  final ValueChanged<bool> onReduceMotion;
  final ValueChanged<bool> onHighContrast;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.layers_outlined),
      selectedIcon: Icon(Icons.layers),
      label: 'Materials',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome),
      label: 'Glass',
    ),
    NavigationDestination(
      icon: Icon(Icons.view_carousel_outlined),
      selectedIcon: Icon(Icons.view_carousel),
      label: 'Tabs',
    ),
    NavigationDestination(
      icon: Icon(Icons.brightness_6_outlined),
      selectedIcon: Icon(Icons.brightness_6),
      label: '主题',
    ),
    NavigationDestination(
      icon: Icon(Icons.devices_outlined),
      selectedIcon: Icon(Icons.devices),
      label: 'Layout',
    ),
    NavigationDestination(
      icon: Icon(Icons.accessibility_new_outlined),
      selectedIcon: Icon(Icons.accessibility_new),
      label: 'Access',
    ),
    NavigationDestination(
      icon: Icon(Icons.phone_iphone_outlined),
      selectedIcon: Icon(Icons.phone_iphone),
      label: 'Native',
    ),
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: '提示',
    ),
    NavigationDestination(
      icon: Icon(Icons.tune_outlined),
      selectedIcon: Icon(Icons.tune),
      label: '旋钮',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt_outlined),
      selectedIcon: Icon(Icons.list_alt),
      label: '列表',
    ),
    NavigationDestination(
      icon: Icon(Icons.short_text_outlined),
      selectedIcon: Icon(Icons.short_text),
      label: '文本框',
    ),
    NavigationDestination(
      icon: Icon(Icons.timelapse_outlined),
      selectedIcon: Icon(Icons.timelapse),
      label: '进度',
    ),
    NavigationDestination(
      icon: Icon(Icons.toggle_on_outlined),
      selectedIcon: Icon(Icons.toggle_on),
      label: '开关',
    ),
    NavigationDestination(
      icon: Icon(Icons.horizontal_split),
      selectedIcon: Icon(Icons.horizontal_split),
      label: '工作表',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MaterialsPage(),
      const GlassPage(),
      const TabBarPage(),
      ThemesPage(
        themeMode: themeMode,
        onThemeModeChanged: onThemeModeChanged,
        initialPanel: themesPanel,
      ),
      const LayoutPage(),
      AccessibilityPage(
        reduceTransparency: reduceTransparency,
        reduceMotion: reduceMotion,
        highContrast: highContrast,
        onReduceTransparency: onReduceTransparency,
        onReduceMotion: onReduceMotion,
        onHighContrast: onHighContrast,
      ),
      const NativePage(),
      AlertsPage(brightness: Theme.of(context).brightness),
      ControlsPage(
        themeMode: themeMode,
        onThemeModeChanged: onThemeModeChanged,
      ),
      const ListsPage(),
      const TextFieldsPage(),
      const ProgressPage(),
      FormControlsPage(
        themeMode: themeMode,
        onThemeModeChanged: onThemeModeChanged,
        initialPanel: formPanel,
      ),
      SheetsPage(
        brightness: Theme.of(context).brightness,
        onBrightnessChanged: (brightness) => onThemeModeChanged(
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
        ),
      ),
    ];

    return LingyunTheme(
      brightness: Theme.of(context).brightness,
      child: LingyunLayoutBuilder(
        builder: (context, data) {
          final useRail = !data.isCompact || data.isWideShort;
          final body = Stack(
            fit: StackFit.expand,
            children: [
              const SystemWallpaper(),
              pages[index],
              if (!bare)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: GalleryBackgroundButton(
                        mode: background,
                        onChanged: onBackgroundChanged,
                      ),
                    ),
                  ),
                ),
            ],
          );

          if (bare) {
            return Scaffold(backgroundColor: Colors.transparent, body: body);
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Row(
              children: [
                if (useRail)
                  NavigationRail(
                    key: const Key('gallery-rail'),
                    selectedIndex: index,
                    onDestinationSelected: onIndexChanged,
                    labelType: NavigationRailLabelType.all,
                    // Fourteen labeled destinations do not fit a short window.
                    scrollable: true,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    destinations: [
                      for (final d in _destinations)
                        NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label),
                        ),
                    ],
                  ),
                Expanded(
                  child: KeyedSubtree(
                    key: const Key('gallery-body'),
                    child: body,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: useRail
                ? null
                : NavigationBar(
                    selectedIndex: index,
                    onDestinationSelected: onIndexChanged,
                    destinations: _destinations,
                  ),
          );
        },
      ),
    );
  }
}
