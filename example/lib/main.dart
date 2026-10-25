import 'package:flutter/foundation.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'gallery_catalog.dart';
import 'gallery_shell.dart';
import 'pages/accessibility_page.dart';
import 'pages/action_sheets_page.dart';
import 'pages/alerts_page.dart';
import 'pages/buttons_page.dart';
import 'pages/form_controls_page.dart';
import 'pages/layout_page.dart';
import 'pages/lists_page.dart';
import 'pages/materials_pack_page.dart';
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
  GalleryPreviewFrame _frame = GalleryPreviewFrame.window;
  GalleryPreviewOrientation? _orientation;
  bool _swapOrientation = false;
  GalleryBackground _background = GalleryBackground.canvas;
  Wave1cPanel _wave1cPanel = Wave1cPanel.segmented;
  ThemesPanel _themesPanel = ThemesPanel.colors;

  /// Captured before [bindGalleryFramePlatform] so later rebuilds do not
  /// bake the board's override into the shell [ThemeData]. The device stage
  /// sets [Theme.platform] for the clipped demo.
  late final TargetPlatform _hostPlatform;

  @override
  void initState() {
    super.initState();
    _hostPlatform = defaultTargetPlatform;
    _apply(widget.launch ?? GalleryLaunch.fromUri(Uri.base));
  }

  @override
  void dispose() {
    bindGalleryFramePlatform(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(LingyunGlassDemoApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    final launch = widget.launch;
    if (launch != null && launch != oldWidget.launch) {
      _apply(launch);
    }
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
    _reduceTransparency = launch.reduceTransparency;
    _frame = launch.device;
    _orientation = launch.orientation;
    _swapOrientation = launch.swapOrientation;
    _background = GalleryBackground.fromQuery(launch.background);
    bindGalleryFramePlatform(_frame.platform);
  }

  void _setFrame(GalleryPreviewFrame frame) {
    bindGalleryFramePlatform(frame.platform);
    setState(() => _frame = frame);
  }

  void _setOrientation(GalleryPreviewOrientation orientation) {
    setState(() {
      _orientation = orientation;
      _swapOrientation = false;
    });
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
      'materials-pack' => MaterialsPackPage(
        initialSection: MaterialsPackSection.fromQuery(_launch.page),
      ),
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
        platform: _hostPlatform,
        colorSchemeSeed: const Color(0xFF6B7C93),
        extensions: const [LiquidGlassTheme.light],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        platform: _hostPlatform,
        colorSchemeSeed: const Color(0xFF6B7C93),
        extensions: const [LiquidGlassTheme.dark],
      ),
      home: GalleryBackgroundScope(
        mode: _background,
        child: LingyunAdaptivity(
          reduceTransparency: _reduceTransparency,
          reduceMotion: _reduceMotion,
          highContrast: _highContrast,
          child: GalleryShell(
            initialPage: _launch.page,
            initialHome: _launch.home,
            initialTab: _launch.tab,
            bare: _launch.bare,
            background: _background,
            onBackgroundChanged: (mode) => setState(() => _background = mode),
            themeMode: _themeMode,
            onThemeModeChanged: _setThemeMode,
            reduceTransparency: _reduceTransparency,
            onReduceTransparency: (value) =>
                setState(() => _reduceTransparency = value),
            frame: _frame,
            onFrameChanged: _setFrame,
            orientation: _orientation,
            swapOrientation: _swapOrientation,
            onOrientationChanged: _setOrientation,
            pageBuilder: _page,
          ),
        ),
      ),
    );
  }
}
