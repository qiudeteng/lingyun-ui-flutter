import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

void main() {
  test('container map follows size class buckets, not a Duo pose', () {
    const spec = LingyunPageSpec();
    expect(spec.requestsArrangement, isFalse);
    expect(LingyunPageChrome.values.map((e) => e.name), [
      'tab',
      'sidebar',
      'none',
    ]);
    expect(LingyunPageNavigation.values.map((e) => e.name), [
      'stack',
      'split',
      'arrangementSplit',
      'arrangementOverlay',
    ]);
    expect(LingyunPageWidthBucket.values.map((e) => e.name), [
      'compact',
      'regular',
      'wide',
    ]);

    expect(
      _resolve(LingyunPageChrome.tab, LingyunPageNavigation.stack).root,
      'TabView',
    );
    expect(
      _resolve(
        LingyunPageChrome.tab,
        LingyunPageNavigation.split,
        LingyunPageWidthBucket.regular,
      ).columns,
      2,
    );
    expect(
      _resolve(
        LingyunPageChrome.tab,
        LingyunPageNavigation.split,
        LingyunPageWidthBucket.wide,
      ).columns,
      2,
    );

    final sidebarWide = _resolve(
      LingyunPageChrome.sidebar,
      LingyunPageNavigation.split,
      LingyunPageWidthBucket.wide,
    );
    expect(sidebarWide.root, 'NavigationSplitView');
    expect(sidebarWide.columns, 3);
    expect(sidebarWide.chromeApplied, isTrue);

    final sidebarCompact = _resolve(
      LingyunPageChrome.sidebar,
      LingyunPageNavigation.stack,
      LingyunPageWidthBucket.compact,
    );
    expect(sidebarCompact.root, 'NavigationSplitView');
    expect(sidebarCompact.columns, 1);

    final plainWide = _resolve(
      LingyunPageChrome.none,
      LingyunPageNavigation.split,
      LingyunPageWidthBucket.wide,
    );
    expect(plainWide.columns, 2);
    expect(plainWide.chromeApplied, isFalse);

    for (final chrome in LingyunPageChrome.values) {
      for (final bucket in LingyunPageWidthBucket.values) {
        final split = _resolve(
          chrome,
          LingyunPageNavigation.arrangementSplit,
          bucket,
        );
        final overlay = _resolve(
          chrome,
          LingyunPageNavigation.arrangementOverlay,
          bucket,
        );
        for (final container in [split, overlay]) {
          expect(container.root, 'ArrangementView');
          expect(container.usesArrangement, isTrue);
          expect(container.wrapsTabView, isFalse);
          expect(container.wrapsSplitView, isFalse);
          expect(container.chromeApplied, isFalse);
          expect(container.columns, 0);
        }
      }
    }

    expect(
      _resolve(LingyunPageChrome.none, LingyunPageNavigation.stack).root,
      'NavigationStack',
    );
  });

  test('wide threshold matches LingyunBreakpoints.large', () {
    expect(LingyunBreakpoints.large, 1200);
    final metrics = File('ios/Classes/LYPage/LYPageMetrics.swift')
        .readAsStringSync();
    expect(
      metrics,
      contains(
        'static let wideMinimumPoints: CGFloat = ${LingyunBreakpoints.large.toStringAsFixed(0)}',
      ),
    );
  });

  test('snapshot wire parses host and content insets', () {
    final snapshot = LingyunPageSnapshot.fromWire({
      'chrome': 'tab',
      'navigation': 'stack',
      'widthBucket': 'compact',
      'horizontalSizeClass': 'compact',
      'verticalSizeClass': 'regular',
      'boundsWidth': 400,
      'boundsHeight': 700,
      'safeLeading': 0,
      'safeTrailing': 12,
      'safeTop': 54,
      'safeBottom': 21,
      'contentSafeLeading': 8,
      'contentSafeTrailing': 40,
      'contentSafeTop': 0,
      'contentSafeBottom': 0,
      'arrangementLinked': false,
      'reservedRegionsSupported': true,
      'regions': [
        {
          'kind': 'division',
          'isActive': false,
          'x': 0,
          'y': 0,
          'width': 0,
          'height': 700,
        },
      ],
      'root': 'TabView',
      'mountedRoot': 'TabView',
      'wrapsTabView': true,
      'wrapsSplitView': false,
      'usesArrangement': false,
      'columns': 1,
      'chromeApplied': true,
      'note': 'safe area',
    });
    expect(snapshot, isNotNull);
    expect(snapshot!.widthBucket, 'compact');
    expect(snapshot.safeTrailing, 12);
    expect(snapshot.contentSafeTrailing, 40);
    expect(snapshot.regions.single.kind, 'division');
    expect(snapshot.regions.single.isActive, isFalse);
    expect(snapshot.mountedRoot, 'TabView');
  });

  test('iOS sources avoid screen, idiom, and orientation layout', () {
    final swiftFiles = Directory('ios/Classes')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.swift'))
        .toList();
    expect(swiftFiles, isNotEmpty);

    final banned = [
      'UIScreen',
      'userInterfaceIdiom',
      'UIDevice',
      'UIInterfaceOrientation',
      'statusBarOrientation',
      'DuoPose',
      'foldedPortrait',
      'halfOpen',
    ];
    final outside = StringBuffer();
    final inside = StringBuffer();
    for (final file in swiftFiles) {
      final stripped = _stripComments(file.readAsStringSync());
      final split = _splitSdkFlag(stripped);
      outside.write(split.outside);
      inside.write(split.inside);
      final code = split.outside + split.inside;
      for (final token in banned) {
        expect(code.contains(token), isFalse, reason: '${file.path} $token');
      }
      expect(code.contains(RegExp(r'\b(390|844|466|678|669|951)\b')), isFalse);
    }

    expect(inside.toString(), contains('ArrangementView {'));
    expect(inside.toString(), contains('UIArrangementViewController'));
    expect(inside.toString(), contains('reservedRegions('));
    expect(inside.toString(), contains('UISplitArrangement'));
    expect(inside.toString(), contains('UIOverlayArrangement'));
    expect(outside.toString().contains('ArrangementView {'), isFalse);
    expect(outside.toString().contains('UIArrangementViewController'), isFalse);
    expect(outside.toString().contains('reservedRegions('), isFalse);
    expect(outside.toString().contains('UISplitArrangement'), isFalse);
    expect(outside.toString().contains('UIOverlayArrangement'), isFalse);
  });
}

LingyunPageContainer _resolve(
  LingyunPageChrome chrome,
  LingyunPageNavigation navigation, [
  LingyunPageWidthBucket bucket = LingyunPageWidthBucket.regular,
]) {
  return resolveLingyunPageContainer(
    LingyunPageSpec(chrome: chrome, navigation: navigation),
    bucket: bucket,
  );
}

String _stripComments(String source) {
  final withoutBlock = source.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return withoutBlock
      .split('\n')
      .map((line) {
        final index = line.indexOf('//');
        return index == -1 ? line : line.substring(0, index);
      })
      .join('\n');
}

class _SdkSplit {
  String outside = '';
  String inside = '';
}

_SdkSplit _splitSdkFlag(String source) {
  final split = _SdkSplit();
  var depth = 0;
  var sdkBranch = false;
  final outside = StringBuffer();
  final inside = StringBuffer();
  for (final line in source.split('\n')) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('#if LY_IOS_27_1_SDK')) {
      depth += 1;
      sdkBranch = true;
      continue;
    }
    if (trimmed.startsWith('#else') && depth > 0) {
      sdkBranch = false;
      continue;
    }
    if (trimmed.startsWith('#endif') && depth > 0) {
      depth -= 1;
      sdkBranch = false;
      continue;
    }
    if (depth > 0 && sdkBranch) {
      inside.writeln(line);
    } else {
      outside.writeln(line);
    }
  }
  split.outside = outside.toString();
  split.inside = inside.toString();
  return split;
}
