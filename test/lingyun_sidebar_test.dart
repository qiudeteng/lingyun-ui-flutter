import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sections = [
    LingyunSidebarSection(
      header: '邮箱',
      items: [
        LingyunSidebarItem(label: '收件箱', icon: Icons.inbox_outlined),
        LingyunSidebarItem(label: '已发送', icon: Icons.send_outlined),
        LingyunSidebarItem(
          label: '已归档',
          icon: Icons.archive_outlined,
          enabled: false,
        ),
      ],
    ),
    LingyunSidebarSection(
      header: '资料',
      items: [LingyunSidebarItem(label: '文稿')],
    ),
  ];

  group('LingyunSidebarMetrics', () {
    test('row tops step through headers and the system row height', () {
      expect(LingyunSidebarMetrics.itemCount(sections), 4);
      expect(LingyunSidebarMetrics.rowTop(sections, 0), 28);
      expect(
        LingyunSidebarMetrics.rowTop(sections, 1),
        28 + LingyunSidebarMetrics.rowHeight,
      );
      expect(
        LingyunSidebarMetrics.rowTop(sections, 3),
        28 +
            LingyunSidebarMetrics.rowHeight * 3 +
            LingyunSidebarMetrics.sectionGap +
            LingyunSidebarMetrics.sectionHeaderHeight,
      );
      expect(LingyunSidebarMetrics.preferredWidth, isNot(96));
      expect(
        LingyunSidebarMetrics.borderRadius(flushLeading: true),
        isNot(LingyunSidebarMetrics.borderRadius(flushLeading: false)),
      );
    });
  });

  test('sidebar sources stay on Thick, system rows, and the system curve', () {
    final library = File('lib/src/widgets/lingyun_sidebar.dart')
        .readAsStringSync();
    expect(library.contains('MaterialTier.thick'), isTrue);
    expect(library.contains('CupertinoListTile'), isTrue);
    expect(library.contains('Curves.fastEaseInToSlowEaseOut'), isTrue);
    expect(library.contains('LiquidGlassMotion'), isTrue);
    expect(library.contains('LiquidGlassStyle'), isFalse);
    expect(library.contains('GlassTabBar('), isFalse);
    expect(library.contains('material:'), isTrue);
    final glassStart = library.indexOf('return GlassSurface(');
    final glassEnd = library.indexOf('child:', glassStart);
    final glassCall = library.substring(glassStart, glassEnd);
    expect(glassCall.contains('style:'), isFalse);
    expect(glassCall.contains('tokens:'), isFalse);
    expect(glassCall.contains('MaterialTier.thick'), isTrue);
    for (final line in library.split('\n')) {
      if (!line.startsWith('import ')) continue;
      expect(line.contains('package:flutter/cupertino.dart'), isFalse);
      expect(line.contains('package:flutter/material.dart'), isFalse);
    }
  });

  group('LingyunSidebar', () {
    testWidgets('platter is Materials Thick directly over the backdrop', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: LingyunSidebarLayout(
              title: '资料库',
              subtitle: '本机',
              sections: sections,
              selectedIndex: 0,
              selectionKey: const Key('sidebar-selection'),
              backdrop: const SizedBox(key: Key('sidebar-backdrop')),
              onSelected: (_) {},
              body: const Text('详情'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('资料库'), findsOneWidget);
      expect(find.text('收件箱'), findsOneWidget);
      expect(find.text('详情'), findsOneWidget);
      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.material, MaterialTier.thick);
      expect(surface.style, isNull);
      expect(surface.tokens, isNull);
      expect(surface.enableHoverHighlight, isFalse);

      final stack = tester.widget<Stack>(
        find.byKey(const Key('lingyun-sidebar-stack')),
      );
      expect(stack.children.first, isA<SizedBox>());
      expect(stack.children.last, isA<LingyunSidebar>());
      expect(
        tester.getSize(find.byKey(const Key('lingyun-sidebar-column'))).width,
        LingyunSidebarMetrics.preferredWidth,
      );
    });

    testWidgets('tapping a row selects it and a disabled row does not', (
      tester,
    ) async {
      var selected = 0;
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return LingyunSidebarLayout(
                  sections: sections,
                  selectedIndex: selected,
                  onSelected: (index) => setState(() => selected = index),
                  body: Text('选中 $selected'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('已发送'));
      await tester.pumpAndSettle();
      expect(find.text('选中 1'), findsOneWidget);
      await tester.tap(find.text('已归档'));
      await tester.pumpAndSettle();
      expect(find.text('选中 1'), findsOneWidget);
    });

    testWidgets('collapse uses a visible curve, then settles closed', (
      tester,
    ) async {
      var expanded = true;
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return LingyunSidebarLayout(
                  expanded: expanded,
                  sections: sections,
                  selectedIndex: 0,
                  onSelected: (_) {},
                  body: TextButton(
                    onPressed: () => setState(() => expanded = !expanded),
                    child: const Text('切换'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const Key('lingyun-sidebar-column'))).width,
        LingyunSidebarMetrics.preferredWidth,
      );

      await tester.tap(find.text('切换'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
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
    });

    testWidgets('reduce motion collapses the column on the next frame', (
      tester,
    ) async {
      var expanded = false;
      await tester.pumpWidget(
        _app(
          reduceMotion: true,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return LingyunSidebarLayout(
                  expanded: expanded,
                  sections: sections,
                  selectedIndex: 0,
                  onSelected: (_) {},
                  body: TextButton(
                    onPressed: () => setState(() => expanded = true),
                    child: const Text('展开'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.getSize(find.byKey(const Key('lingyun-sidebar-column'))).width,
        0,
      );
      await tester.tap(find.text('展开'));
      await tester.pump();
      expect(
        tester.getSize(find.byKey(const Key('lingyun-sidebar-column'))).width,
        LingyunSidebarMetrics.preferredWidth,
      );
    });

    testWidgets('selection capsule moves, and jumps when animations are off', (
      tester,
    ) async {
      var selected = 0;
      Future<void> pumpAt(int index, {required bool disableAnimations}) {
        selected = index;
        return tester.pumpWidget(
          _app(
            disableAnimations: disableAnimations,
            home: Scaffold(
              body: LingyunSidebarLayout(
                sections: sections,
                selectedIndex: selected,
                selectionKey: const Key('sidebar-selection'),
                onSelected: (_) {},
                body: const SizedBox.shrink(),
              ),
            ),
          ),
        );
      }

      await pumpAt(0, disableAnimations: false);
      await tester.pumpAndSettle();
      final start = tester
          .getTopLeft(find.byKey(const Key('sidebar-selection')))
          .dy;

      await pumpAt(1, disableAnimations: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final mid = tester
          .getTopLeft(find.byKey(const Key('sidebar-selection')))
          .dy;
      expect(mid, greaterThan(start));
      expect(mid, lessThan(start + LingyunSidebarMetrics.rowHeight - 0.5));

      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(const Key('sidebar-selection'))).dy,
        closeTo(start + LingyunSidebarMetrics.rowHeight, 0.5),
      );

      await pumpAt(0, disableAnimations: true);
      await tester.pump();
      expect(
        tester.getTopLeft(find.byKey(const Key('sidebar-selection'))).dy,
        closeTo(start, 0.5),
      );
    });

    testWidgets('dark ambient is still one Thick platter', (tester) async {
      await tester.pumpWidget(
        _app(
          brightness: Brightness.dark,
          home: const Scaffold(
            body: LingyunSidebar(
              title: '资料库',
              sections: sections,
              selectedIndex: 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.material, MaterialTier.thick);
      expect(surface.style, isNull);
      final title = tester.widget<Text>(find.text('资料库'));
      expect(title.style?.color, LingyunColors.dark.labels.primary);
    });
  });
}

Widget _app({
  required Widget home,
  Brightness brightness = Brightness.light,
  bool reduceMotion = false,
  bool disableAnimations = false,
}) {
  final glass = brightness == Brightness.dark
      ? LiquidGlassTheme.dark
      : LiquidGlassTheme.light;
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: LingyunMaterialTheme.themeData(brightness)
        .copyWith(extensions: [glass]),
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: LingyunAdaptivity(
          reduceMotion: reduceMotion,
          child: LingyunTheme(brightness: brightness, child: child!),
        ),
      );
    },
    home: home,
  );
}
