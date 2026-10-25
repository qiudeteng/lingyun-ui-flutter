import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toolbar sources are grouped glass, not Thick and not Dock', () {
    final library = File('lib/src/widgets/lingyun_toolbar.dart')
        .readAsStringSync();
    expect(library.contains('LiquidGlassStyle.regularMedium'), isTrue);
    expect(library.contains('LiquidGlassStyle.dock'), isTrue);
    expect(library.contains('material:'), isFalse);
    expect(library.contains('style: style'), isTrue);
    expect(library.contains('GlassTabBar('), isFalse);
    expect(library.contains('LiquidGlassMotion'), isTrue);
    expect(library.contains('pressedScale = 0.97'), isTrue);
    for (final line in library.split('\n')) {
      if (!line.startsWith('import ')) continue;
      expect(line.contains('package:flutter/cupertino.dart'), isFalse);
      expect(line.contains('package:flutter/material.dart'), isFalse);
    }
  });

  test('Dock is rejected', () {
    expect(
      () => LingyunToolbar(glassStyle: LiquidGlassStyle.dock),
      throwsAssertionError,
    );
  });

  group('LingyunToolbar', () {
    testWidgets('leading, title, and trailing share floating groups', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: LingyunToolbar(
                slotKey: Key('toolbar-slot'),
                title: Text('浏览'),
                leading: LingyunToolbarActionButton(
                  action: LingyunToolbarAction(
                    icon: Icons.arrow_back,
                    label: '返回',
                    onPressed: _noop,
                  ),
                ),
                actions: [
                  LingyunToolbarAction(
                    icon: Icons.share_outlined,
                    label: '分享',
                    onPressed: _noop,
                  ),
                  LingyunToolbarAction(
                    icon: Icons.more_horiz,
                    label: '更多',
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('浏览'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      final surfaces = tester.widgetList<GlassSurface>(
        find.byType(GlassSurface),
      );
      expect(surfaces, hasLength(2));
      for (final surface in surfaces) {
        expect(surface.style, LiquidGlassStyle.regularMedium);
        expect(surface.material, isNull);
        expect(surface.tokens, isNull);
        expect(surface.borderRadius, LingyunToolbarMetrics.capsuleRadius);
      }
      final slot = tester.getRect(find.byKey(const Key('toolbar-slot')));
      expect(slot.top, 0);
      expect(slot.height, greaterThan(LingyunToolbarMetrics.actionExtent));
    });

    testWidgets(
      'press eases toward 0.97 and still lands there without motion',
      (tester) async {
        await tester.pumpWidget(
          _app(
            home: const Scaffold(
              body: LingyunToolbar(
                actions: [
                  LingyunToolbarAction(
                    icon: Icons.share_outlined,
                    label: '分享',
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final button = find.byType(LingyunToolbarActionButton);
        final gesture = await tester.startGesture(tester.getCenter(button));
        await tester.pump();
        expect(
          tester
              .widget<AnimatedScale>(
                find.descendant(
                  of: button,
                  matching: find.byType(AnimatedScale),
                ),
              )
              .scale,
          LingyunToolbarMetrics.pressedScale,
        );
        await tester.pump(const Duration(milliseconds: 90));
        final mid = tester
            .widget<ScaleTransition>(
              find.descendant(
                of: button,
                matching: find.byType(ScaleTransition),
              ),
            )
            .scale
            .value;
        expect(mid, greaterThan(LingyunToolbarMetrics.pressedScale));
        expect(mid, lessThan(1));
        await gesture.up();
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          _app(
            reduceMotion: true,
            home: const Scaffold(
              body: LingyunToolbar(
                actions: [
                  LingyunToolbarAction(
                    icon: Icons.share_outlined,
                    label: '分享',
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        final held = await tester.startGesture(
          tester.getCenter(find.byType(LingyunToolbarActionButton)),
        );
        await tester.pump();
        expect(
          tester
              .widget<ScaleTransition>(
                find.descendant(
                  of: find.byType(LingyunToolbarActionButton),
                  matching: find.byType(ScaleTransition),
                ),
              )
              .scale
              .value,
          closeTo(LingyunToolbarMetrics.pressedScale, 0.001),
        );
        await held.up();
      },
    );

    testWidgets('hiding the bar animates the slot, unless motion is reduced', (
      tester,
    ) async {
      var visible = true;
      Future<void> pump({required bool reduceMotion}) {
        return tester.pumpWidget(
          _app(
            reduceMotion: reduceMotion,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      LingyunToolbar(
                        slotKey: const Key('toolbar-slot'),
                        visible: visible,
                        title: const Text('浏览'),
                        actions: const [
                          LingyunToolbarAction(
                            icon: Icons.share_outlined,
                            label: '分享',
                            onPressed: _noop,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => setState(() => visible = !visible),
                        child: const Text('显隐'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }

      await pump(reduceMotion: false);
      await tester.pumpAndSettle();
      final full = tester.getSize(find.byKey(const Key('toolbar-slot'))).height;
      expect(full, greaterThan(0));
      await tester.tap(find.text('显隐'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final mid = tester.getSize(find.byKey(const Key('toolbar-slot'))).height;
      expect(mid, greaterThan(0));
      expect(mid, lessThan(full));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(const Key('toolbar-slot'))).height, 0);

      visible = true;
      await pump(reduceMotion: true);
      await tester.pump();
      expect(
        tester.getSize(find.byKey(const Key('toolbar-slot'))).height,
        greaterThan(0),
      );
      await tester.tap(find.text('显隐'));
      await tester.pump();
      expect(tester.getSize(find.byKey(const Key('toolbar-slot'))).height, 0);
    });

    testWidgets(
      'bottom placement sits lower, and avoidHinge insets the group',
      (tester) async {
        await tester.pumpWidget(
          _app(
            home: const Scaffold(
              body: Column(
                children: [
                  LingyunToolbar(
                    placement: LingyunToolbarPlacement.top,
                    actions: [
                      LingyunToolbarAction(
                        icon: Icons.share_outlined,
                        label: '上',
                        onPressed: _noop,
                      ),
                    ],
                  ),
                  Spacer(),
                  LingyunToolbar(
                    placement: LingyunToolbarPlacement.bottom,
                    actions: [
                      LingyunToolbarAction(
                        icon: Icons.ios_share,
                        label: '下',
                        onPressed: _noop,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.byIcon(Icons.ios_share)).dy,
          greaterThan(tester.getTopLeft(find.byIcon(Icons.share_outlined)).dy),
        );

        await tester.pumpWidget(
          _app(
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(size: Size(800, 400)),
                child: const Column(
                  children: [
                    LingyunToolbar(
                      avoidHinge: false,
                      actions: [
                        LingyunToolbarAction(
                          icon: Icons.share_outlined,
                          label: '平',
                          onPressed: _noop,
                        ),
                      ],
                    ),
                    LingyunToolbar(
                      avoidHinge: true,
                      actions: [
                        LingyunToolbarAction(
                          icon: Icons.ios_share,
                          label: '让',
                          onPressed: _noop,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.byIcon(Icons.ios_share)).dx,
          lessThan(tester.getTopLeft(find.byIcon(Icons.share_outlined)).dx),
        );
      },
    );

    testWidgets('a disabled action does not fire', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: LingyunToolbar(
              actions: [
                LingyunToolbarAction(
                  icon: Icons.share_outlined,
                  label: '分享',
                  enabled: false,
                  onPressed: () => taps += 1,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pump();
      expect(taps, 0);
    });
  });
}

void _noop() {}

Widget _app({required Widget home, bool reduceMotion = false}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: LingyunMaterialTheme.themeData(Brightness.light)
        .copyWith(extensions: const [LiquidGlassTheme.light]),
    builder: (context, child) {
      return LingyunAdaptivity(
        reduceMotion: reduceMotion,
        child: LingyunTheme(brightness: Brightness.light, child: child!),
      );
    },
    home: home,
  );
}
