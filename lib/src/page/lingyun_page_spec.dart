import 'package:flutter/foundation.dart';

/// Tab, sidebar, or no chrome. Matches native `LYPageChrome`.
///
/// This is the iOS host contract. FlutterUI's `LingyunPage` widget is not
/// defined here.
enum LingyunPageChrome { tab, sidebar, none }

/// Stack, split, or a system arrangement. Matches native `LYPageNavigation`.
///
/// Arrangement is not a Duo pose. Half-open and fully open share Regular;
/// the hinge is a reserved region.
enum LingyunPageNavigation {
  stack,
  split,
  arrangementSplit,
  arrangementOverlay,
}

/// Horizontal size class plus available width.
///
/// [compact] is a compact horizontal size class (folded outer display
/// included). [regular] and [wide] are regular. [wide] also requires
/// available width >= `LingyunBreakpoints.large` (1200). That cut is the
/// existing Dart breakpoint, not an iOS kit token. Vertical size class is
/// not part of the bucket.
enum LingyunPageWidthBucket { compact, regular, wide }

/// Content roles for the native page host.
@immutable
class LingyunPageSpec {
  const LingyunPageSpec({
    this.chrome = LingyunPageChrome.tab,
    this.navigation = LingyunPageNavigation.stack,
    this.primaryLabel = 'Primary',
    this.secondaryLabel = 'Secondary',
  });

  final LingyunPageChrome chrome;
  final LingyunPageNavigation navigation;
  final String primaryLabel;
  final String secondaryLabel;

  bool get requestsArrangement =>
      navigation == LingyunPageNavigation.arrangementSplit ||
      navigation == LingyunPageNavigation.arrangementOverlay;

  Map<String, String> toWire() {
    return {
      'chrome': chrome.name,
      'navigation': navigation.name,
      'primaryLabel': primaryLabel,
      'secondaryLabel': secondaryLabel,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is LingyunPageSpec &&
        other.chrome == chrome &&
        other.navigation == navigation &&
        other.primaryLabel == primaryLabel &&
        other.secondaryLabel == secondaryLabel;
  }

  @override
  int get hashCode =>
      Object.hash(chrome, navigation, primaryLabel, secondaryLabel);
}

/// System container selected for a [LingyunPageSpec].
///
/// Mirrors `LYPageContainer.resolve` in `ios/Classes/LYPage/LYPageContainer.swift`.
@immutable
class LingyunPageContainer {
  const LingyunPageContainer({
    required this.root,
    required this.wrapsTabView,
    required this.wrapsSplitView,
    required this.usesArrangement,
    required this.columns,
    required this.chromeApplied,
    required this.note,
  });

  /// `TabView`, `NavigationSplitView`, `NavigationStack`, or `ArrangementView`.
  final String root;
  final bool wrapsTabView;
  final bool wrapsSplitView;
  final bool usesArrangement;
  final int columns;
  final bool chromeApplied;
  final String note;

  static const arrangementNote =
      'ArrangementView stays outside TabView and NavigationSplitView. '
      'A NavigationStack may wrap the arrangement. '
      'The iOS 27.1 compile flag LY_IOS_27_1_SDK links the system type. '
      'Without it this host does not invent a hinge layout.';

  static const splitNote =
      'NavigationSplitView collapses to one column when the horizontal size '
      'class is compact. Wide (regular, and available width >= '
      'LingyunBreakpoints.large) adds a third column only when chrome is '
      'sidebar. Tab chrome keeps two columns so the tab bar is not also a sidebar.';

  static const tabNote =
      'TabView is the system tab bar. On an iOS 27.1 build it may sit on the '
      'side. Content uses each safe-area edge and does not assume a bottom dock.';

  static const stackNote =
      'NavigationStack fills the available bounds. Safe area is per edge.';
}

/// Pure mapping used by the example notes and by the native host.
LingyunPageContainer resolveLingyunPageContainer(
  LingyunPageSpec spec, {
  LingyunPageWidthBucket bucket = LingyunPageWidthBucket.regular,
}) {
  if (spec.requestsArrangement) {
    return const LingyunPageContainer(
      root: 'ArrangementView',
      wrapsTabView: false,
      wrapsSplitView: false,
      usesArrangement: true,
      columns: 0,
      chromeApplied: false,
      note: LingyunPageContainer.arrangementNote,
    );
  }

  final sidebar = spec.chrome == LingyunPageChrome.sidebar;
  final split = spec.navigation == LingyunPageNavigation.split || sidebar;

  if (spec.chrome == LingyunPageChrome.tab) {
    if (split) {
      return LingyunPageContainer(
        root: 'TabView',
        wrapsTabView: true,
        wrapsSplitView: true,
        usesArrangement: false,
        columns: _splitColumns(bucket, allowThree: false),
        chromeApplied: true,
        note:
            '${LingyunPageContainer.tabNote} ${LingyunPageContainer.splitNote}',
      );
    }
    return const LingyunPageContainer(
      root: 'TabView',
      wrapsTabView: true,
      wrapsSplitView: false,
      usesArrangement: false,
      columns: 1,
      chromeApplied: true,
      note: LingyunPageContainer.tabNote,
    );
  }

  if (split) {
    return LingyunPageContainer(
      root: 'NavigationSplitView',
      wrapsTabView: false,
      wrapsSplitView: true,
      usesArrangement: false,
      columns: _splitColumns(bucket, allowThree: sidebar),
      chromeApplied: sidebar,
      note: LingyunPageContainer.splitNote,
    );
  }

  return const LingyunPageContainer(
    root: 'NavigationStack',
    wrapsTabView: false,
    wrapsSplitView: false,
    usesArrangement: false,
    columns: 1,
    chromeApplied: false,
    note: LingyunPageContainer.stackNote,
  );
}

int _splitColumns(LingyunPageWidthBucket bucket, {required bool allowThree}) {
  switch (bucket) {
    case LingyunPageWidthBucket.compact:
      return 1;
    case LingyunPageWidthBucket.regular:
      return 2;
    case LingyunPageWidthBucket.wide:
      return allowThree ? 3 : 2;
  }
}

/// One reserved region reported by the iOS 27.1 SDK.
///
/// [frame] is in the platform view's coordinates and already includes the
/// system's margins. Kind is `division` (hinge) or `occlusion` (camera).
@immutable
class LingyunPageRegion {
  const LingyunPageRegion({
    required this.kind,
    required this.isActive,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final String kind;
  final bool isActive;
  final double x;
  final double y;
  final double width;
  final double height;
}

/// Metrics pushed by the native host. Absent on non-iOS runs.
@immutable
class LingyunPageSnapshot {
  const LingyunPageSnapshot({
    required this.chrome,
    required this.navigation,
    required this.widthBucket,
    required this.horizontalSizeClass,
    required this.verticalSizeClass,
    required this.boundsWidth,
    required this.boundsHeight,
    required this.safeLeading,
    required this.safeTrailing,
    required this.safeTop,
    required this.safeBottom,
    required this.contentSafeLeading,
    required this.contentSafeTrailing,
    required this.contentSafeTop,
    required this.contentSafeBottom,
    required this.arrangementLinked,
    required this.reservedRegionsSupported,
    required this.regions,
    required this.root,
    required this.mountedRoot,
    required this.wrapsTabView,
    required this.wrapsSplitView,
    required this.usesArrangement,
    required this.columns,
    required this.chromeApplied,
    required this.note,
  });

  final String chrome;
  final String navigation;
  final String widthBucket;
  final String horizontalSizeClass;
  final String verticalSizeClass;
  final double boundsWidth;
  final double boundsHeight;
  final double safeLeading;
  final double safeTrailing;
  final double safeTop;
  final double safeBottom;
  final double contentSafeLeading;
  final double contentSafeTrailing;
  final double contentSafeTop;
  final double contentSafeBottom;
  final bool arrangementLinked;
  final bool reservedRegionsSupported;
  final List<LingyunPageRegion> regions;
  final String root;
  final String mountedRoot;
  final bool wrapsTabView;
  final bool wrapsSplitView;
  final bool usesArrangement;
  final int columns;
  final bool chromeApplied;
  final String note;

  static LingyunPageSnapshot? fromWire(Object? raw) {
    if (raw is! Map) return null;
    final regions = <LingyunPageRegion>[];
    final listed = raw['regions'];
    if (listed is List) {
      for (final item in listed) {
        if (item is! Map) continue;
        regions.add(
          LingyunPageRegion(
            kind: item['kind']?.toString() ?? '',
            isActive: item['isActive'] == true,
            x: _asDouble(item['x']),
            y: _asDouble(item['y']),
            width: _asDouble(item['width']),
            height: _asDouble(item['height']),
          ),
        );
      }
    }
    return LingyunPageSnapshot(
      chrome: raw['chrome']?.toString() ?? '',
      navigation: raw['navigation']?.toString() ?? '',
      widthBucket: raw['widthBucket']?.toString() ?? '',
      horizontalSizeClass: raw['horizontalSizeClass']?.toString() ?? '',
      verticalSizeClass: raw['verticalSizeClass']?.toString() ?? '',
      boundsWidth: _asDouble(raw['boundsWidth']),
      boundsHeight: _asDouble(raw['boundsHeight']),
      safeLeading: _asDouble(raw['safeLeading']),
      safeTrailing: _asDouble(raw['safeTrailing']),
      safeTop: _asDouble(raw['safeTop']),
      safeBottom: _asDouble(raw['safeBottom']),
      contentSafeLeading: _asDouble(raw['contentSafeLeading']),
      contentSafeTrailing: _asDouble(raw['contentSafeTrailing']),
      contentSafeTop: _asDouble(raw['contentSafeTop']),
      contentSafeBottom: _asDouble(raw['contentSafeBottom']),
      arrangementLinked: raw['arrangementLinked'] == true,
      reservedRegionsSupported: raw['reservedRegionsSupported'] == true,
      regions: regions,
      root: raw['root']?.toString() ?? '',
      mountedRoot: raw['mountedRoot']?.toString() ?? '',
      wrapsTabView: raw['wrapsTabView'] == true,
      wrapsSplitView: raw['wrapsSplitView'] == true,
      usesArrangement: raw['usesArrangement'] == true,
      columns: _asInt(raw['columns']),
      chromeApplied: raw['chromeApplied'] == true,
      note: raw['note']?.toString() ?? '',
    );
  }
}

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return 0;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  return 0;
}
