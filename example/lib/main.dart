import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

import 'pages/accessibility_page.dart';
import 'pages/layout_page.dart';
import 'pages/materials_page.dart';
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

  @override
  void initState() {
    super.initState();
    final page = Uri.base.queryParameters['page'];
    _index = switch (page) {
      'themes' => 1,
      'layout' => 2,
      'access' => 3,
      _ => 0,
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
      home: LingyunAdaptivity(
        reduceTransparency: _reduceTransparency,
        reduceMotion: _reduceMotion,
        highContrast: _highContrast,
        child: DemoHome(
          index: _index,
          themeMode: _themeMode,
          reduceTransparency: _reduceTransparency,
          reduceMotion: _reduceMotion,
          highContrast: _highContrast,
          onIndexChanged: (i) => setState(() => _index = i),
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
          onReduceTransparency: (v) => setState(() => _reduceTransparency = v),
          onReduceMotion: (v) => setState(() => _reduceMotion = v),
          onHighContrast: (v) => setState(() => _highContrast = v),
        ),
      ),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({
    super.key,
    required this.index,
    required this.themeMode,
    required this.reduceTransparency,
    required this.reduceMotion,
    required this.highContrast,
    required this.onIndexChanged,
    required this.onThemeModeChanged,
    required this.onReduceTransparency,
    required this.onReduceMotion,
    required this.onHighContrast,
  });

  final int index;
  final ThemeMode themeMode;
  final bool reduceTransparency;
  final bool reduceMotion;
  final bool highContrast;
  final ValueChanged<int> onIndexChanged;
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
          children: [const SystemWallpaper(), pages[index]],
        );

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
