import 'package:flutter/material.dart';
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

    testWidgets('selection lens is a capsule, not a thin indicator bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          bar: GlassTabBar(items: items, currentIndex: 0, onChanged: (_) {}),
        ),
      );
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
      final lens = tester.getSize(
        find.byKey(const Key('glass-tab-selection-lens')),
      );
      expect(lens.height, greaterThan(24));
      expect(lens.height, lessThan(54));
      expect(lens.width, greaterThan(24));
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
