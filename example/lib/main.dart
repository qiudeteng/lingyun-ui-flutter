import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

import 'pages/accessibility_page.dart';
import 'pages/glass_page.dart';
import 'pages/layout_page.dart';
import 'pages/materials_page.dart';
import 'pages/tab_bar_page.dart';
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
  bool _bare = false;
  GalleryBackground _background = GalleryBackground.canvas;

  @override
  void initState() {
    super.initState();
    final page = Uri.base.queryParameters['page'];
    _bare = Uri.base.queryParameters['chrome'] == '0';
    _background = GalleryBackground.fromQuery(Uri.base.queryParameters['bg']);
    _index = switch (page) {
      'glass' => 1,
      'tabs' => 2,
      'themes' => 3,
      'layout' => 4,
      'access' => 5,
      _ => 0,
    };
    _themeMode = switch (Uri.base.queryParameters['theme']) {
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
      label: 'Themes',
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
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MaterialsPage(),
      const GlassPage(),
      const TabBarPage(),
      ThemesPage(themeMode: themeMode, onThemeModeChanged: onThemeModeChanged),
      const LayoutPage(),
      AccessibilityPage(
        reduceTransparency: reduceTransparency,
        reduceMotion: reduceMotion,
        highContrast: highContrast,
        onReduceTransparency: onReduceTransparency,
        onReduceMotion: onReduceMotion,
        onHighContrast: onHighContrast,
      ),
    ];

    return LingyunLayoutBuilder(
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
                  selectedIndex: index,
                  onDestinationSelected: onIndexChanged,
                  labelType: NavigationRailLabelType.all,
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
              Expanded(child: body),
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
    );
  }
}
