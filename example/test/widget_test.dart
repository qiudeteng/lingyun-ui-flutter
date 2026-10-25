import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/foundation_app.dart';
import 'package:example/gallery_catalog.dart';
import 'package:example/gallery_preview.dart';
import 'package:example/main.dart';
import 'package:example/pages/form_controls_page.dart';
import 'package:example/pages/materials_pack_page.dart';
import 'package:example/pages/wave1c_page.dart';
import 'package:example/pages/native_page.dart';
import 'package:example/wallpaper.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Page scroller inside the pushed demo, not the workbench list.
Finder galleryContentScrollable() {
  return find
      .descendant(
        of: find.byKey(const Key('gallery-body')),
        matching: find.byType(Scrollable),
      )
      .first;
}

/// Scrolls [finder] into the band above the Dock.
///
/// The floating tab bar's top padding does not hit-test, and a control
/// whose center sits in that band is laid out but cannot be tapped.
/// [Scrollable.ensureVisible] treats a barely revealed sliver as done.
Future<void> revealGalleryTarget(WidgetTester tester, Finder finder) async {
  final state = tester.state<ScrollableState>(galleryContentScrollable());
  final screen = tester.view.physicalSize.height / tester.view.devicePixelRatio;
  const topInset = 72.0;
  const bottomInset = 120.0;
  for (var i = 0; i < 24; i++) {
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      final rect = tester.getRect(finder);
      if (rect.top >= topInset &&
          rect.bottom <= screen - bottomInset &&
          rect.height > 0) {
        return;
      }
      final down = rect.top < topInset;
      final current = state.position.pixels;
      final delta = down ? -160.0 : 160.0;
      final target = (current + delta).clamp(
        state.position.minScrollExtent,
        state.position.maxScrollExtent,
      );
      if (target == current) return;
      state.position.jumpTo(target);
      continue;
    }
    final current = state.position.pixels;
    final target = (current + 320).clamp(
      state.position.minScrollExtent,
      state.position.maxScrollExtent,
    );
    if (target == current) break;
    state.position.jumpTo(target);
  }
  expect(finder, findsOneWidget);
}

/// Tops increase down the page. Off-screen children of a single scroll
/// view are still laid out, so this does not require them to be visible.
void _expectTopsIncrease(WidgetTester tester, List<Key> keys) {
  double? previous;
  for (final key in keys) {
    final top = tester.getRect(find.byKey(key)).top;
    if (previous != null) {
      expect(top, greaterThan(previous), reason: '$key');
    }
    previous = top;
  }
}

/// [Scrollable.ensureVisible] with alignment 0 puts the section title on
/// the leading edge of the demo scroller.
void _expectSectionAtTop(WidgetTester tester, Key key) {
  final viewport = tester.getRect(galleryContentScrollable());
  final title = tester.getRect(find.byKey(key));
  expect((title.top - viewport.top).abs(), lessThan(24), reason: '$key');
}

/// Opens a demo from its group tab and workbench list row.
///
/// [settle] stays false for the progress page, whose indeterminate
/// indicator never goes idle.
Future<void> openGalleryEntry(
  WidgetTester tester,
  String entryId, {
  bool settle = true,
}) async {
  final selection = resolveGallerySelection(entryId);
  expect(selection, isNotNull);
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('lingyun-page-tab-bar')),
      matching: find.text(selection!.group.label),
    ),
  );
  await tester.pumpAndSettle();
  final card = find.byKey(Key('gallery-entry-${selection.entry.id}'));
  await tester.ensureVisible(card);
  await tester.tap(card);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// Every workbench section list is inset Materials Regular.
///
/// The four group tabs share [GalleryWorkbench]. [backgroundArgb] is the
/// system grouped background for the current brightness.
Future<void> _expectWorkbenchLists(
  WidgetTester tester,
  int backgroundArgb,
) async {
  for (final group in galleryGroups) {
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('lingyun-page-tab-bar')),
        matching: find.text(group.label),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-workbench-title')))
          .data,
      group.workbenchTitle,
    );
    expect(
      tester
          .widget<ColoredBox>(
            find.byKey(const Key('gallery-workbench-background')),
          )
          .color
          .toARGB32(),
      backgroundArgb,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('gallery-workbench')),
        matching: find.byType(GlassCard),
      ),
      findsNothing,
    );
    for (final section in group.sections) {
      expect(find.byKey(Key('gallery-section-${section.id}')), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(Key('gallery-card-label-${section.id}')))
            .data,
        group.workbenchTitle,
      );
      final list = tester.widget<GlassList>(
        find.byKey(Key('gallery-card-${section.id}')),
      );
      expect(list.style, GlassListStyle.inset);
      final surfaces = tester.widgetList<GlassSurface>(
        find.descendant(
          of: find.byKey(Key('gallery-card-${section.id}')),
          matching: find.byType(GlassSurface),
        ),
      );
      expect(surfaces, hasLength(1));
      expect(surfaces.single.material, MaterialTier.regular);
      expect(surfaces.single.style, isNull);
      expect(surfaces.single.tokens, isNull);
    }
  }
}

void main() {
  testWidgets('gallery boots on the basics workbench', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('lingyun-page-sidebar')), findsNothing);
    expect(find.byKey(const Key('lingyun-page-tab-bar')), findsOneWidget);
    final tabs = tester.widget<GlassTabBar>(
      find.byKey(const Key('lingyun-page-tab-bar')),
    );
    expect(tabs.style, GlassTabBarStyle.floatingPill);
    expect(tabs.glassStyle, LiquidGlassStyle.dock);
    expect(tabs.items.map((item) => item.label).toList(), [
      '基础',
      '控件',
      '浮层',
      '导航壳',
    ]);
    expect(find.text('标签栏'), findsNothing);
    expect(find.byKey(const Key('gallery-workbench')), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-workbench-title')))
          .data,
      '基础工作台',
    );
    expect(find.text('点一行打开示例。'), findsOneWidget);
    expect(find.byKey(const Key('gallery-section-surface')), findsOneWidget);
    expect(
      find.byKey(const Key('gallery-section-presentation')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-card-label-surface')))
          .data,
      '基础工作台',
    );
    expect(
      find.byKey(const Key('gallery-entry-materials-pack')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('gallery-entry-materials')), findsNothing);
    expect(find.byKey(const Key('gallery-entry-glass')), findsNothing);
    expect(find.text('材质封装'), findsOneWidget);
    expect(find.text('液态玻璃'), findsNothing);
    expect(find.text('玻璃按钮'), findsWidgets);
    expect(find.byKey(const Key('materials-title')), findsNothing);

    await openGalleryEntry(tester, 'materials');
    expect(find.byKey(const Key('materials-pack-title')), findsOneWidget);
    expect(find.text('材质封装'), findsWidgets);
    expect(find.text('材质'), findsWidgets);
    expect(find.text('超薄'), findsWidgets);
    expect(find.text('厚'), findsWidgets);
    expect(find.byKey(const Key('controls-title')), findsOneWidget);
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    expect(find.byKey(const Key('materials-title')), findsOneWidget);
    expect(find.byKey(const Key('materials-thick-note')), findsOneWidget);
    expect(find.textContaining('Sheet'), findsWidgets);
    expect(find.textContaining('Sidebar'), findsWidgets);
    expect(find.byKey(const Key('knob-light-idle')), findsOneWidget);
    expect(find.byKey(const Key('knob-light-clicked')), findsOneWidget);
    expect(find.byKey(const Key('knob-dark-idle-missing')), findsOneWidget);
    expect(find.byKey(const Key('knob-dark-clicked')), findsOneWidget);
    expect(find.byKey(const Key('track-light-filled-idle')), findsOneWidget);
    expect(
      find.byKey(const Key('track-dark-unfilled-disabled')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('slider-idle')), findsNothing);
    expect(find.byType(GlassButton), findsNothing);
    expect(find.textContaining('模糊'), findsNothing);
    expect(find.textContaining('饱和'), findsNothing);
    _expectTopsIncrease(tester, const [
      Key('controls-title'),
      Key('glass-title'),
      Key('materials-title'),
      Key('material-light-thick'),
      Key('material-light-regular'),
      Key('material-light-thin'),
      Key('material-light-ultrathin'),
    ]);
    _expectTopsIncrease(tester, const [
      Key('material-dark-thick'),
      Key('material-dark-regular'),
      Key('material-dark-thin'),
      Key('material-dark-ultrathin'),
    ]);
    await tester.scrollUntilVisible(
      find.byKey(const Key('radius-large')),
      200,
      scrollable: galleryContentScrollable(),
    );
    expect(find.byKey(const Key('radius-small')), findsOneWidget);
    expect(find.byKey(const Key('radius-medium')), findsOneWidget);
    expect(find.byKey(const Key('radius-large')), findsOneWidget);
  });

  testWidgets('workbench lists use materials regular, not liquid glass', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await _expectWorkbenchLists(tester, 0xFFF2F2F7);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 2200);
    await tester.pumpWidget(
      const LingyunGlassDemoApp(launch: GalleryLaunch(theme: 'dark')),
    );
    await tester.pumpAndSettle();
    await _expectWorkbenchLists(tester, 0xFF000000);
  });

  testWidgets('gallery can open Glass, Layout and Accessibility', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'glass');
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    expect(find.byKey(const Key('glass-light-clear')), findsOneWidget);
    expect(find.byKey(const Key('glass-dark-clear')), findsOneWidget);
    expect(find.byKey(const Key('glass-light-regularSmall')), findsOneWidget);
    expect(find.byKey(const Key('glass-light-regularMedium')), findsOneWidget);
    expect(find.byKey(const Key('glass-light-regularLarge')), findsOneWidget);
    expect(find.byKey(const Key('glass-light-dock')), findsOneWidget);
    expect(find.byKey(const Key('glass-dark-dock')), findsOneWidget);
    expect(find.byKey(const Key('glass-light-widgetGlass')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-default')), findsNothing);
    expect(find.text('常规小'), findsWidgets);

    await openGalleryEntry(tester, 'layout');
    expect(find.byKey(const Key('layout-title')), findsOneWidget);
    expect(find.byKey(const Key('preset-regular')), findsOneWidget);
    expect(find.byKey(const Key('layout-class-label')), findsOneWidget);
    expect(find.textContaining('常规 · 侧栏'), findsOneWidget);

    await tester.tap(find.byKey(const Key('preset-compact')));
    await tester.pumpAndSettle();
    expect(find.textContaining('紧凑 · 标签'), findsOneWidget);

    await tester.tap(find.byKey(const Key('preset-wide')));
    await tester.pumpAndSettle();
    expect(find.textContaining('宽屏 · 侧栏'), findsOneWidget);

    await openGalleryEntry(tester, 'tabs');
    expect(find.byKey(const Key('tab-bar-title')), findsOneWidget);
    final rootTabs = tester.widget<GlassTabBar>(
      find.byKey(const Key('lingyun-page-tab-bar')),
    );
    expect(rootTabs.items.map((item) => item.label), isNot(contains('标签栏')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('tab-stage-tinted')),
      300,
      scrollable: galleryContentScrollable(),
    );
    expect(find.byKey(const Key('tab-stage-standard')), findsOneWidget);
    expect(find.byKey(const Key('tab-stage-floating-3')), findsOneWidget);
    expect(find.byKey(const Key('tab-stage-floating-4')), findsOneWidget);
    expect(find.byKey(const Key('tab-stage-floating-5')), findsOneWidget);
    expect(find.byKey(const Key('tab-stage-tinted')), findsOneWidget);
    expect(find.textContaining('系统蓝'), findsWidgets);

    await openGalleryEntry(tester, 'access');
    expect(find.byKey(const Key('a11y-title')), findsOneWidget);
    expect(find.text('降低透明度'), findsNWidgets(2));
    expect(find.text('减弱动态'), findsOneWidget);
  });

  testWidgets('native page lists compact and regular skeletons', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NativePage())),
    );
    expect(find.byKey(const Key('native-page-title')), findsOneWidget);
    expect(find.byKey(const Key('native-page-compact-note')), findsOneWidget);
    expect(find.byKey(const Key('native-page-regular-note')), findsOneWidget);
    expect(find.byKey(const Key('native-page-placeholder')), findsOneWidget);
    expect(find.byKey(const Key('native-page-host')), findsOneWidget);

    final arrangement = find.byKey(
      const Key('native-navigation-arrangementSplit'),
    );
    await tester.ensureVisible(arrangement);
    await tester.tap(arrangement);
    await tester.pump();
    expect(find.textContaining('ArrangementView'), findsWidgets);
  });

  test('unknown bg query falls back to the design canvas', () {
    expect(GalleryBackground.fromQuery(null), GalleryBackground.canvas);
    expect(GalleryBackground.fromQuery('meadow'), GalleryBackground.meadow);
    expect(GalleryBackground.fromQuery('nope'), GalleryBackground.canvas);
    expect(GalleryCanvasColors.light, const Color(0xFFD1D1D6));
    expect(GalleryCanvasColors.dark, const Color(0xFF000000));
  });

  testWidgets('background control stays across tabs', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());

    expect(find.byKey(const Key('gallery-bg-control')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-canvas')), findsOneWidget);
    final canvas = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byKey(const Key('gallery-bg-canvas')),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(canvas.color, GalleryCanvasColors.light);

    await tester.tap(find.byKey(const Key('gallery-bg-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('gallery-bg-option-meadow')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gallery-bg-meadow')), findsOneWidget);

    await openGalleryEntry(tester, 'glass');
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-meadow')), findsOneWidget);

    await openGalleryEntry(tester, 'tabs');
    expect(find.byKey(const Key('tab-bar-title')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-meadow')), findsWidgets);
  });

  testWidgets('alerts page shows system dialog states', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'alerts');

    expect(find.byKey(const Key('alert-title')), findsOneWidget);
    expect(find.text('提示'), findsWidgets);
    expect(find.byKey(const Key('alert-stage-single')), findsOneWidget);
    expect(find.byKey(const Key('alert-stage-dual')), findsOneWidget);
    expect(find.byKey(const Key('alert-stage-destructive')), findsOneWidget);
    expect(find.byKey(const Key('alert-stage-title-message')), findsOneWidget);
    expect(find.byKey(const Key('alert-stage-message-only')), findsOneWidget);

    final dual = find.byKey(const Key('alert-stage-dual'));
    final cancel = find.descendant(of: dual, matching: find.text('取消'));
    final confirm = find.descendant(of: dual, matching: find.text('确认'));
    expect(tester.getRect(cancel).left, lessThan(tester.getRect(confirm).left));

    expect(find.textContaining('尚未弹出'), findsOneWidget);
    await revealGalleryTarget(
      tester,
      find.byKey(const Key('alert-live-single')),
    );
    await tester.tap(find.byKey(const Key('alert-live-single')));
    await tester.pumpAndSettle();
    expect(find.text('已保存'), findsWidgets);
    await tester.tap(find.text('好').last);
    await tester.pumpAndSettle();
    expect(find.text('实时路由 · 上次结果：好'), findsOneWidget);
  });

  testWidgets('sheets page is Chinese and can open a thick sheet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'sheets');

    expect(find.byKey(const Key('sheet-title')), findsOneWidget);
    expect(find.byKey(const Key('sheet-thick-note')), findsOneWidget);
    expect(find.textContaining('Materials Thick'), findsOneWidget);
    expect(find.byKey(const Key('sheet-stage-compact-medium')), findsOneWidget);
    expect(find.byKey(const Key('sheet-stage-compact-large')), findsOneWidget);
    expect(find.byKey(const Key('sheet-stage-wide')), findsOneWidget);
    expect(find.text('浅色'), findsWidgets);
    expect(find.text('深色'), findsWidgets);

    await tester.tap(find.byKey(const Key('sheet-theme-dark')));
    await tester.pumpAndSettle();
    final title = tester.element(find.byKey(const Key('sheet-title')));
    expect(Theme.of(title).brightness, Brightness.dark);

    await tester.tap(find.byKey(const Key('sheet-theme-light')));
    await tester.pumpAndSettle();

    expect(find.textContaining('尚未弹出'), findsOneWidget);
    await revealGalleryTarget(
      tester,
      find.byKey(const Key('sheet-open-window')),
    );
    await tester.tap(find.byKey(const Key('sheet-open-window')));
    await tester.pumpAndSettle();
    expect(find.text('编辑项目'), findsWidgets);
    await tester.tap(find.text('完成').last);
    await tester.pumpAndSettle();
    tester
        .state<ScrollableState>(galleryContentScrollable())
        .position
        .jumpTo(0);
    await tester.pump();
    expect(find.textContaining('上次结果：完成'), findsOneWidget);
  });

  testWidgets('action sheets page is Chinese and can open a system sheet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'actions');

    expect(find.byKey(const Key('action-sheet-title')), findsOneWidget);
    expect(find.byKey(const Key('action-sheet-scope')), findsOneWidget);
    expect(find.textContaining('系统操作表'), findsOneWidget);
    expect(find.byKey(const Key('action-sheet-stage-titled')), findsOneWidget);
    expect(
      find.byKey(const Key('action-sheet-stage-destructive')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('action-sheet-stage-several')), findsOneWidget);
    expect(find.byKey(const Key('action-sheet-stage-plain')), findsOneWidget);

    final several = find.byKey(const Key('action-sheet-stage-several'));
    double topOf(String label) {
      return tester
          .getRect(find.descendant(of: several, matching: find.text(label)))
          .top;
    }

    expect(topOf('拷贝'), lessThan(topOf('存储')));
    expect(topOf('存储'), lessThan(topOf('删除')));
    expect(topOf('删除'), lessThan(topOf('取消')));

    await tester.scrollUntilVisible(
      find.byKey(const Key('action-sheet-live-plain')),
      400,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('action-sheet-gallery-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.textContaining('尚未弹出'), findsOneWidget);
    await tester.tap(find.byKey(const Key('action-sheet-live-plain')));
    await tester.pumpAndSettle();
    expect(find.text('打开'), findsWidgets);
    await tester.tap(find.text('打开').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('上次结果：打开'), findsOneWidget);
  });

  testWidgets('popovers page is Chinese and can open, press, and dismiss', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'popovers');

    expect(find.byKey(const Key('popover-title')), findsOneWidget);
    expect(find.byKey(const Key('popover-motion-note')), findsOneWidget);
    expect(find.textContaining('Regular Medium'), findsOneWidget);
    expect(find.byKey(const Key('popover-stage-below')), findsOneWidget);
    expect(find.byKey(const Key('popover-stage-above')), findsOneWidget);
    expect(find.byKey(const Key('popover-stage-after')), findsOneWidget);
    expect(find.byKey(const Key('popover-stage-pressed')), findsOneWidget);
    expect(find.text('浅色'), findsWidgets);
    expect(find.text('深色'), findsWidgets);

    await tester.tap(find.byKey(const Key('popover-theme-dark')));
    await tester.pumpAndSettle();
    final title = tester.element(find.byKey(const Key('popover-title')));
    expect(Theme.of(title).brightness, Brightness.dark);
    await tester.tap(find.byKey(const Key('popover-theme-light')));
    await tester.pumpAndSettle();

    expect(find.textContaining('尚未弹出'), findsOneWidget);
    await tester.tap(find.byKey(const Key('popover-open')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('popover-action-detail')), findsOneWidget);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('popover-action-detail'))),
    );
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.textContaining('上次结果：查看详情'), findsOneWidget);

    await tester.tap(find.byKey(const Key('popover-open')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(24, 860));
    await tester.pumpAndSettle();
    expect(find.textContaining('上次结果：已关闭'), findsOneWidget);
  });

  testWidgets('menus page is Chinese and can open a glass menu', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'menus');

    expect(find.byKey(const Key('menu-title')), findsOneWidget);
    expect(find.byKey(const Key('menu-scope')), findsOneWidget);
    expect(find.textContaining('Regular Large'), findsOneWidget);
    expect(find.text('浅色'), findsWidgets);
    expect(find.text('深色'), findsWidgets);
    expect(find.byKey(const Key('menu-stage-grouped')), findsOneWidget);
    expect(find.byKey(const Key('menu-stage-pressed')), findsOneWidget);
    expect(find.textContaining('尚未弹出'), findsOneWidget);

    await tester.tap(find.byKey(const Key('menu-open')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lingyun-menu-action-0')), findsOneWidget);
    await tester.tap(find.byKey(const Key('lingyun-menu-action-2')));
    await tester.pumpAndSettle();
    expect(find.textContaining('上次结果：删除'), findsOneWidget);
  });

  testWidgets('foundation gallery shows colors and text styles', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const FoundationGallery(showChrome: false));
    expect(find.byKey(const Key('colors-title')), findsOneWidget);
    expect(find.text('液态玻璃标签'), findsOneWidget);
    expect(find.text('系统颜色'), findsOneWidget);
    expect(find.text('System Colors'), findsNothing);
    expect(find.text('Colors'), findsNothing);
    expect(find.text('#1A1A1A'), findsWidgets);
    expect(find.text('#0088FF'), findsWidgets);

    await tester.pumpWidget(
      const FoundationGallery(
        initialPage: FoundationPage.text,
        initialBrightness: Brightness.dark,
        showChrome: false,
      ),
    );
    expect(find.byKey(const Key('text-styles-title')), findsOneWidget);
    expect(find.byKey(const Key('text-role-body')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('text-role-caption1')),
      300,
    );
    expect(find.byKey(const Key('text-role-caption1')), findsOneWidget);
  });

  testWidgets('themes page opens color swatches and text styles', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'themes');

    expect(find.byKey(const Key('themes-title')), findsOneWidget);
    expect(find.byKey(const Key('colors-title')), findsOneWidget);
    expect(find.text('系统颜色'), findsOneWidget);
    expect(find.text('#0088FF'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('液态玻璃标签'),
      400,
      scrollable: galleryContentScrollable(),
    );
    expect(find.text('液态玻璃标签'), findsOneWidget);
    tester
        .state<ScrollableState>(galleryContentScrollable())
        .position
        .jumpTo(0);
    await tester.pump();
    expect(find.text('Themes'), findsNothing);
    expect(find.text('Dark mode'), findsNothing);
    expect(find.text('Materials Thin'), findsNothing);

    await tester.tap(find.text('深色').last);
    await tester.pumpAndSettle();
    expect(find.text('#0091FF'), findsWidgets);

    await tester.tap(find.text('文本').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('text-styles-title')), findsOneWidget);
    expect(find.text('凌云界面'), findsWidgets);
    expect(find.textContaining('大标题'), findsWidgets);
  });

  test('materials pack queries map onto the three sections', () {
    expect(MaterialsPackSection.fromQuery('materials-pack'), isNull);
    expect(MaterialsPackSection.fromQuery(null), isNull);
    expect(MaterialsPackSection.fromQuery('buttons'), isNull);
    expect(
      MaterialsPackSection.fromQuery('knob'),
      MaterialsPackSection.controls,
    );
    expect(
      MaterialsPackSection.fromQuery('controls'),
      MaterialsPackSection.controls,
    );
    expect(
      MaterialsPackSection.fromQuery('track'),
      MaterialsPackSection.controls,
    );
    expect(
      MaterialsPackSection.fromQuery('glass'),
      MaterialsPackSection.liquidGlass,
    );
    expect(
      MaterialsPackSection.fromQuery('materials'),
      MaterialsPackSection.materials,
    );
  });

  testWidgets('materials pack deep links land on the matching section', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Future<void> open(GalleryLaunch launch) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(LingyunGlassDemoApp(launch: launch));
      await tester.pumpAndSettle();
    }

    await open(const GalleryLaunch(home: 'controls'));
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-workbench-title')))
          .data,
      '控件工作台',
    );
    expect(find.byKey(const Key('gallery-entry-knob')), findsNothing);
    expect(find.byKey(const Key('gallery-section-track')), findsNothing);
    expect(find.text('旋钮与轨道'), findsNothing);
    expect(find.byKey(const Key('gallery-entry-lists')), findsOneWidget);

    await open(const GalleryLaunch(page: 'materials-pack', chrome: '0'));
    expect(find.byKey(const Key('materials-pack-title')), findsOneWidget);
    expect(
      tester.state<ScrollableState>(galleryContentScrollable()).position.pixels,
      0,
    );
    expect(find.byType(GlassButton), findsNothing);

    await open(const GalleryLaunch(page: 'materials', chrome: '0'));
    _expectSectionAtTop(tester, const Key('materials-title'));

    await open(const GalleryLaunch(page: 'glass', chrome: '0'));
    _expectSectionAtTop(tester, const Key('glass-title'));

    for (final page in ['knob', 'controls', 'track']) {
      await open(GalleryLaunch(page: page, chrome: '0'));
      _expectSectionAtTop(tester, const Key('controls-title'));
    }
  });

  testWidgets('form gallery pages use Simplified Chinese copy', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());

    await openGalleryEntry(tester, 'lists');
    expect(find.byKey(const Key('lists-title')), findsOneWidget);
    expect(find.text('无线局域网'), findsOneWidget);
    expect(find.text('设计评审'), findsOneWidget);
    expect(find.text('Lists'), findsNothing);
    expect(find.textContaining('液态玻璃托盘'), findsNothing);
    expect(find.textContaining('常规材质'), findsWidgets);
    final pageBackground = tester.widget<ColoredBox>(
      find.byKey(const Key('lists-page-background')),
    );
    expect(pageBackground.color.toARGB32(), 0xFFF2F2F7);
    final insetSurfaces = tester.widgetList<GlassSurface>(
      find.descendant(
        of: find.byKey(const Key('lists-inset')),
        matching: find.byType(GlassSurface),
      ),
    );
    expect(insetSurfaces, hasLength(2));
    for (final surface in insetSurfaces) {
      expect(surface.material, MaterialTier.regular);
      expect(surface.style, isNull);
      expect(surface.tokens, isNull);
    }
    expect(
      find.descendant(
        of: find.byKey(const Key('lists-plain')),
        matching: find.byType(GlassSurface),
      ),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(page: 'lists', theme: 'dark', chrome: '0'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('无线局域网'), findsOneWidget);
    expect(find.textContaining('液态玻璃托盘'), findsNothing);
    final darkBackground = tester.widget<ColoredBox>(
      find.byKey(const Key('lists-page-background')),
    );
    expect(darkBackground.color.toARGB32(), 0xFF000000);
    final darkSurfaces = tester.widgetList<GlassSurface>(
      find.descendant(
        of: find.byKey(const Key('lists-inset')),
        matching: find.byType(GlassSurface),
      ),
    );
    expect(darkSurfaces, isNotEmpty);
    for (final surface in darkSurfaces) {
      expect(surface.material, MaterialTier.regular);
      expect(surface.style, isNull);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'fields');
    expect(find.byKey(const Key('fields-title')), findsOneWidget);
    expect(find.text('显示名称'), findsOneWidget);
    expect(find.text('请输入有效的电子邮件'), findsOneWidget);
    expect(find.text('Text Fields'), findsNothing);

    await openGalleryEntry(tester, 'progress', settle: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('progress-title')), findsOneWidget);
    expect(find.text('不确定'), findsWidgets);
    expect(find.text('圆形着色'), findsOneWidget);
    expect(find.text('Progress Indicators'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  test('form control query opens toggles, sliders, or steppers', () {
    expect(FormControlPanel.fromQuery('toggles'), FormControlPanel.toggles);
    expect(FormControlPanel.fromQuery('toggle'), FormControlPanel.toggles);
    expect(FormControlPanel.fromQuery('sliders'), FormControlPanel.sliders);
    expect(FormControlPanel.fromQuery('slider'), FormControlPanel.sliders);
    expect(FormControlPanel.fromQuery('steppers'), FormControlPanel.steppers);
    expect(FormControlPanel.fromQuery('stepper'), FormControlPanel.steppers);
    expect(FormControlPanel.fromQuery('knob'), isNull);
    expect(FormControlPanel.fromQuery(null), isNull);
  });

  testWidgets('toggle slider and stepper page covers the pinned states', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'toggles');

    expect(find.byKey(const Key('form-controls-title')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('form-controls-title'))).data,
      '开关',
    );
    expect(find.byKey(const Key('toggle-off-idle')), findsOneWidget);
    expect(find.byKey(const Key('toggle-on-idle')), findsOneWidget);
    expect(find.byKey(const Key('toggle-off-pressed')), findsOneWidget);
    expect(find.byKey(const Key('toggle-on-pressed')), findsOneWidget);
    expect(find.byKey(const Key('toggle-off-disabled')), findsOneWidget);
    expect(find.byKey(const Key('toggle-on-disabled')), findsOneWidget);
    expect(find.textContaining('不是材质四档'), findsOneWidget);
    expect(find.textContaining('#0088FF'), findsWidgets);

    final onKnob = find.descendant(
      of: find.byKey(const Key('toggle-on-idle')),
      matching: find.byType(ControlKnobStack),
    );
    final offPressed = find.descendant(
      of: find.byKey(const Key('toggle-off-pressed')),
      matching: find.byType(ControlKnobStack),
    );
    expect(onKnob, findsOneWidget);
    expect(tester.getSize(onKnob), const Size(24, 24));
    expect(tester.widget<ControlKnobStack>(offPressed).clicked, isTrue);

    expect(find.text('实时：开'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toggle-live')));
    await tester.pumpAndSettle();
    expect(find.text('实时：关'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('form-controls-brightness')),
        matching: find.text('深色'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('toggle-on-idle')),
        matching: find.byType(ControlKnobStack),
      ),
      findsNothing,
    );
    expect(offPressed, findsOneWidget);
    expect(find.textContaining('#0091FF'), findsWidgets);

    await openGalleryEntry(tester, 'sliders');
    expect(find.byKey(const Key('slider-mid-idle')), findsOneWidget);
    expect(find.byKey(const Key('slider-mid-pressed')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('slider-mid-idle')),
        matching: find.byType(ControlKnobStack),
      ),
      findsNothing,
    );
    final pressedSlider = find.descendant(
      of: find.byKey(const Key('slider-mid-pressed')),
      matching: find.byType(ControlKnobStack),
    );
    expect(pressedSlider, findsOneWidget);
    expect(tester.widget<ControlKnobStack>(pressedSlider).clicked, isTrue);
    expect(tester.getSize(pressedSlider), const Size(24, 24));
    expect(find.byKey(const Key('slider-disabled')), findsOneWidget);
    expect(find.byKey(const Key('toggle-off-idle')), findsNothing);
    expect(find.text('实时：50%'), findsOneWidget);

    await openGalleryEntry(tester, 'steppers');
    expect(find.byKey(const Key('stepper-idle')), findsOneWidget);
    expect(find.byKey(const Key('stepper-decrement-pressed')), findsOneWidget);
    expect(find.byKey(const Key('stepper-increment-pressed')), findsOneWidget);
    expect(find.byKey(const Key('stepper-disabled')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('stepper-idle')),
        matching: find.byType(ControlKnobStack),
      ),
      findsNothing,
    );
    expect(find.text('实时：3。到 0 或到 8 时，对应一侧停用。'), findsOneWidget);

    final live = tester.getRect(find.byKey(const Key('stepper-live')));
    await tester.tapAt(Offset(live.right - 12, live.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('实时：4。到 0 或到 8 时，对应一侧停用。'), findsOneWidget);
  });

  test('wave 1c query opens segmented controls or page controls', () {
    expect(Wave1cPanel.fromQuery('segmented'), Wave1cPanel.segmented);
    expect(Wave1cPanel.fromQuery('segments'), Wave1cPanel.segmented);
    expect(Wave1cPanel.fromQuery('pages'), Wave1cPanel.pages);
    expect(Wave1cPanel.fromQuery('page-controls'), Wave1cPanel.pages);
    expect(Wave1cPanel.fromQuery('pagecontrol'), Wave1cPanel.pages);
    expect(Wave1cPanel.fromQuery('toggles'), isNull);
    expect(Wave1cPanel.fromQuery(null), isNull);
  });

  testWidgets('segmented and page gallery is Simplified Chinese', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'segmented');

    expect(find.byKey(const Key('wave1c-title')), findsOneWidget);
    expect(find.text('分段与页面控件'), findsOneWidget);
    expect(find.textContaining('不是厚材质'), findsWidgets);
    expect(find.text('Segmented'), findsNothing);
    expect(find.byKey(const Key('segmented-two')), findsOneWidget);
    expect(find.byKey(const Key('segmented-large')), findsOneWidget);
    expect(find.byKey(const Key('segmented-pressed')), findsOneWidget);
    expect(find.text('实时：左。点按后透镜滑过去。'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('segmented-live')),
        matching: find.text('中'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('实时：中。点按后透镜滑过去。'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('wave1c-panel')),
        matching: find.text('页点'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('不能点'), findsWidgets);
    expect(find.byKey(const Key('page-five')), findsOneWidget);
    expect(find.byKey(const Key('page-busy')), findsOneWidget);
    expect(find.byKey(const Key('page-five')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('page-five')),
        matching: find.byKey(LingyunPageControl.tapKey),
      ),
      findsNothing,
    );
    expect(find.text('Page Control'), findsNothing);
  });

  testWidgets('sidebar and toolbar pages are Chinese and move', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'sidebars');
    expect(find.byKey(const Key('sidebar-title')), findsOneWidget);
    expect(find.byKey(const Key('sidebar-thick-note')), findsOneWidget);
    expect(find.textContaining('Materials Thick'), findsWidgets);
    expect(find.byKey(const Key('sidebar-stage-light')), findsOneWidget);
    expect(find.byKey(const Key('sidebar-stage-dark')), findsOneWidget);
    expect(find.text('浅色'), findsWidgets);
    expect(find.text('深色'), findsWidgets);

    await revealGalleryTarget(tester, find.byKey(const Key('sidebar-live')));
    await tester.tap(find.byKey(const Key('sidebar-live-inbox')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sidebar-live-selection')), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('sidebar-live')),
        matching: find.byIcon(Icons.menu),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final mid = tester
        .getSize(find.byKey(const Key('lingyun-sidebar-column')))
        .width;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(LingyunSidebarMetrics.preferredWidth));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const Key('lingyun-sidebar-column'))).width,
      0,
    );

    await revealGalleryTarget(
      tester,
      find.byKey(const Key('sidebar-rail-toggle')),
    );
    final bar = tester.widget<GlassTabBar>(
      find.byKey(const Key('sidebar-rail-bar')),
    );
    expect(bar.style, GlassTabBarStyle.floatingPill);
    expect(bar.glassStyle, LiquidGlassStyle.dock);
    await tester.tap(find.byKey(const Key('sidebar-rail-toggle')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<GlassTabBar>(find.byKey(const Key('sidebar-rail-bar')))
          .style,
      GlassTabBarStyle.sidebar,
    );
    expect(
      tester
          .widget<GlassTabBar>(find.byKey(const Key('sidebar-rail-bar')))
          .glassStyle,
      LiquidGlassStyle.dock,
    );

    await openGalleryEntry(tester, 'toolbars');
    expect(find.byKey(const Key('toolbar-title')), findsOneWidget);
    expect(find.byKey(const Key('toolbar-glass-note')), findsOneWidget);
    expect(find.textContaining('Regular Medium'), findsOneWidget);
    expect(find.byKey(const Key('toolbar-stage-light')), findsOneWidget);
    expect(find.byKey(const Key('toolbar-stage-dark')), findsOneWidget);
    await revealGalleryTarget(
      tester,
      find.byKey(const Key('toolbar-live-share')),
    );
    expect(find.text('已分享 0 次'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toolbar-live-share')));
    await tester.pumpAndSettle();
    expect(find.text('已分享 1 次'), findsOneWidget);
  });

  test('gallery page ids stay unique and grouped', () {
    final seen = <String>{};
    expect(galleryGroups.map((group) => group.label).toList(), [
      '基础',
      '控件',
      '浮层',
      '导航壳',
    ]);
    expect(galleryGroups.map((group) => group.homeKey).toList(), [
      'foundation',
      'controls',
      'overlays',
      'chrome',
    ]);
    for (final group in galleryGroups) {
      expect(group.sections.length, greaterThanOrEqualTo(2));
      expect(group.workbenchTitle, '${group.label}工作台');
      for (final entry in group.entries) {
        expect(entry.queries, contains(entry.id));
        for (final query in entry.queries) {
          expect(seen.add(query), isTrue, reason: query);
          expect(resolveGallerySelection(query)?.entry.id, entry.id);
        }
      }
    }
    expect(resolveGallerySelection(null), isNull);
    expect(resolveGallerySelection('nope'), isNull);
    expect(resolveGallerySelection('button')?.entry.id, 'buttons');
    expect(resolveGallerySelection('buttons')?.group.id, 'basics');
    expect(resolveGallerySelection('buttons')?.entry.label, '玻璃按钮');
    expect(resolveGallerySelection('glass')?.entry.label, '材质封装');
    expect(resolveGallerySelection('glass')?.entry.id, 'materials-pack');
    expect(resolveGallerySelection('knob')?.entry.label, '材质封装');
    expect(resolveGallerySelection('knob')?.group.id, 'basics');
    expect(resolveGallerySelection('materials')?.entry.id, 'materials-pack');
    expect(resolveGallerySelection('track')?.entry.id, 'materials-pack');
    expect(resolveGallerySelection('segmented')?.entry.label, '分段与页控');
    expect(resolveGallerySelection('toggle')?.entry.id, 'toggles');
    expect(resolveGallerySelection('slider')?.entry.id, 'sliders');
    expect(resolveGallerySelection('stepper')?.entry.id, 'steppers');
    expect(resolveGallerySelection('pages')?.entry.id, 'segmented');
    expect(resolveGallerySelection('controls')?.entry.id, 'materials-pack');
    expect(resolveGalleryWorkbench('controls')?.id, 'controls');
    expect(resolveGalleryWorkbench('foundation')?.label, '基础');
    expect(resolveGalleryWorkbench('chrome')?.label, '导航壳');
    expect(resolveGalleryWorkbench('tabs'), isNull);
  });

  test('launch reads page, theme, chrome, bg, a11y, and device', () {
    final launch = GalleryLaunch.fromUri(
      Uri.parse(
        'https://example.test/?page=text&theme=dark&chrome=0&bg=meadow&panel=samples'
        '&reduceTransparency=1&device=pro',
      ),
    );
    expect(launch.page, 'text');
    expect(launch.themesPanel, 'text');
    expect(launch.bare, isTrue);
    expect(launch.themeMode, ThemeMode.dark);
    expect(launch.background, 'meadow');
    expect(launch.reduceTransparency, isTrue);
    expect(launch.device, GalleryPreviewFrame.pro);
    expect(launch.device.logicalSize, const Size(402, 874));

    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?theme=light'))
          .themeMode,
      ThemeMode.light,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?theme=DARK'))
          .themeMode,
      ThemeMode.dark,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?theme=system'))
          .themeMode,
      ThemeMode.system,
    );
    expect(
      GalleryLaunch.fromUri(
        Uri.parse('https://example.test/?a11y=reduceTransparency'),
      ).reduceTransparency,
      isTrue,
    );
    expect(
      GalleryLaunch.fromUri(
        Uri.parse('https://example.test/?a11y=reduce-transparency'),
      ).reduceTransparency,
      isTrue,
    );
    expect(
      GalleryLaunch.fromUri(
        Uri.parse('https://example.test/?reduceTransparency=0&a11y=1'),
      ).reduceTransparency,
      isFalse,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?a11y=off'))
          .reduceTransparency,
      isFalse,
    );
    expect(
      GalleryLaunch.fromUri(
        Uri.parse('https://example.test/?frame=duo-inner-portrait'),
      ).device,
      GalleryPreviewFrame.duoInnerPortrait,
    );
    expect(
      GalleryLaunch.fromUri(
        Uri.parse('https://example.test/?device=air&frame=pro'),
      ).device,
      GalleryPreviewFrame.air,
    );
    expect(
      GalleryLaunch.fromUri(
        Uri.parse('https://example.test/?device=nope&frame=440×956'),
      ).device,
      GalleryPreviewFrame.proMax,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?device=16-pro'))
          .device
          .logicalSize,
      const Size(402, 874),
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?frame=951x669'))
          .device,
      GalleryPreviewFrame.duoInnerLandscape,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?device=window'))
          .device
          .logicalSize,
      isNull,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?device=466x678'))
          .device,
      GalleryPreviewFrame.duoOuter,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?frame=420x912'))
          .device,
      GalleryPreviewFrame.air,
    );
    expect(GalleryPreviewFrame.pro.platform, TargetPlatform.iOS);
    expect(GalleryPreviewFrame.proMax.platform, TargetPlatform.iOS);
    expect(GalleryPreviewFrame.air.platform, TargetPlatform.iOS);
    expect(GalleryPreviewFrame.duoOuter.platform, TargetPlatform.iOS);
    expect(GalleryPreviewFrame.duoInnerLandscape.platform, TargetPlatform.iOS);
    expect(GalleryPreviewFrame.duoInnerPortrait.platform, TargetPlatform.iOS);
    expect(
      GalleryPreviewFrame.pro.safePadding,
      const EdgeInsets.only(top: 59, bottom: 34),
    );
    expect(
      GalleryPreviewFrame.duoOuter.safePadding,
      const EdgeInsets.only(top: 24, bottom: 12),
    );
    expect(GalleryPreviewFrame.window.platform, isNull);
    expect(GalleryPreviewFrame.window.safePadding, EdgeInsets.zero);
    expect(GalleryPreviewFrame.window.form, GalleryPreviewForm.window);

    expect(GalleryPreviewFrame.ipadMini.shortLabel, 'iPad mini');
    expect(GalleryPreviewFrame.ipadMini.label, 'iPad mini 744×1133');
    expect(GalleryPreviewFrame.ipadMini.logicalSize, const Size(744, 1133));
    expect(GalleryPreviewFrame.ipadMini.platform, TargetPlatform.iOS);
    expect(
      GalleryPreviewFrame.ipadMini.safePadding,
      const EdgeInsets.only(top: 24, bottom: 20),
    );
    expect(GalleryPreviewFrame.ipadAir11.shortLabel, 'iPad Air 11');
    expect(GalleryPreviewFrame.ipadAir11.label, 'iPad Air 11" 820×1180');
    expect(GalleryPreviewFrame.ipadAir11.logicalSize, const Size(820, 1180));
    expect(GalleryPreviewFrame.ipadPro11.label, 'iPad Pro 11" 834×1210');
    expect(GalleryPreviewFrame.ipadPro11.logicalSize, const Size(834, 1210));
    expect(GalleryPreviewFrame.ipadAir13.shortLabel, 'iPad Air 13');
    expect(GalleryPreviewFrame.ipadAir13.label, 'iPad Air 13" 1024×1366');
    expect(GalleryPreviewFrame.ipadPro13.shortLabel, 'iPad Pro 13');
    expect(GalleryPreviewFrame.ipadPro13.label, 'iPad Pro 13" 1032×1376');
    expect(GalleryPreviewFrame.ipadPro13.logicalSize, const Size(1032, 1376));
    expect(GalleryPreviewFrame.macos.shortLabel, 'macOS');
    expect(GalleryPreviewFrame.macos.label, 'macOS 1440×900');
    expect(GalleryPreviewFrame.macos.logicalSize, const Size(1440, 900));
    expect(GalleryPreviewFrame.macos.platform, TargetPlatform.macOS);
    expect(GalleryPreviewFrame.macos.safePadding, EdgeInsets.zero);
    expect(GalleryPreviewFrame.windows.shortLabel, 'Windows');
    expect(GalleryPreviewFrame.windows.label, 'Windows 1280×800');
    expect(GalleryPreviewFrame.windows.logicalSize, const Size(1280, 800));
    expect(GalleryPreviewFrame.windows.platform, TargetPlatform.windows);
    expect(GalleryPreviewFrame.windows.safePadding, EdgeInsets.zero);

    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?device=ipad-mini'))
          .device,
      GalleryPreviewFrame.ipadMini,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?device=ipadmini'))
          .device,
      GalleryPreviewFrame.ipadMini,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?frame=820×1180'))
          .device,
      GalleryPreviewFrame.ipadAir11,
    );
    expect(
      GalleryLaunch.fromUri(
        Uri.parse('https://example.test/?device=ipad-pro-11'),
      ).device,
      GalleryPreviewFrame.ipadPro11,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?device=air13'))
          .device,
      GalleryPreviewFrame.ipadAir13,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?frame=pro13'))
          .device,
      GalleryPreviewFrame.ipadPro13,
    );
    expect(
      GalleryLaunch.fromUri(
        Uri.parse('https://example.test/?device=macos&frame=pro'),
      ).device,
      GalleryPreviewFrame.macos,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?device=mac'))
          .device,
      GalleryPreviewFrame.macos,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?device=win'))
          .device,
      GalleryPreviewFrame.windows,
    );
    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?frame=1280x800'))
          .device,
      GalleryPreviewFrame.windows,
    );

    final home = GalleryLaunch.fromUri(
      Uri.parse('https://example.test/?home=controls'),
    );
    expect(home.page, isNull);
    expect(home.workbench?.id, 'controls');

    final tab = GalleryLaunch.fromUri(
      Uri.parse('https://example.test/?tab=chrome'),
    );
    expect(tab.workbench?.homeKey, 'chrome');

    final tabWins = GalleryLaunch.fromUri(
      Uri.parse('https://example.test/?home=foundation&tab=overlays'),
    );
    expect(tabWins.workbench?.id, 'overlays');

    final pageWins = GalleryLaunch.fromUri(
      Uri.parse('https://example.test/?page=menus&home=foundation'),
    );
    expect(pageWins.page, 'menus');
    expect(resolveGallerySelection(pageWins.page)?.entry.id, 'menus');

    expect(
      GalleryLaunch.fromUri(Uri.parse('https://example.test/?home=nope'))
          .workbench,
      isNull,
    );
  });

  testWidgets('home and tab queries open that workbench', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const LingyunGlassDemoApp(launch: GalleryLaunch(home: 'overlays')),
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-workbench-title')))
          .data,
      '浮层工作台',
    );
    expect(find.byKey(const Key('gallery-entry-alerts')), findsOneWidget);
    expect(find.byKey(const Key('alert-title')), findsNothing);
    final tabs = tester.widget<GlassTabBar>(
      find.byKey(const Key('lingyun-page-tab-bar')),
    );
    expect(tabs.currentIndex, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const LingyunGlassDemoApp(launch: GalleryLaunch(tab: 'chrome')),
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-workbench-title')))
          .data,
      '导航壳工作台',
    );
    expect(find.byKey(const Key('gallery-entry-tabs')), findsOneWidget);
    expect(find.byKey(const Key('tab-bar-title')), findsNothing);
    expect(
      tester
          .widget<GlassTabBar>(find.byKey(const Key('lingyun-page-tab-bar')))
          .items
          .map((item) => item.label),
      isNot(contains('标签栏')),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(page: 'glass', home: 'controls'),
      ),
    );
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('gallery-back')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-workbench-title')))
          .data,
      '基础工作台',
    );
  });

  testWidgets('deep link opens the demo and back returns to its workbench', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const LingyunGlassDemoApp(launch: GalleryLaunch(page: 'menus')),
    );
    expect(find.byKey(const Key('menu-title')), findsOneWidget);
    expect(find.byKey(const Key('gallery-workbench')), findsNothing);
    expect(find.byKey(const Key('lingyun-page-tab-bar')), findsOneWidget);
    expect(find.byKey(const Key('lingyun-page-sidebar')), findsNothing);

    await tester.tap(find.byKey(const Key('gallery-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('menu-title')), findsNothing);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-workbench-title')))
          .data,
      '浮层工作台',
    );
    expect(find.byKey(const Key('gallery-entry-menus')), findsOneWidget);
  });

  testWidgets('chrome theme and bg still hide the shell', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(
          page: 'button',
          theme: 'dark',
          chrome: '0',
          background: 'meadow',
        ),
      ),
    );
    expect(find.byKey(const Key('buttons-title')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-default')), findsOneWidget);
    expect(find.byKey(const Key('lingyun-page-tab-bar')), findsNothing);
    expect(find.byKey(const Key('gallery-back')), findsNothing);
    expect(find.byKey(const Key('gallery-bg-control')), findsNothing);
    expect(find.byKey(const Key('gallery-bg-meadow')), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byKey(const Key('buttons-title'))))
          .brightness,
      Brightness.dark,
    );
  });

  testWidgets('legacy form and page queries open the right leaf', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(page: 'slider', chrome: '0'),
      ),
    );
    expect(find.byKey(const Key('slider-mid-idle')), findsOneWidget);
    expect(find.byKey(const Key('toggle-off-idle')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(page: 'stepper', chrome: '0'),
      ),
    );
    expect(find.byKey(const Key('stepper-idle')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(page: 'toggle', chrome: '0'),
      ),
    );
    expect(find.byKey(const Key('toggle-off-idle')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(page: 'pagecontrol', chrome: '0'),
      ),
    );
    expect(find.byKey(const Key('page-five')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(page: 'text', chrome: '0'),
      ),
    );
    expect(find.byKey(const Key('text-styles-title')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('glass buttons are their own leaf', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await openGalleryEntry(tester, 'buttons');
    expect(find.byKey(const Key('buttons-title')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-default')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-pressed')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-disabled')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-clear')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-destructive')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-prominent')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-medium')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-large')), findsOneWidget);
    expect(find.byKey(const Key('glass-button-symbol')), findsOneWidget);
    expect(
      find.byKey(const Key('glass-button-prominent-disabled')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('glass-button-live')),
      200,
      scrollable: galleryContentScrollable(),
    );
    await tester.tap(find.byKey(const Key('glass-button-live')));
    await tester.pumpAndSettle();
    expect(find.text('已点 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('gallery-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('buttons-title')), findsNothing);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('gallery-workbench-title')))
          .data,
      '基础工作台',
    );
  });

  testWidgets('compact width still uses dock tabs, not a sidebar', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    expect(find.byKey(const Key('lingyun-page-tab-bar')), findsOneWidget);
    expect(find.byKey(const Key('lingyun-page-sidebar')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('gallery-workbench')), findsOneWidget);
    await openGalleryEntry(tester, 'native');
    expect(find.byKey(const Key('native-page-title')), findsOneWidget);
  });

  testWidgets('preview chrome toggles theme and reduce transparency', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const LingyunGlassDemoApp());
    final title = find.byKey(const Key('gallery-workbench-title'));
    expect(find.byKey(const Key('gallery-preview-cluster')), findsOneWidget);
    expect(find.byKey(const Key('gallery-theme-light-on')), findsOneWidget);
    expect(find.byKey(const Key('gallery-theme-dark-on')), findsNothing);
    expect(find.byKey(const Key('gallery-bg-control')), findsOneWidget);
    expect(find.byKey(const Key('gallery-device-control')), findsOneWidget);
    expect(find.byKey(const Key('gallery-device-bg-canvas')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('lingyun-page-tab-bar')),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
    expect(Theme.of(tester.element(title)).brightness, Brightness.light);
    expect(
      LingyunAdaptivity.of(tester.element(title)).reduceTransparency,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('gallery-theme-dark')));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(title)).brightness, Brightness.dark);
    expect(find.byKey(const Key('gallery-theme-dark-on')), findsOneWidget);

    await tester.tap(find.byKey(const Key('gallery-theme-light')));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(title)).brightness, Brightness.light);

    await tester.tap(find.byKey(const Key('gallery-reduce-transparency')));
    await tester.pumpAndSettle();
    expect(
      LingyunAdaptivity.of(tester.element(title)).reduceTransparency,
      isTrue,
    );

    await openGalleryEntry(tester, 'access');
    expect(
      tester
          .widget<Switch>(find.byKey(const Key('gallery-reduce-transparency')))
          .value,
      isTrue,
    );
    expect(
      tester
          .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, '降低透明度'))
          .value,
      isTrue,
    );
    expect(
      LingyunAdaptivity.of(tester.element(find.byKey(const Key('a11y-title'))))
          .reduceTransparency,
      isTrue,
    );
  });

  testWidgets('device frame clips the stage and keeps chrome outside', (
    tester,
  ) async {
    final hostPlatform = defaultTargetPlatform;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      LingyunGlassDemoApp(
        launch: GalleryLaunch.fromUri(
          Uri.parse(
            'https://example.test/?theme=dark&a11y=1&frame=402x874&bg=meadow',
          ),
        ),
      ),
    );

    final title = find.byKey(const Key('gallery-workbench-title'));
    expect(Theme.of(tester.element(title)).brightness, Brightness.dark);
    expect(
      LingyunAdaptivity.of(tester.element(title)).reduceTransparency,
      isTrue,
    );
    expect(MediaQuery.sizeOf(tester.element(title)), const Size(402, 874));
    expect(Theme.of(tester.element(title)).platform, TargetPlatform.iOS);
    final board = find.byKey(const Key('gallery-workbench'));
    expect(
      MediaQuery.paddingOf(tester.element(board)),
      GalleryPreviewFrame.pro.safePadding,
    );
    expect(
      MediaQuery.viewPaddingOf(tester.element(board)),
      GalleryPreviewFrame.pro.safePadding,
    );
    expect(defaultTargetPlatform, TargetPlatform.iOS);
    expect(find.byKey(const Key('gallery-preview-chrome')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-meadow')), findsOneWidget);
    expect(find.byKey(const Key('gallery-device-bg-meadow')), findsOneWidget);
    final innerMeadow = tester.getRect(
      find.byKey(const Key('gallery-device-bg-meadow')),
    );

    final frameRect = tester.getRect(
      find.byKey(const Key('gallery-device-frame')),
    );
    final clusterRect = tester.getRect(
      find.byKey(const Key('gallery-preview-cluster')),
    );
    expect(frameRect.size, const Size(402, 874));
    expect(frameRect.center.dx, closeTo(800, 1));
    final bezelRect = tester.getRect(
      find.byKey(const Key('gallery-device-bezel')),
    );
    expect(
      tester
          .widget<IgnorePointer>(find.byKey(const Key('gallery-device-bezel')))
          .ignoring,
      isTrue,
    );
    expect(bezelRect.left, lessThan(frameRect.left));
    expect(bezelRect.top, lessThan(frameRect.top));
    expect(bezelRect.right, greaterThan(frameRect.right));
    expect(bezelRect.bottom, greaterThan(frameRect.bottom));
    expect(innerMeadow.width, closeTo(frameRect.width, 1));
    expect(innerMeadow.height, closeTo(frameRect.height, 1));
    expect(clusterRect.bottom, lessThanOrEqualTo(frameRect.top));
    final wall = tester.getRect(find.byKey(const Key('gallery-bg-meadow')));
    expect(wall.width, greaterThan(frameRect.width));
    expect(wall.height, greaterThan(frameRect.height));

    await tester.tap(find.byKey(const Key('gallery-bg-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('gallery-bg-option-canvas')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gallery-bg-canvas')), findsOneWidget);
    expect(find.byKey(const Key('gallery-device-bg-canvas')), findsOneWidget);
    expect(find.byKey(const Key('gallery-device-bg-meadow')), findsNothing);
    expect(find.byKey(const Key('gallery-device-frame')), findsOneWidget);

    await openGalleryEntry(tester, 'materials');
    expect(find.byKey(const Key('materials-title')), findsOneWidget);
    expect(
      MediaQuery.sizeOf(
        tester.element(find.byKey(const Key('materials-title'))),
      ),
      const Size(402, 874),
    );
    final back = tester.getRect(find.byKey(const Key('gallery-back')));
    final framed = tester.getRect(
      find.byKey(const Key('gallery-device-frame')),
    );
    expect(back.bottom, lessThanOrEqualTo(framed.top));

    await tester.tap(find.byKey(const Key('gallery-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gallery-workbench-title')), findsOneWidget);

    const frames = <GalleryPreviewFrame, Size>{
      GalleryPreviewFrame.proMax: Size(440, 956),
      GalleryPreviewFrame.air: Size(420, 912),
      GalleryPreviewFrame.duoOuter: Size(466, 678),
      GalleryPreviewFrame.duoInnerLandscape: Size(951, 669),
      GalleryPreviewFrame.duoInnerPortrait: Size(669, 951),
      GalleryPreviewFrame.ipadMini: Size(744, 1133),
      GalleryPreviewFrame.ipadAir11: Size(820, 1180),
      GalleryPreviewFrame.ipadPro11: Size(834, 1210),
      GalleryPreviewFrame.ipadAir13: Size(1024, 1366),
      GalleryPreviewFrame.ipadPro13: Size(1032, 1376),
      GalleryPreviewFrame.macos: Size(1440, 900),
      GalleryPreviewFrame.windows: Size(1280, 800),
      GalleryPreviewFrame.window: Size(1600, 1600),
    };
    for (final entry in frames.entries) {
      await tester.tap(find.byKey(const Key('gallery-device-control')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(Key('gallery-device-option-${entry.key.query}')),
      );
      await tester.pumpAndSettle();
      final titleFinder = find.byKey(const Key('gallery-workbench-title'));
      expect(MediaQuery.sizeOf(tester.element(titleFinder)), entry.value);
      if (entry.key == GalleryPreviewFrame.window) {
        expect(find.byKey(const Key('gallery-device-frame')), findsNothing);
        expect(find.byKey(const Key('gallery-device-bezel')), findsNothing);
        expect(find.byKey(const Key('gallery-preview-chrome')), findsNothing);
        expect(find.byKey(const Key('gallery-device-bg-canvas')), findsNothing);
        expect(find.byKey(const Key('gallery-bg-canvas')), findsOneWidget);
        expect(defaultTargetPlatform, hostPlatform);
        expect(Theme.of(tester.element(titleFinder)).platform, hostPlatform);
      } else {
        expect(
          Theme.of(tester.element(titleFinder)).platform,
          entry.key.platform,
        );
        final workbench = find.byKey(const Key('gallery-workbench'));
        expect(
          MediaQuery.paddingOf(tester.element(workbench)),
          entry.key.safePadding,
        );
        expect(
          MediaQuery.viewPaddingOf(tester.element(workbench)),
          entry.key.safePadding,
        );
        expect(defaultTargetPlatform, entry.key.platform);
        expect(find.byKey(const Key('gallery-device-bezel')), findsOneWidget);
        expect(
          tester
              .widget<IgnorePointer>(
                find.byKey(const Key('gallery-device-bezel')),
              )
              .ignoring,
          isTrue,
        );
        final screen = tester.getRect(
          find.byKey(const Key('gallery-device-frame')),
        );
        final shell = tester.getRect(
          find.byKey(const Key('gallery-device-bezel')),
        );
        expect(shell.left, lessThanOrEqualTo(screen.left));
        expect(shell.top, lessThanOrEqualTo(screen.top));
        expect(shell.right, greaterThanOrEqualTo(screen.right));
        expect(shell.bottom, greaterThanOrEqualTo(screen.bottom));
        expect(
          tester.getSize(find.byKey(const Key('gallery-device-frame'))),
          entry.value,
        );
        expect(
          tester
              .getRect(find.byKey(const Key('gallery-preview-cluster')))
              .bottom,
          lessThanOrEqualTo(
            tester.getRect(find.byKey(const Key('gallery-device-frame'))).top,
          ),
        );
        expect(
          find.byKey(const Key('gallery-device-bg-canvas')),
          findsOneWidget,
        );
        final board = tester.getRect(
          find.byKey(const Key('gallery-device-bg-canvas')),
        );
        final chrome = tester.getRect(
          find.byKey(const Key('gallery-device-frame')),
        );
        expect(board.width, closeTo(chrome.width, 1));
        expect(board.height, closeTo(chrome.height, 1));
      }
    }
  });

  testWidgets('large boards scale down and keep logical size and platform', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(720, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(device: GalleryPreviewFrame.ipadPro13),
      ),
    );
    final title = find.byKey(const Key('gallery-workbench-title'));
    expect(MediaQuery.sizeOf(tester.element(title)), const Size(1032, 1376));
    expect(Theme.of(tester.element(title)).platform, TargetPlatform.iOS);
    final padBoard = find.byKey(const Key('gallery-workbench'));
    expect(MediaQuery.paddingOf(tester.element(padBoard)).top, greaterThan(0));
    expect(
      MediaQuery.paddingOf(tester.element(padBoard)).bottom,
      greaterThan(0),
    );
    expect(defaultTargetPlatform, TargetPlatform.iOS);
    final pad = tester.getRect(find.byKey(const Key('gallery-device-frame')));
    expect(pad.width, lessThan(1032));
    expect(pad.height, lessThan(1376));
    expect(pad.width / pad.height, closeTo(1032 / 1376, 0.02));
    expect(find.byKey(const Key('gallery-device-bezel')), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const Key('gallery-preview-cluster'))).bottom,
      lessThanOrEqualTo(pad.top),
    );

    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(device: GalleryPreviewFrame.macos),
      ),
    );
    expect(MediaQuery.sizeOf(tester.element(title)), const Size(1440, 900));
    expect(Theme.of(tester.element(title)).platform, TargetPlatform.macOS);
    final macBoard = find.byKey(const Key('gallery-workbench'));
    expect(MediaQuery.paddingOf(tester.element(macBoard)), EdgeInsets.zero);
    expect(MediaQuery.viewPaddingOf(tester.element(macBoard)), EdgeInsets.zero);
    expect(defaultTargetPlatform, TargetPlatform.macOS);
    final mac = tester.getRect(find.byKey(const Key('gallery-device-frame')));
    expect(mac.width, lessThan(1440));
    expect(mac.width / mac.height, closeTo(1440 / 900, 0.02));

    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(device: GalleryPreviewFrame.windows),
      ),
    );
    expect(MediaQuery.sizeOf(tester.element(title)), const Size(1280, 800));
    expect(Theme.of(tester.element(title)).platform, TargetPlatform.windows);
    expect(
      MediaQuery.paddingOf(
        tester.element(find.byKey(const Key('gallery-workbench'))),
      ),
      EdgeInsets.zero,
    );
    expect(defaultTargetPlatform, TargetPlatform.windows);
    final win = tester.getRect(find.byKey(const Key('gallery-device-frame')));
    expect(win.width / win.height, closeTo(1280 / 800, 0.02));
    expect(win.width, lessThanOrEqualTo(720));
  });

  testWidgets('a narrow window scales the frame and keeps logical points', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(300, 400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const LingyunGlassDemoApp(
        launch: GalleryLaunch(device: GalleryPreviewFrame.pro),
      ),
    );
    final title = find.byKey(const Key('gallery-workbench-title'));
    expect(MediaQuery.sizeOf(tester.element(title)), const Size(402, 874));
    final rect = tester.getRect(find.byKey(const Key('gallery-device-frame')));
    expect(rect.width, lessThan(402));
    expect(rect.width / rect.height, closeTo(402 / 874, 0.02));
    expect(find.byKey(const Key('gallery-preview-cluster')), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const Key('gallery-preview-cluster'))).bottom,
      lessThanOrEqualTo(rect.top),
    );
  });

  testWidgets('bare chrome still applies theme, a11y, frame, and bg', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      LingyunGlassDemoApp(
        launch: GalleryLaunch.fromUri(
          Uri.parse(
            'https://example.test/?page=glass&chrome=0&theme=light'
            '&reduceTransparency=on&device=air&bg=wash',
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    expect(find.byKey(const Key('gallery-preview-cluster')), findsNothing);
    expect(find.byKey(const Key('gallery-bg-control')), findsNothing);
    expect(find.byKey(const Key('gallery-back')), findsNothing);
    expect(find.byKey(const Key('gallery-bg-wash')), findsOneWidget);
    expect(find.byKey(const Key('gallery-device-bg-wash')), findsOneWidget);
    expect(
      MediaQuery.sizeOf(tester.element(find.byKey(const Key('glass-title')))),
      const Size(420, 912),
    );
    expect(
      Theme.of(tester.element(find.byKey(const Key('glass-title')))).brightness,
      Brightness.light,
    );
    expect(
      LingyunAdaptivity.of(tester.element(find.byKey(const Key('glass-title'))))
          .reduceTransparency,
      isTrue,
    );
  });

  testWidgets('fixed board dock frosts the wallpaper inside the clip', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Future<void> pumpBoard(Brightness brightness) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: brightness,
            extensions: [
              brightness == Brightness.dark
                  ? LiquidGlassTheme.dark
                  : LiquidGlassTheme.light,
            ],
          ),
          home: RepaintBoundary(
            key: const Key('dock-probe'),
            child: GalleryDeviceStage(
              frame: GalleryPreviewFrame.pro,
              backdrop: const Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: ColoredBox(color: Color(0xFF101010))),
                  Expanded(child: ColoredBox(color: Color(0xFFF4F4F6))),
                ],
              ),
              child: const Align(
                alignment: Alignment.bottomCenter,
                child: GlassSurface(
                  style: LiquidGlassStyle.dock,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  width: 320,
                  height: 54,
                  child: SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    Future<int> redAt(Offset global) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('dock-probe')),
      );
      final local = boundary.globalToLocal(global);
      final width = boundary.size.width.round();
      final height = boundary.size.height.round();
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        return data!.buffer.asUint8List();
      });
      final x = local.dx.round().clamp(0, width - 1).toInt();
      final y = local.dy.round().clamp(0, height - 1).toInt();
      return bytes![(y * width + x) * 4];
    }

    for (final brightness in [Brightness.light, Brightness.dark]) {
      await pumpBoard(brightness);
      expect(find.byType(BackdropFilter), findsOneWidget);
      final glass = tester.getRect(find.byType(GlassSurface));
      final insideLeft = await redAt(
        Offset(glass.left + glass.width * 0.2, glass.center.dy),
      );
      final insideRight = await redAt(
        Offset(glass.right - glass.width * 0.2, glass.center.dy),
      );
      final outsideLeft = await redAt(Offset(glass.left - 10, glass.center.dy));
      final outsideRight = await redAt(
        Offset(glass.right + 10, glass.center.dy),
      );
      expect(
        (insideLeft - insideRight).abs(),
        greaterThan(20),
        reason: 'Dock glass must sample the split wallpaper, not a flat fill',
      );
      expect(
        (outsideLeft - outsideRight).abs(),
        greaterThan(20),
        reason: 'The slot beside the capsule stays transparent',
      );
    }
  });
}
