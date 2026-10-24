import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  const destinations = [
    GlassTabBarItem(icon: Icons.home_outlined, label: 'Home'),
    GlassTabBarItem(icon: Icons.search, label: 'Search'),
  ];

  group('resolveFlutterPageBucket', () {
    test('null size class uses the width proxy', () {
      expect(
        resolveFlutterPageBucket(width: 390),
        LingyunPageWidthBucket.compact,
      );
      expect(
        resolveFlutterPageBucket(width: 678),
        LingyunPageWidthBucket.regular,
      );
      expect(
        resolveFlutterPageBucket(width: 1024),
        LingyunPageWidthBucket.regular,
      );
      expect(
        resolveFlutterPageBucket(width: 1440),
        LingyunPageWidthBucket.wide,
      );
    });

    test('compact size class wins over a wide measurement', () {
      expect(
        resolveFlutterPageBucket(width: 678, horizontalSizeClass: 'compact'),
        LingyunPageWidthBucket.compact,
      );
      expect(
        resolveFlutterPageBucket(width: 1440, horizontalSizeClass: 'compact'),
        LingyunPageWidthBucket.compact,
      );
    });

    test('unspecified matches the iOS host and is not compact', () {
      expect(
        resolveFlutterPageBucket(
          width: 390,
          horizontalSizeClass: 'unspecified',
        ),
        LingyunPageWidthBucket.regular,
      );
      expect(
        resolveFlutterPageBucket(width: 1440, horizontalSizeClass: 'regular'),
        LingyunPageWidthBucket.wide,
      );
    });

    test('recommended spec is tab on compact and sidebar on regular', () {
      final compact = lingyunPageSpecForBucket(LingyunPageWidthBucket.compact);
      expect(compact.chrome, LingyunPageChrome.tab);
      expect(compact.navigation, LingyunPageNavigation.stack);
      expect(compact.requestsArrangement, isFalse);

      final regular = lingyunPageSpecForBucket(LingyunPageWidthBucket.regular);
      expect(regular.chrome, LingyunPageChrome.sidebar);
      expect(regular.navigation, LingyunPageNavigation.split);

      final wide = lingyunPageSpecForBucket(LingyunPageWidthBucket.wide);
      expect(wide.chrome, LingyunPageChrome.sidebar);
      expect(
        resolveLingyunPageContainer(
          wide,
          bucket: LingyunPageWidthBucket.wide,
        ).columns,
        3,
      );
    });
  });

  group('LingyunPage skeleton', () {
    Future<void> pumpPage(
      WidgetTester tester, {
      required Size size,
      required LingyunPage page,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: const [LiquidGlassTheme.light],
          ),
          home: Scaffold(body: page),
        ),
      );
      await tester.pump();
    }

    testWidgets('compact tab spec uses the bottom Dock and hides secondary', (
      tester,
    ) async {
      await pumpPage(
        tester,
        size: const Size(390, 844),
        page: const LingyunPage(
          spec: LingyunPageSpec(
            chrome: LingyunPageChrome.tab,
            navigation: LingyunPageNavigation.stack,
          ),
          destinations: destinations,
          primary: Text('primary-body'),
          secondary: Text('secondary-body'),
        ),
      );
      expect(find.byKey(const Key('lingyun-page-skeleton')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-tab-bar')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-sidebar')), findsNothing);
      expect(find.text('secondary-body'), findsNothing);
      final bar = tester.widget<GlassTabBar>(find.byType(GlassTabBar));
      expect(bar.style, GlassTabBarStyle.floatingPill);
      expect(bar.glassStyle, LiquidGlassStyle.dock);
      final scope = LingyunPageScope.of(
        tester.element(find.text('primary-body')),
      );
      expect(scope.bucket, LingyunPageWidthBucket.compact);
      expect(scope.container.root, 'TabView');
    });

    testWidgets('compact sidebar spec collapses to one column', (tester) async {
      await pumpPage(
        tester,
        size: const Size(390, 844),
        page: const LingyunPage(
          spec: LingyunPageSpec(
            chrome: LingyunPageChrome.sidebar,
            navigation: LingyunPageNavigation.split,
          ),
          destinations: destinations,
          primary: Text('primary-body'),
          secondary: Text('secondary-body'),
        ),
      );
      expect(find.byKey(const Key('lingyun-page-sidebar')), findsNothing);
      expect(find.byKey(const Key('lingyun-page-tab-bar')), findsNothing);
      expect(find.text('secondary-body'), findsNothing);
      expect(
        LingyunPageScope.of(tester.element(find.text('primary-body')))
            .container
            .columns,
        1,
      );
    });

    testWidgets('regular sidebar spec shows the glass rail only', (
      tester,
    ) async {
      await pumpPage(
        tester,
        size: const Size(1024, 768),
        page: const LingyunPage(
          spec: LingyunPageSpec(
            chrome: LingyunPageChrome.sidebar,
            navigation: LingyunPageNavigation.split,
          ),
          destinations: destinations,
          primary: Text('primary-body'),
          secondary: Text('secondary-body'),
        ),
      );
      expect(find.byKey(const Key('lingyun-page-sidebar')), findsOneWidget);
      expect(find.byKey(const Key('lingyun-page-tab-bar')), findsNothing);
      expect(find.text('secondary-body'), findsNothing);
      final bar = tester.widget<GlassTabBar>(find.byType(GlassTabBar));
      expect(bar.style, GlassTabBarStyle.sidebar);
      expect(bar.glassStyle, LiquidGlassStyle.dock);
      final scope = LingyunPageScope.of(
        tester.element(find.text('primary-body')),
      );
      expect(scope.bucket, LingyunPageWidthBucket.regular);
      expect(scope.container.columns, 2);
    });

    testWidgets('wide sidebar spec shows rail plus two content columns', (
      tester,
    ) async {
      await pumpPage(
        tester,
        size: const Size(1440, 900),
        page: const LingyunPage(
          spec: LingyunPageSpec(
            chrome: LingyunPageChrome.sidebar,
            navigation: LingyunPageNavigation.split,
          ),
          destinations: destinations,
          primary: Text('primary-body'),
          secondary: Text('secondary-body'),
        ),
      );
      expect(find.byKey(const Key('lingyun-page-sidebar')), findsOneWidget);
      expect(find.text('secondary-body'), findsOneWidget);
      expect(find.text('primary-body'), findsOneWidget);
      expect(
        LingyunPageScope.of(tester.element(find.text('primary-body')))
            .container
            .columns,
        3,
      );
    });

    testWidgets('explicit compact class at 678 stays on the bottom tab', (
      tester,
    ) async {
      await pumpPage(
        tester,
        size: const Size(678, 466),
        page: LingyunPage(
          spec: lingyunPageSpecForBucket(LingyunPageWidthBucket.compact),
          horizontalSizeClass: 'compact',
          destinations: destinations,
          primary: const Text('primary-body'),
        ),
      );
      expect(find.byKey(const Key('lingyun-page-tab-bar')), findsOneWidget);
      expect(
        LingyunPageScope.of(tester.element(find.text('primary-body'))).bucket,
        LingyunPageWidthBucket.compact,
      );
    });

    testWidgets('active division inserts a seam on a two-column split', (
      tester,
    ) async {
      const size = Size(951, 669);
      final stub = lingyunPageDivisionStub(size);
      await pumpPage(
        tester,
        size: size,
        page: LingyunPage(
          spec: const LingyunPageSpec(
            chrome: LingyunPageChrome.none,
            navigation: LingyunPageNavigation.split,
          ),
          regions: [stub],
          primary: const Text('primary-body'),
          secondary: const Text('secondary-body'),
        ),
      );
      final seam = tester.getSize(
        find.byKey(const Key('lingyun-page-division')),
      );
      expect(seam.width, closeTo(stub.width, 0.5));
      final primary = tester.getRect(find.text('primary-body'));
      final secondary = tester.getRect(find.text('secondary-body'));
      expect(secondary.right, lessThan(primary.left));
    });

    testWidgets('inactive division does not insert a seam', (tester) async {
      await pumpPage(
        tester,
        size: const Size(951, 669),
        page: const LingyunPage(
          spec: LingyunPageSpec(
            chrome: LingyunPageChrome.none,
            navigation: LingyunPageNavigation.split,
          ),
          regions: [
            LingyunPageRegion(
              kind: 'division',
              isActive: false,
              x: 400,
              y: 0,
              width: 40,
              height: 669,
            ),
          ],
          primary: Text('primary-body'),
          secondary: Text('secondary-body'),
        ),
      );
      expect(find.byKey(const Key('lingyun-page-division')), findsNothing);
      expect(find.text('secondary-body'), findsOneWidget);
    });

    testWidgets('arrangement is a note, not a hinge or a tab bar', (
      tester,
    ) async {
      await pumpPage(
        tester,
        size: const Size(1024, 768),
        page: const LingyunPage(
          spec: LingyunPageSpec(
            chrome: LingyunPageChrome.tab,
            navigation: LingyunPageNavigation.arrangementSplit,
          ),
          regions: [
            LingyunPageRegion(
              kind: 'division',
              isActive: true,
              x: 480,
              y: 0,
              width: 40,
              height: 768,
            ),
          ],
          destinations: destinations,
          primary: Text('primary-body'),
        ),
      );
      expect(
        find.byKey(const Key('lingyun-page-arrangement-fallback')),
        findsOneWidget,
      );
      expect(find.textContaining('LY_IOS_27_1_SDK=1'), findsOneWidget);
      expect(find.byType(GlassTabBar), findsNothing);
      expect(find.byKey(const Key('lingyun-page-division')), findsNothing);
      expect(
        LingyunPageScope.of(tester.element(find.text('primary-body')))
            .container
            .root,
        'ArrangementView',
      );
    });
  });
}
