import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'gallery_catalog.dart';
import 'gallery_shell.dart';
import 'pages/accessibility_page.dart';
import 'pages/action_sheets_page.dart';
import 'pages/alerts_page.dart';
import 'pages/buttons_page.dart';
import 'pages/controls_page.dart';
import 'pages/form_controls_page.dart';
import 'pages/glass_page.dart';
import 'pages/layout_page.dart';
import 'pages/lists_page.dart';
import 'pages/materials_page.dart';
import 'pages/menus_page.dart';
import 'pages/native_page.dart';
import 'pages/popovers_page.dart';
import 'pages/progress_page.dart';
import 'pages/sheets_page.dart';
import 'pages/sidebars_page.dart';
import 'pages/tab_bar_page.dart';
import 'pages/text_fields_page.dart';
import 'pages/themes_page.dart';
import 'pages/toolbars_page.dart';
import 'pages/wave1c_page.dart';
import 'wallpaper.dart';

void main() {
  runApp(const LingyunGlassDemoApp());
}

class LingyunGlassDemoApp extends StatefulWidget {
  const LingyunGlassDemoApp({super.key, this.launch});

  /// Test hook. Null reads [Uri.base] and the `GALLERY_*` environment keys.
  final GalleryLaunch? launch;

  @override
  State<LingyunGlassDemoApp> createState() => _LingyunGlassDemoAppState();
}

class _LingyunGlassDemoAppState extends State<LingyunGlassDemoApp> {
  late GalleryLaunch _launch;
  ThemeMode _themeMode = ThemeMode.light;
  bool _reduceTransparency = false;
  bool _reduceMotion = false;
  bool _highContrast = false;
  Wave1cPanel _wave1cPanel = Wave1cPanel.segmented;
  ThemesPanel _themesPanel = ThemesPanel.colors;

  @override
  void initState() {
    super.initState();
    _apply(widget.launch ?? GalleryLaunch.fromUri(Uri.base));
  }

  void _apply(GalleryLaunch launch) {
    _launch = launch;
    _wave1cPanel = Wave1cPanel.fromQuery(launch.page) ?? Wave1cPanel.segmented;
    _themesPanel = switch (launch.themesPanel) {
      'text' => ThemesPanel.text,
      'samples' => ThemesPanel.samples,
      _ => ThemesPanel.colors,
    };
    _themeMode = launch.themeMode;
  }

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  void _setBrightness(Brightness brightness) {
    _setThemeMode(
      brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Widget _page(BuildContext context, String entryId) {
    final brightness = Theme.of(context).brightness;
    return switch (entryId) {
      'materials' => const MaterialsPage(),
      'glass' => const GlassPage(),
      'themes' => ThemesPage(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
        initialPanel: _themesPanel,
      ),
      'layout' => const LayoutPage(),
      'access' => AccessibilityPage(
        reduceTransparency: _reduceTransparency,
        reduceMotion: _reduceMotion,
        highContrast: _highContrast,
        onReduceTransparency: (value) =>
            setState(() => _reduceTransparency = value),
        onReduceMotion: (value) => setState(() => _reduceMotion = value),
        onHighContrast: (value) => setState(() => _highContrast = value),
      ),
      'native' => const NativePage(),
      'knob' => ControlsPage(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
      'lists' => const ListsPage(),
      'fields' => const TextFieldsPage(),
      'progress' => const ProgressPage(),
      'buttons' => const ButtonsPage(),
      'toggles' => FormControlsPage(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
        initialPanel: FormControlPanel.toggles,
      ),
      'sliders' => FormControlsPage(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
        initialPanel: FormControlPanel.sliders,
      ),
      'steppers' => FormControlsPage(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
        initialPanel: FormControlPanel.steppers,
      ),
      'segmented' => Wave1cPage(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
        initialPanel: _wave1cPanel,
      ),
      'alerts' => AlertsPage(
        brightness: brightness,
        onBrightnessChanged: _setBrightness,
      ),
      'sheets' => SheetsPage(
        brightness: brightness,
        onBrightnessChanged: _setBrightness,
      ),
      'actions' => ActionSheetsPage(brightness: brightness),
      'popovers' => PopoversPage(
        brightness: brightness,
        onBrightnessChanged: _setBrightness,
      ),
      'menus' => MenusPage(
        brightness: brightness,
        onBrightnessChanged: _setBrightness,
      ),
      'tabs' => const TabBarPage(),
      'sidebars' => SidebarsPage(
        brightness: brightness,
        onBrightnessChanged: _setBrightness,
      ),
      'toolbars' => ToolbarsPage(
        brightness: brightness,
        onBrightnessChanged: _setBrightness,
      ),
      _ => throw StateError('Unknown gallery entry $entryId'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '凌云界面',
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
        mode: _launch.background == null
            ? GalleryBackground.canvas
            : GalleryBackground.fromQuery(_launch.background),
        child: LingyunAdaptivity(
          reduceTransparency: _reduceTransparency,
          reduceMotion: _reduceMotion,
          highContrast: _highContrast,
          child: GalleryShell(
            initialPage: _launch.page,
            bare: _launch.bare,
            background: GalleryBackground.fromQuery(_launch.background),
            onBackgroundChanged: (mode) {
              setState(() {
                _launch = GalleryLaunch(
                  page: _launch.page,
                  theme: _launch.theme,
                  chrome: _launch.chrome,
                  background: mode.query,
                  panel: _launch.panel,
                );
              });
            },
            pageBuilder: _page,
          ),
        ),
      ),
    );
  }
}
