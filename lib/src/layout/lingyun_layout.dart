import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Adaptive width classes derived from the current **window / view** size.
///
/// These are not device-model checks and must not be treated as
/// `isIPhone` / `isIPad` / `isMac`. Measure [MediaQuery.sizeOf] (or a
/// [LayoutBuilder] constraint) so the same code works for:
///
/// * **iPhone** — typically [compact]
/// * **iPhone Duo** — outer cover [compact] or wide-short; inner display
///   [regular] (or [expanded]) with a center hinge/division band
/// * **iPad** — [expanded], including Split View columns that may drop to
///   [regular] or [compact]
/// * **macOS** — [large] (or smaller when the window is resized)
enum LingyunWidthClass {
  /// Width &lt; 600. Classic phone portrait, Duo outer cover.
  compact,

  /// 600–839. Duo inner display, large-phone landscape, iPad Split View.
  regular,

  /// 840–1199. Full iPad / large tablet.
  expanded,

  /// ≥ 1200. macOS / desktop windows.
  large,
}

/// Logical-pixel breakpoints for [LingyunWidthClass].
///
/// Aligned with Material 3 window size classes (compact / medium / expanded /
/// large) so existing Flutter size-class thinking applies.
class LingyunBreakpoints {
  const LingyunBreakpoints._();

  /// Lower bound of [LingyunWidthClass.regular].
  static const double regular = 600;

  /// Lower bound of [LingyunWidthClass.expanded].
  static const double expanded = 840;

  /// Lower bound of [LingyunWidthClass.large].
  static const double large = 1200;
}

/// Snapshot of adaptive layout metrics for the current view.
@immutable
class LingyunLayoutData {
  const LingyunLayoutData({
    required this.size,
    required this.widthClass,
    required this.safeArea,
    required this.layoutMargin,
    required this.hingeBand,
    required this.isWideShort,
    required this.avoidHinge,
  });

  final Size size;
  final LingyunWidthClass widthClass;
  final EdgeInsets safeArea;

  /// Safe area + recommended content margins for the width class.
  final EdgeInsets layoutMargin;

  /// Vertical center band that should stay free of interactive chrome.
  final Rect hingeBand;

  /// Wide and short — typical closed-foldable cover / landscape strip.
  final bool isWideShort;

  /// Whether chrome should stay out of [hingeBand].
  final bool avoidHinge;

  bool get isCompact => widthClass == LingyunWidthClass.compact;
  bool get isRegular => widthClass == LingyunWidthClass.regular;
  bool get isExpanded => widthClass == LingyunWidthClass.expanded;
  bool get isLarge => widthClass == LingyunWidthClass.large;
}

/// Size-class, safe-area, and hinge-avoidance helpers.
///
/// Public API talks about **width classes and geometry**, not hardware.
/// Comments mention iPhone / Duo / iPad / macOS only as examples of when
/// a given class typically appears.
class LingyunLayout {
  const LingyunLayout._();

  /// Center band as a fraction of width (used when [avoidHinge] is true).
  static const double hingeBandFraction = 0.07;

  /// Minimum hinge/division width so hit targets cannot sit on the seam.
  static const double hingeBandMinWidth = 28;

  /// Width / height ratio that counts as "wide and short".
  static const double wideShortAspect = 1.6;

  /// Height below which a wide window is treated as a closed-cover strip.
  static const double wideShortMaxHeight = 520;

  static LingyunWidthClass widthClassForWidth(double width) {
    if (width < LingyunBreakpoints.regular) return LingyunWidthClass.compact;
    if (width < LingyunBreakpoints.expanded) return LingyunWidthClass.regular;
    if (width < LingyunBreakpoints.large) return LingyunWidthClass.expanded;
    return LingyunWidthClass.large;
  }

  static LingyunWidthClass widthClassOf(BuildContext context) {
    return widthClassForWidth(MediaQuery.sizeOf(context).width);
  }

  static bool isCompactWidth(BuildContext context) {
    return widthClassOf(context) == LingyunWidthClass.compact;
  }

  static bool isRegularOrWider(BuildContext context) {
    return !isCompactWidth(context);
  }

  /// Closed foldable cover heuristic: wide and short, from [Size] only.
  static bool isWideShort(Size size) {
    if (size.height <= 0) return false;
    return size.width / size.height >= wideShortAspect &&
        size.height < wideShortMaxHeight;
  }

  /// Vertical center band in the coordinate space of [size].
  static Rect hingeBandOf(
    Size size, {
    double fraction = hingeBandFraction,
    double minWidth = hingeBandMinWidth,
  }) {
    final width = math.max(minWidth, size.width * fraction);
    final left = (size.width - width) / 2;
    return Rect.fromLTWH(left, 0, width, size.height);
  }

  /// Avoid the center band on regular+ widths (Duo inner, iPad, desktop
  /// split) and on wide-short covers (closed Duo). Compact phone portrait
  /// has no hinge.
  static bool shouldAvoidHinge(Size size) {
    return widthClassForWidth(size.width) != LingyunWidthClass.compact ||
        isWideShort(size);
  }

  static EdgeInsets safeAreaOf(BuildContext context) {
    return MediaQuery.paddingOf(context);
  }

  /// Content margins: safe area + width-class gutters.
  static EdgeInsets layoutMarginOf(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return layoutMarginFor(size, MediaQuery.paddingOf(context));
  }

  static EdgeInsets layoutMarginFor(Size size, EdgeInsets safeArea) {
    final gutter = switch (widthClassForWidth(size.width)) {
      LingyunWidthClass.compact => 16.0,
      LingyunWidthClass.regular => 20.0,
      LingyunWidthClass.expanded => 24.0,
      LingyunWidthClass.large => 32.0,
    };
    return EdgeInsets.fromLTRB(
      safeArea.left + gutter,
      safeArea.top + 12,
      safeArea.right + gutter,
      safeArea.bottom + 12,
    );
  }

  /// Extra leading/trailing inset that keeps chrome off the hinge band.
  static EdgeInsets chromeInsetsFor(Size size) {
    if (!shouldAvoidHinge(size)) {
      return EdgeInsets.zero;
    }
    final hinge = hingeBandOf(size);
    final side = math.max(0.0, (size.width - hinge.width) / 2);
    // Keep chrome in the outer 28% of each remaining wing, not the inner edge.
    final wing = side * 0.08;
    return EdgeInsets.only(left: wing, right: wing);
  }

  static LingyunLayoutData dataOf(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safe = MediaQuery.paddingOf(context);
    return dataFor(size, safeArea: safe);
  }

  static LingyunLayoutData dataFor(
    Size size, {
    EdgeInsets safeArea = EdgeInsets.zero,
  }) {
    return LingyunLayoutData(
      size: size,
      widthClass: widthClassForWidth(size.width),
      safeArea: safeArea,
      layoutMargin: layoutMarginFor(size, safeArea),
      hingeBand: hingeBandOf(size),
      isWideShort: isWideShort(size),
      avoidHinge: shouldAvoidHinge(size),
    );
  }
}

/// Rebuilds when the window size class or hinge geometry changes.
class LingyunLayoutBuilder extends StatelessWidget {
  const LingyunLayoutBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, LingyunLayoutData data) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : mq.size.width,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : mq.size.height,
        );
        return builder(
          context,
          LingyunLayout.dataFor(size, safeArea: mq.padding),
        );
      },
    );
  }
}

/// Positions [leading] / [trailing] on the side edges and never in the
/// center hinge/division band.
///
/// Use this for closed Duo (wide-short) edge controls and for inner-display
/// or iPad chrome that should stay off the seam. Compact phone layouts can
/// still use it; the hinge inset is then zero.
class LingyunSideChrome extends StatelessWidget {
  const LingyunSideChrome({
    super.key,
    this.leading,
    this.trailing,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  });

  final Widget? leading;
  final Widget? trailing;
  final Widget? child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LingyunLayoutBuilder(
      builder: (context, data) {
        final hingeInset = data.avoidHinge ? data.hingeBand.width / 2 : 0.0;
        return Padding(
          padding: padding,
          child: Stack(
            children: [
              if (child != null)
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hingeInset),
                    child: child,
                  ),
                ),
              if (leading != null)
                Align(alignment: Alignment.centerLeft, child: leading),
              if (trailing != null)
                Align(alignment: Alignment.centerRight, child: trailing),
            ],
          ),
        );
      },
    );
  }
}

/// Two-pane body that keeps a non-interactive gutter on the hinge band
/// when [LingyunLayoutData.avoidHinge] is true; otherwise stacks or
/// stretches a single [child].
class LingyunSplitBody extends StatelessWidget {
  const LingyunSplitBody({
    super.key,
    required this.leading,
    required this.trailing,
    this.gutterColor = const Color(0x33FFFFFF),
  });

  final Widget leading;
  final Widget trailing;
  final Color gutterColor;

  @override
  Widget build(BuildContext context) {
    return LingyunLayoutBuilder(
      builder: (context, data) {
        if (!data.avoidHinge || data.isCompact && !data.isWideShort) {
          return leading;
        }
        final hinge = data.hingeBand;
        return Row(
          children: [
            Expanded(child: leading),
            SizedBox(
              width: hinge.width,
              child: DecoratedBox(
                decoration: BoxDecoration(color: gutterColor),
                child: const IgnorePointer(child: SizedBox.expand()),
              ),
            ),
            Expanded(child: trailing),
          ],
        );
      },
    );
  }
}
