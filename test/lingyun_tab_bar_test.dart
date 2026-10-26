import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const items = <GlassTabBarItem>[
    GlassTabBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      systemImage: 'house',
      selectedSystemImage: 'house.fill',
    ),
    GlassTabBarItem(
      icon: Icons.search,
      label: 'Search',
      badge: '3',
      systemImage: 'magnifyingglass',
    ),
    GlassTabBarItem(
      icon: Icons.grid_view_rounded,
      label: 'Library',
      systemImage: 'square.grid.2x2',
      selectedSystemImage: 'square.grid.2x2.fill',
    ),
    GlassTabBarItem(
      icon: Icons.lock_outline,
      label: 'Locked',
      enabled: false,
      systemImage: 'lock',
    ),
  ];

  group('LingyunTabBar API parity', () {
    test('flutter dock and the iOS host share one item wire', () {
      final bar = LingyunTabBar(
        items: items,
        currentIndex: 1,
        onChanged: (_) {},
        tintedBar: true,
        tint: const Color(0xFF0088FF),
      );
      expect(bar.style, GlassTabBarStyle.floatingPill);
      expect(bar.glassStyle, LiquidGlassStyle.dock);
      expect(bar.items, items);
      expect(bar.currentIndex, 1);
      final wire = bar.toWire();
      expect(wire['currentIndex'], 1);
      expect(wire['tintedBar'], isTrue);
      expect(wire['tint'], const Color(0xFF0088FF).toARGB32());
      final wired = wire['items'] as List;
      expect(wired, hasLength(4));
      expect((wired[0] as Map)['systemImage'], 'house');
      expect((wired[0] as Map)['selectedSystemImage'], 'house.fill');
      expect((wired[1] as Map)['badge'], '3');
      expect((wired[1] as Map)['selectedSystemImage'], 'magnifyingglass');
      expect((wired[3] as Map)['enabled'], isFalse);
    });

    test('flutter dock stays up unless a real iOS view is ready', () {
      expect(
        lingyunTabBarPaintsFlutterDock(
          isIOSHost: false,
          debugOverride: false,
          platformViewReady: false,
        ),
        isTrue,
      );
      expect(
        lingyunTabBarPaintsFlutterDock(
          isIOSHost: true,
          debugOverride: true,
          platformViewReady: true,
        ),
        isTrue,
      );
      expect(
        lingyunTabBarPaintsFlutterDock(
          isIOSHost: true,
          debugOverride: false,
          platformViewReady: false,
        ),
        isTrue,
      );
      expect(
        lingyunTabBarPaintsFlutterDock(
          isIOSHost: true,
          debugOverride: false,
          platformViewReady: true,
        ),
        isFalse,
      );
    });

    test('system frame insets the matching edge', () {
      const bounds = Size(402, 874);
      expect(
        const LingyunTabBarMetrics(
          edge: LingyunTabBarEdge.bottom,
          x: 16,
          y: 780,
          width: 370,
          height: 94,
        ).contentPadding(bounds),
        const EdgeInsetsDirectional.only(bottom: 94),
      );
      expect(
        const LingyunTabBarMetrics(
          edge: LingyunTabBarEdge.leading,
          x: 0,
          y: 0,
          width: 86,
          height: 874,
        ).contentPadding(bounds),
        const EdgeInsetsDirectional.only(start: 86),
      );
      expect(
        const LingyunTabBarMetrics(
          edge: LingyunTabBarEdge.trailing,
          x: 320,
          y: 0,
          width: 82,
          height: 874,
        ).contentPadding(bounds),
        const EdgeInsetsDirectional.only(end: 82),
      );
      expect(
        const LingyunTabBarMetrics(
          edge: LingyunTabBarEdge.top,
          x: 0,
          y: 0,
          width: 402,
          height: 58,
        ).contentPadding(bounds),
        const EdgeInsetsDirectional.only(top: 58),
      );
      expect(
        LingyunTabBarMetrics.fromWire({
          'edge': 'leading',
          'x': 0,
          'y': 0,
          'width': 40,
          'height': 100,
        }),
        const LingyunTabBarMetrics(
          edge: LingyunTabBarEdge.leading,
          x: 0,
          y: 0,
          width: 40,
          height: 100,
        ),
      );
      expect(LingyunTabBarMetrics.fromWire({'edge': 'nope'}), isNull);
    });
  });

  group('LingyunTabBar hosts', () {
    Widget host(LingyunTabBar bar) {
      return MaterialApp(
        theme: ThemeData.light().copyWith(
          extensions: const [LiquidGlassTheme.light],
        ),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 402,
            height: 874,
            child: MediaQuery(
              data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
              child: bar,
            ),
          ),
        ),
      );
    }

    testWidgets('non-iOS paints the system dock and keeps the body', (
      tester,
    ) async {
      var index = 0;
      await tester.pumpWidget(
        host(
          LingyunTabBar(
            items: items,
            currentIndex: index,
            onChanged: (value) => index = value,
            child: const Text('workbench', key: Key('tab-body')),
          ),
        ),
      );
      expect(find.byType(UiKitView), findsNothing);
      expect(find.byKey(const Key('tab-body')), findsOneWidget);
      final dock = tester.widget<GlassTabBar>(find.byType(GlassTabBar));
      expect(dock.systemDock, isTrue);
      expect(dock.style, GlassTabBarStyle.floatingPill);
      expect(dock.glassStyle, LiquidGlassStyle.dock);
      expect(dock.items.map((item) => item.systemImage), [
        'house',
        'magnifyingglass',
        'square.grid.2x2',
        'lock',
      ]);
      expect(
        tester.widget<Text>(find.text('Home')).style?.color,
        const Color(0xFF0088FF),
      );
      expect(
        tester.widget<Text>(find.text('Search')).style?.color,
        const Color(0xFF727272),
      );
      expect(tester.widget<Icon>(find.byIcon(Icons.home)).size, 22);
      final glass = tester.getSize(find.byType(GlassSurface));
      expect(glass.width, closeTo(370, 1));
      expect(glass.height, closeTo(62, 1));

      await tester.tap(find.text('Library'));
      await tester.pump();
      expect(index, 2);

      await tester.tap(find.text('Locked'));
      await tester.pump();
      expect(index, 2);
    });

    testWidgets('wide boards cap the system capsule', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: const [LiquidGlassTheme.light],
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 1280,
                child: GlassTabBar(
                  systemDock: true,
                  items: items,
                  currentIndex: 0,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(GlassSurface)).width, closeTo(480, 1));
    });

    testWidgets('iOS host mounts the system tab bar and keeps the body', (
      tester,
    ) async {
      LingyunPageHost.debugIsIOSHostOverride = true;
      addTearDown(() => LingyunPageHost.debugIsIOSHostOverride = null);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        (call) async => null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform_views,
          null,
        ),
      );

      var index = 0;
      await tester.pumpWidget(
        host(
          LingyunTabBar(
            items: items,
            currentIndex: index,
            onChanged: (value) => index = value,
            child: const Text('workbench', key: Key('tab-body')),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('tab-body')), findsOneWidget);
      expect(find.byType(UiKitView), findsOneWidget);
      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      expect(view.viewType, LingyunTabBarHost.viewType);
      expect(view.viewType, isNot(LingyunPageHost.viewType));
      expect(view.hitTestBehavior, PlatformViewHitTestBehavior.transparent);
      final dock = tester.widget<GlassTabBar>(find.byType(GlassTabBar));
      expect(dock.systemDock, isTrue);
      expect(dock.onChanged, isNotNull);

      await tester.tap(find.text('Search'));
      await tester.pump();
      expect(index, 1);
    });
  });
}
