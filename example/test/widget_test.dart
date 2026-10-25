import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/foundation_app.dart';
import 'package:example/main.dart';
import 'package:example/pages/form_controls_page.dart';
import 'package:example/pages/native_page.dart';
import 'package:example/wallpaper.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Page scroller inside the gallery body. The rail is also scrollable.
Finder galleryContentScrollable() {
  return find
      .descendant(
        of: find.byKey(const Key('gallery-body')),
        matching: find.byType(Scrollable),
      )
      .first;
}

void main() {
  testWidgets('gallery boots on Materials', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    expect(find.text('材质'), findsWidgets);
    expect(find.text('超薄'), findsWidgets);
    expect(find.text('厚'), findsWidgets);
    expect(find.byKey(const Key('materials-title')), findsOneWidget);
    expect(find.byKey(const Key('material-ultrathin')), findsOneWidget);
    expect(find.byKey(const Key('material-thin')), findsOneWidget);
    expect(find.byKey(const Key('material-regular')), findsOneWidget);
    expect(find.byKey(const Key('material-thick')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('radius-large')),
      200,
      scrollable: galleryContentScrollable(),
    );
    expect(find.byKey(const Key('radius-small')), findsOneWidget);
    expect(find.byKey(const Key('radius-medium')), findsOneWidget);
    expect(find.byKey(const Key('radius-large')), findsOneWidget);
  });

  testWidgets('gallery can open Glass, Layout and Accessibility', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await tester.tap(find.text('玻璃').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
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
    expect(find.text('常规小'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('glass-button-live')),
      200,
      scrollable: galleryContentScrollable(),
    );
    await tester.tap(find.byKey(const Key('glass-button-live')));
    await tester.pumpAndSettle();
    expect(find.text('已点 1'), findsOneWidget);

    await tester.tap(find.text('Layout').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('layout-title')), findsOneWidget);
    expect(find.byKey(const Key('preset-regular')), findsOneWidget);
    expect(find.byKey(const Key('layout-class-label')), findsOneWidget);
    expect(find.textContaining('regular · sidebar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('preset-compact')));
    await tester.pumpAndSettle();
    expect(find.textContaining('compact · tab'), findsOneWidget);

    await tester.tap(find.byKey(const Key('preset-wide')));
    await tester.pumpAndSettle();
    expect(find.textContaining('wide · sidebar'), findsOneWidget);

    await tester.tap(find.text('标签栏').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab-bar-title')), findsOneWidget);
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

    await tester.tap(find.text('Access').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('a11y-title')), findsOneWidget);
    expect(find.text('Reduce transparency'), findsOneWidget);
    expect(find.text('Reduce motion'), findsOneWidget);
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

    await tester.tap(find.text('玻璃').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glass-title')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-meadow')), findsOneWidget);

    await tester.tap(find.text('标签栏').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab-bar-title')), findsOneWidget);
    expect(find.byKey(const Key('gallery-bg-meadow')), findsWidgets);
  });

  testWidgets('alerts page shows system dialog states', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await tester.tap(find.text('提示').last);
    await tester.pumpAndSettle();

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
    await tester.tap(find.text('工作表').last);
    await tester.pumpAndSettle();

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
    await tester.scrollUntilVisible(
      find.byKey(const Key('sheet-open-window')),
      400,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('sheet-gallery-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const Key('sheet-open-window')));
    await tester.pumpAndSettle();
    expect(find.text('编辑项目'), findsWidgets);
    await tester.tap(find.text('完成').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('sheet-result')),
      -400,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('sheet-gallery-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
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
    final railScroll = find.descendant(
      of: find.byKey(const Key('gallery-rail')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('操作表').last,
      200,
      scrollable: railScroll.first,
    );
    await tester.tap(find.text('操作表').last);
    await tester.pumpAndSettle();

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
    await tester.tap(find.text('主题').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('themes-title')), findsOneWidget);
    expect(find.byKey(const Key('colors-title')), findsOneWidget);
    expect(find.text('系统颜色'), findsOneWidget);
    expect(find.text('液态玻璃标签'), findsOneWidget);
    expect(find.text('#0088FF'), findsWidgets);
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

  testWidgets('knob and track page switches brightness', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());
    await tester.tap(find.text('旋钮').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('controls-title')), findsOneWidget);
    expect(find.byKey(const Key('track-filled-idle')), findsOneWidget);
    expect(find.byKey(const Key('track-filled-clicked')), findsOneWidget);
    expect(find.byKey(const Key('track-unfilled-idle')), findsOneWidget);
    expect(find.byKey(const Key('track-unfilled-clicked')), findsOneWidget);
    expect(find.byKey(const Key('track-unfilled-disabled')), findsOneWidget);
    expect(
      find.byKey(const Key('track-filled-disabled-missing')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('knob-idle')), findsOneWidget);
    expect(find.byKey(const Key('knob-clicked')), findsOneWidget);
    expect(find.byKey(const Key('slider-idle')), findsOneWidget);
    expect(find.byKey(const Key('slider-clicked')), findsOneWidget);
    expect(find.byKey(const Key('knob-idle-missing')), findsNothing);
    expect(find.text('旋钮与轨道'), findsOneWidget);
    expect(find.textContaining('不是材质四档'), findsOneWidget);
    expect(find.textContaining('圆旋钮叠在轨道上'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('controls-brightness')),
        matching: find.text('深色'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('knob-idle')), findsNothing);
    expect(find.byKey(const Key('knob-idle-missing')), findsOneWidget);
    expect(find.byKey(const Key('knob-clicked')), findsOneWidget);
    expect(find.byKey(const Key('slider-clicked')), findsOneWidget);
    expect(find.byKey(const Key('track-filled-idle')), findsOneWidget);
    expect(find.textContaining('#0091FF'), findsWidgets);
  });

  testWidgets('form gallery pages use Simplified Chinese copy', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const LingyunGlassDemoApp());

    await tester.tap(find.text('列表').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lists-title')), findsOneWidget);
    expect(find.text('无线局域网'), findsOneWidget);
    expect(find.text('设计评审'), findsOneWidget);
    expect(find.text('Lists'), findsNothing);

    await tester.tap(find.text('文本框').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fields-title')), findsOneWidget);
    expect(find.text('显示名称'), findsOneWidget);
    expect(find.text('请输入有效的电子邮件'), findsOneWidget);
    expect(find.text('Text Fields'), findsNothing);

    await tester.tap(find.text('进度').last);
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
    await tester.tap(find.text('开关').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('form-controls-title')), findsOneWidget);
    expect(find.byKey(const Key('toggle-off-idle')), findsOneWidget);
    expect(find.byKey(const Key('toggle-on-idle')), findsOneWidget);
    expect(find.byKey(const Key('toggle-off-pressed')), findsOneWidget);
    expect(find.byKey(const Key('toggle-on-pressed')), findsOneWidget);
    expect(find.byKey(const Key('toggle-off-disabled')), findsOneWidget);
    expect(find.byKey(const Key('toggle-on-disabled')), findsOneWidget);
    expect(find.text('开关、滑杆与步进器'), findsOneWidget);
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

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('form-controls-panel')),
        matching: find.text('滑杆'),
      ),
    );
    await tester.pumpAndSettle();
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

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('form-controls-panel')),
        matching: find.text('步进器'),
      ),
    );
    await tester.pumpAndSettle();
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
}
