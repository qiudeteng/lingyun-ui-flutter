import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const items = <GlassTabBarItem>[
    GlassTabBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    GlassTabBarItem(icon: Icons.search, label: 'Search', badge: '3'),
    GlassTabBarItem(icon: Icons.grid_view_rounded, label: 'Library'),
    GlassTabBarItem(icon: Icons.lock_outline, label: 'Locked', enabled: false),
    GlassTabBarItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  Widget harness({
    required GlassTabBar bar,
    Brightness brightness = Brightness.light,
    double width = 402,
    EdgeInsets padding = const EdgeInsets.only(bottom: 34),
    bool disableAnimations = false,
  }) {
    final glass = brightness == Brightness.dark
        ? LiquidGlassTheme.dark
        : LiquidGlassTheme.light;
    final theme = brightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();
    return MaterialApp(
      theme: theme.copyWith(extensions: [glass]),
      home: MediaQuery(
        data: MediaQueryData(
          padding: padding,
          size: Size(width, 874),
          disableAnimations: disableAnimations,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(width: width, child: bar),
        ),
      ),
    );
  }

  group('GlassTabBar', () {
    test('defaults are floating Dock glass, not a Materials tier', () {
      final bar = GlassTabBar(items: items, currentIndex: 0, onChanged: (_) {});
      expect(bar.style, GlassTabBarStyle.floatingPill);
      expect(bar.glassStyle, LiquidGlassStyle.dock);
      expect(bar.tintedBar, isFalse);
      expect(GlassTabBar.systemBlueLight, const Color(0xFF0088FF));
      expect(GlassTabBar.systemBlueDark, const Color(0xFF0091FF));
      expect(
        GlassTabBarStyle.values,
        containsAll([
          GlassTabBarStyle.standard,
          GlassTabBarStyle.floatingPill,
          GlassTabBarStyle.sidebar,
        ]),
      );
    });

    testWidgets('selected caption is System Blue, unselected is primary', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(items: items, currentIndex: 0, onChanged: (_) {}),
        ),
      );

      final home = tester.widget<Text>(find.text('Home'));
      final library = tester.widget<Text>(find.text('Library'));
      expect(home.style?.fontSize, 10);
      expect(home.style?.fontSize, isNot(17));
      expect(home.style?.color, GlassTabBar.systemBlueLight);
      expect(home.style?.fontWeight, FontWeight.w600);
      expect(
        library.style?.color,
        LiquidGlassLabels.lightPrimary.withValues(
          alpha: GlassTabBar.unselectedOpacity,
        ),
      );

      final homeIcon = tester.widget<Icon>(find.byIcon(Icons.home));
      final libraryIcon = tester.widget<Icon>(
        find.byIcon(Icons.grid_view_rounded),
      );
      expect(homeIcon.color, GlassTabBar.systemBlueLight);
      expect(homeIcon.size, 18);
      expect(libraryIcon.color, isNot(GlassTabBar.systemBlueLight));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('dark selected tint is the dark System Blue', (tester) async {
      await tester.pumpWidget(
        harness(
          brightness: Brightness.dark,
          bar: GlassTabBar(items: items, currentIndex: 0, onChanged: (_) {}),
        ),
      );
      final home = tester.widget<Text>(find.text('Home'));
      expect(home.style?.color, GlassTabBar.systemBlueDark);
      final library = tester.widget<Text>(find.text('Library'));
      expect(
        library.style?.color,
        LiquidGlassLabels.darkPrimary.withValues(
          alpha: GlassTabBar.unselectedOpacity,
        ),
      );
    });

    testWidgets('tinted bar is white on the platter, not blue glyphs', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(
            tintedBar: true,
            items: items,
            currentIndex: 0,
            onChanged: (_) {},
          ),
        ),
      );
      final home = tester.widget<Text>(find.text('Home'));
      final library = tester.widget<Text>(find.text('Library'));
      expect(home.style?.color, Colors.white);
      expect(
        library.style?.color,
        Colors.white.withValues(alpha: GlassTabBar.tintedUnselectedOpacity),
      );
      expect(home.style?.color, isNot(GlassTabBar.systemBlueLight));
    });

    testWidgets('disabled item does not change the index', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(
            items: items,
            currentIndex: index,
            onChanged: (i) => index = i,
          ),
        ),
      );
      await tester.tap(find.text('Locked'));
      await tester.pump();
      expect(index, 0);

      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(index, 4);

      expect(
        tester
            .widgetList<Opacity>(find.byType(Opacity))
            .any((opacity) => opacity.opacity == GlassTabBar.disabledOpacity),
        isTrue,
      );
    });

    testWidgets('selection lens is a nested capsule, not a second platter', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(items: items, currentIndex: 0, onChanged: (_) {}),
        ),
      );
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byType(AnimatedPositioned), findsNothing);
      // One Dock platter. The lens is a light layer, not another blur.
      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      const lensKey = Key('glass-tab-selection-lens');
      final lens = tester.getSize(find.byKey(lensKey));
      expect(lens.height, greaterThan(24));
      expect(lens.height, lessThan(54));
      expect(lens.width, greaterThan(24));
      expect(
        find.descendant(
          of: find.byKey(lensKey),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(
        tester.getCenter(find.byKey(lensKey)).dx,
        closeTo(tester.getCenter(find.text('Home')).dx, 4),
      );
      expect(
        tester
            .widget<Opacity>(find.byKey(const Key('glass-tab-lens-glow')))
            .opacity,
        0,
      );
    });

    testWidgets('drag follows the finger and selects on release', (
      tester,
    ) async {
      var index = 0;
      var calls = 0;
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(
            items: items,
            currentIndex: index,
            onChanged: (i) {
              calls += 1;
              index = i;
            },
          ),
        ),
      );
      const lensKey = Key('glass-tab-selection-lens');
      final start = tester.getCenter(find.byKey(lensKey)).dx;
      final home = tester.getCenter(find.text('Home'));
      final library = tester.getCenter(find.text('Library'));
      final gesture = await tester.startGesture(home);
      await gesture.moveBy(library - home);
      await tester.pump(const Duration(milliseconds: 80));
      expect(index, 0);
      expect(calls, 0);
      expect(tester.getCenter(find.byKey(lensKey)).dx, greaterThan(start + 8));
      await gesture.up();
      await tester.pump();
      expect(calls, 1);
      expect(index, 2);
    });

    testWidgets('release on a disabled item does not select it', (
      tester,
    ) async {
      var index = 0;
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(
            items: items,
            currentIndex: index,
            onChanged: (i) => index = i,
          ),
        ),
      );
      final home = tester.getCenter(find.text('Home'));
      final locked = tester.getCenter(find.text('Locked'));
      final gesture = await tester.startGesture(home);
      await gesture.moveBy(locked - home);
      await gesture.up();
      await tester.pump();
      expect(index, 0);
    });

    testWidgets('press lifts the glyph and lights the lens', (tester) async {
      var index = 0;
      var calls = 0;
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(
            items: items,
            currentIndex: index,
            onChanged: (i) {
              calls += 1;
              index = i;
            },
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Home')),
      );
      await tester.pump(const Duration(milliseconds: 90));
      final scale = tester.widget<AnimatedScale>(
        find.descendant(
          of: find.byKey(const Key('glass-tab-item-0')),
          matching: find.byType(AnimatedScale),
        ),
      );
      expect(scale.scale, greaterThan(1.12));
      expect(scale.scale, lessThan(1.16));
      expect(
        tester
            .widget<Opacity>(find.byKey(const Key('glass-tab-lens-glow')))
            .opacity,
        1,
      );
      final transform = tester.widget<Transform>(
        find.byKey(const Key('glass-tab-lens-transform')),
      );
      expect(transform.transform.storage[0], greaterThan(1.03));
      await gesture.up();
      await tester.pump();
      // Reselect still notifies so a shell can pop back to its workbench.
      expect(calls, 1);
      expect(index, 0);
    });

    testWidgets('lens travels across a far selection, then settles', (
      tester,
    ) async {
      const lensKey = Key('glass-tab-selection-lens');
      Future<void> show(int index) {
        return tester.pumpWidget(
          harness(
            bar: GlassTabBar(
              key: const Key('travel-bar'),
              items: items,
              currentIndex: index,
              onChanged: (_) {},
            ),
          ),
        );
      }

      await show(0);
      final start = tester.getCenter(find.byKey(lensKey)).dx;
      await show(4);
      await tester.pump(const Duration(milliseconds: 80));
      final mid = tester.getCenter(find.byKey(lensKey)).dx;
      final profile = tester.getCenter(find.text('Profile')).dx;
      expect(mid, greaterThan(start + 0.5));
      expect((profile - mid).abs(), greaterThan(40));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 20),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 3),
      );
      expect(tester.getCenter(find.byKey(lensKey)).dx, closeTo(profile, 8));
    });

    testWidgets('reduce motion snaps the lens without a flight', (
      tester,
    ) async {
      const lensKey = Key('glass-tab-selection-lens');
      Future<void> show(int index) {
        return tester.pumpWidget(
          harness(
            disableAnimations: true,
            bar: GlassTabBar(
              key: const Key('reduce-bar'),
              items: items,
              currentIndex: index,
              onChanged: (_) {},
            ),
          ),
        );
      }

      await show(0);
      await show(4);
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        tester.getCenter(find.byKey(lensKey)).dx,
        closeTo(tester.getCenter(find.text('Profile')).dx, 8),
      );
    });

    testWidgets('floating pill grows from 3 items to the 5-item cap', (
      tester,
    ) async {
      Future<Size> glassSize(int count) async {
        await tester.pumpWidget(
          harness(
            bar: GlassTabBar(
              style: GlassTabBarStyle.floatingPill,
              items: [
                for (var i = 0; i < count; i++)
                  GlassTabBarItem(icon: Icons.circle, label: 'Tab $i'),
              ],
              currentIndex: 0,
              onChanged: (_) {},
            ),
          ),
        );
        return tester.getSize(find.byType(GlassSurface));
      }

      final three = await glassSize(3);
      final four = await glassSize(4);
      final five = await glassSize(5);

      // Kit content group + 4pt platter outset each side.
      // 3 → 266 + 8, 4 and 5 share 352 + 8 on a 402pt board.
      expect(three.width, closeTo(274, 1));
      expect(four.width, closeTo(360, 1));
      expect(five.width, closeTo(360, 1));
      expect(five.width, greaterThan(three.width));
      expect(five.width, lessThan(402));
      expect(three.height, closeTo(62, 1));
    });

    testWidgets('floating pill sits above the home indicator', (tester) async {
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(
            style: GlassTabBarStyle.floatingPill,
            items: items,
            currentIndex: 0,
            onChanged: (_) {},
          ),
        ),
      );
      final bar = tester.getRect(find.byType(GlassTabBar));
      final glass = tester.getRect(find.byType(GlassSurface));
      expect(glass.width, lessThan(bar.width));
      expect(bar.bottom - glass.bottom, closeTo(25, 0.5));
      expect(glass.center.dx, closeTo(bar.center.dx, 0.5));
    });

    testWidgets('standard bar is full width and edge to bottom', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(
            style: GlassTabBarStyle.standard,
            items: items,
            currentIndex: 0,
            onChanged: (_) {},
          ),
        ),
      );
      final bar = tester.getRect(find.byType(GlassTabBar));
      final glass = tester.getRect(find.byType(GlassSurface));
      final label = tester.getRect(find.text('Home'));
      expect(glass.left, bar.left);
      expect(glass.right, bar.right);
      expect(glass.bottom, bar.bottom);
      expect(glass.width, 402);
      expect(label.bottom, lessThan(glass.bottom - 20));
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('sidebar stub lays items out vertically', (tester) async {
      await tester.pumpWidget(
        harness(
          padding: EdgeInsets.zero,
          bar: GlassTabBar(
            style: GlassTabBarStyle.sidebar,
            items: const [
              GlassTabBarItem(icon: Icons.home_outlined, label: 'Home'),
              GlassTabBarItem(icon: Icons.search, label: 'Search'),
            ],
            currentIndex: 0,
            onChanged: (_) {},
          ),
        ),
      );
      expect(
        find.byKey(const Key('glass-tab-bar-sidebar-stub')),
        findsOneWidget,
      );
      final home = tester.getRect(find.text('Home'));
      final search = tester.getRect(find.text('Search'));
      expect(search.top, greaterThan(home.bottom - 4));
    });

    testWidgets('reduce motion still selects without throwing', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        harness(
          disableAnimations: true,
          bar: GlassTabBar(
            items: items,
            currentIndex: 0,
            onChanged: (i) => index = i,
          ),
        ),
      );
      await tester.tap(find.text('Library'));
      await tester.pump();
      expect(index, 2);
    });

    testWidgets('opaque fallback skips backdrop blur', (tester) async {
      await tester.pumpWidget(
        LingyunAdaptivity(
          reduceTransparency: true,
          child: MaterialApp(
            home: GlassTabBar(items: items, currentIndex: 0, onChanged: (_) {}),
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}
