import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show Theme;

import '../page/lingyun_page.dart';
import '../page/lingyun_page_spec.dart';
import '../theme/lingyun_theme.dart';
import '../tokens/glass_material.dart';
import '../tokens/lingyun_colors.dart';
import '../tokens/lingyun_text_styles.dart';
import '../tokens/liquid_glass_motion.dart';
import 'glass_surface.dart';

/// Height stops for a sheet.
///
/// Fractions live on [LingyunSheetLayout]. They are implementation
/// approximations (待核验 vs Sketch Sheets), not kit tokens.
enum LingyunSheetDetent {
  /// About half the height above the keyboard.
  medium,

  /// Fills the stage except a top peek so the page behind still shows.
  large,
}

/// Sheet geometry that is not a Design Token.
///
/// Sketch Sheets was not measured in this change. Numbers below are working
/// steps: the top gap and grabber match the comments in `cupertino_ui`'s
/// sheet (iOS 18 eyeball / Apple Figma), and the corner reuses
/// [LiquidGlassRadii.large], which this repo already marks 待核验 for sheets.
/// Change them here when design measures the kit page.
abstract final class LingyunSheetLayout {
  /// Medium detent as a fraction of the height above the keyboard.
  ///
  /// Half is the usual system description. 待核验 vs Sketch.
  static const double mediumFraction = 0.5;

  /// Uncovered top of a large detent, as a fraction of the stage.
  ///
  /// Same ratio `cupertino_ui` documents for its sheet top gap (0.08,
  /// eyeballed on iOS 18). The gap is also at least the top safe area.
  /// 待核验 vs Sketch iOS 27.
  static const double largeTopGapFraction = 0.08;

  /// Width cap for a regular or wide sheet. 待核验. Not a device check.
  static const double regularMaxWidth = 704;

  /// Side margin on regular / wide, outside the safe area. 待核验.
  static const double regularSideMargin = 20;

  /// Gap under a regular / wide sheet, above the bottom safe area. 待核验.
  ///
  /// Compact sheets stay attached to the bottom, or to the keyboard.
  static const double regularBottomGap = 12;

  /// Grabber pill. `cupertino_ui` sheet comments cite Apple's Figma / iOS 18.2.
  /// 待核验 vs Sketch.
  static const double grabberWidth = 36;
  static const double grabberHeight = 5;
  static const double grabberTopPadding = 5;

  /// Row that holds the pill. Taller than the pill so it can be dragged.
  static const double grabberSlotHeight = 28;

  /// Smallest platter while a drag is in progress, so the pill does not overflow.
  static const double minVisualHeight = 36;

  /// Release below this fraction of the shortest detent to dismiss.
  static const double dismissFraction = 0.55;

  /// Horizontal padding inside the scrolling content. 待核验.
  static const double contentHorizontalPadding = 20;

  /// Dim over the page behind the sheet. Not the alert barrier, not a token.
  /// 待核验.
  static const Color lightBarrier = Color(0x33000000);
  static const Color darkBarrier = Color(0x59000000);

  static BorderRadius borderRadius({required bool attachedToBottom}) {
    final radius = Radius.circular(LiquidGlassRadii.large);
    if (attachedToBottom) {
      return BorderRadius.vertical(top: radius);
    }
    return BorderRadius.all(radius);
  }
}

/// Size of one sheet for the current bounds, safe area, and keyboard.
///
/// [bucket] uses [resolveFlutterPageBucket]. Pass [horizontalSizeClass]
/// (`compact`, `regular`, `unspecified`, or null) the same way [LingyunPage]
/// does. Null means Flutter has no system class and the width is a proxy.
/// This does not read a device idiom.
@immutable
class LingyunSheetMetrics {
  const LingyunSheetMetrics({
    required this.bounds,
    required this.safeArea,
    required this.keyboardInset,
    this.horizontalSizeClass,
  });

  final Size bounds;
  final EdgeInsets safeArea;

  /// `MediaQuery.viewInsets.bottom`. The sheet's bottom edge sits on it.
  final double keyboardInset;

  /// `compact`, `regular`, `unspecified`, or null. See [LingyunPage].
  final String? horizontalSizeClass;

  LingyunPageWidthBucket get bucket {
    assert(
      horizontalSizeClass == null ||
          horizontalSizeClass == 'compact' ||
          horizontalSizeClass == 'regular' ||
          horizontalSizeClass == 'unspecified',
      'horizontalSizeClass must be compact, regular, unspecified, or null.',
    );
    final known =
        horizontalSizeClass == 'compact' ||
            horizontalSizeClass == 'regular' ||
            horizontalSizeClass == 'unspecified'
        ? horizontalSizeClass
        : null;
    return resolveFlutterPageBucket(
      width: bounds.width,
      horizontalSizeClass: known,
    );
  }

  bool get isCompact => bucket == LingyunPageWidthBucket.compact;

  /// Compact sheets meet the bottom (or the keyboard) with square bottom corners.
  bool get attachedToBottom => isCompact;

  /// Height available above the keyboard, before the top peek.
  double get stageHeight => math.max(0.0, bounds.height - keyboardInset);

  double get topInset => math.max(
    safeArea.top,
    stageHeight * LingyunSheetLayout.largeTopGapFraction,
  );

  /// Distance from the screen bottom to the sheet's bottom edge.
  double get bottomOffset {
    final floating = isCompact
        ? 0.0
        : safeArea.bottom + LingyunSheetLayout.regularBottomGap;
    return math.max(keyboardInset, floating);
  }

  double get width {
    if (isCompact) return bounds.width;
    final available = math.max(
      0.0,
      bounds.width -
          safeArea.left -
          safeArea.right -
          LingyunSheetLayout.regularSideMargin * 2,
    );
    return math.min(available, LingyunSheetLayout.regularMaxWidth);
  }

  double get left {
    if (isCompact) return 0;
    final side = LingyunSheetLayout.regularSideMargin;
    final minLeft = safeArea.left + side;
    final maxLeft = math.max(
      minLeft,
      bounds.width - safeArea.right - side - width,
    );
    return ((bounds.width - width) / 2).clamp(minLeft, maxLeft).toDouble();
  }

  BorderRadius get borderRadius =>
      LingyunSheetLayout.borderRadius(attachedToBottom: attachedToBottom);

  /// Sheet height for [detent], never taller than the large stop.
  double heightFor(LingyunSheetDetent detent) {
    final maxHeight = math.max(0.0, bounds.height - bottomOffset - topInset);
    final medium = stageHeight * LingyunSheetLayout.mediumFraction;
    final raw = switch (detent) {
      LingyunSheetDetent.medium => medium,
      LingyunSheetDetent.large => maxHeight,
    };
    if (maxHeight <= 0) return 0;
    return raw.clamp(0.0, maxHeight);
  }
}

/// Which detent a presented sheet is on.
///
/// [animateTo] asks the open sheet to move. Dragging the grabber updates
/// [detent] after the finger lifts.
class LingyunSheetController extends ChangeNotifier {
  LingyunSheetController({
    LingyunSheetDetent initialDetent = LingyunSheetDetent.medium,
  }) : _detent = initialDetent;

  LingyunSheetDetent _detent;

  LingyunSheetDetent get detent => _detent;

  /// Animate the open sheet to [detent].
  void animateTo(LingyunSheetDetent detent) {
    if (_detent == detent) return;
    _detent = detent;
    notifyListeners();
  }

  void _adopt(LingyunSheetDetent detent) {
    if (_detent == detent) return;
    _detent = detent;
    notifyListeners();
  }
}

/// Materials Thick platter.
///
/// The parent supplies the size. Chrome is [GlassSurface] with
/// `material: MaterialTier.thick` and no token override, so a later
/// Materials fix shows up here without a recipe change in this file.
///
/// [grabber] replaces the static pill when the sheet route needs a drag handle.
class LingyunSheet extends StatelessWidget {
  const LingyunSheet({
    super.key,
    required this.child,
    this.showGrabber = true,
    this.attachedToBottom = true,
    this.grabberLabel = 'Drag handle',
    this.grabberKey,
    this.grabber,
  });

  final Widget child;
  final bool showGrabber;

  /// Square bottom corners when the sheet sits on the screen or the keyboard.
  final bool attachedToBottom;

  final String grabberLabel;
  final Key? grabberKey;

  /// Interactive grabber. Null paints a static pill.
  final Widget? grabber;

  @override
  Widget build(BuildContext context) {
    final radius = LingyunSheetLayout.borderRadius(
      attachedToBottom: attachedToBottom,
    );
    return GlassSurface(
      material: MaterialTier.thick,
      borderRadius: radius,
      enableHoverHighlight: false,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = showGrabber ? LingyunSheetLayout.grabberSlotHeight : 0.0;
          final showBody = constraints.maxHeight > slot + 1;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (showBody)
                Positioned(
                  top: slot,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: child,
                ),
              if (showGrabber)
                Align(
                  alignment: Alignment.topCenter,
                  child:
                      grabber ??
                      _SheetGrabber(label: grabberLabel, key: grabberKey),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = LingyunTheme.colorsOf(context).grays.gray;
    return Semantics(
      label: label,
      container: true,
      child: SizedBox(
        height: LingyunSheetLayout.grabberSlotHeight,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(
            top: LingyunSheetLayout.grabberTopPadding,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(
                  LingyunSheetLayout.grabberHeight / 2,
                ),
              ),
              child: const SizedBox(
                width: LingyunSheetLayout.grabberWidth,
                height: LingyunSheetLayout.grabberHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef LingyunSheetBuilder = Widget Function(
  BuildContext context,
  LingyunSheetController controller,
);

/// Paints something for the sheet's [BackdropFilter] to sample.
///
/// [platter] is the glass rect in the route, in logical pixels. A modal
/// route keeps its own compositing layer, so on Impeller the filter does
/// not see the page underneath. Paint the preview in this builder and it
/// sits in that same layer, behind the platter. Null leaves the route
/// empty and the filter samples whatever else is already there.
typedef LingyunSheetBackdropBuilder = Widget Function(
  BuildContext context,
  LingyunSheetMetrics metrics,
  Rect platter,
);

/// Presents a sheet and returns the value passed to [Navigator.pop].
///
/// Chrome is Materials Thick ([LingyunSheet]). The host needs a Material
/// [Theme] so [GlassSurface] can resolve that tier — the example gallery
/// already has one. Brightness follows that theme, and the route installs
/// [LingyunTheme] so content can use the Sketch color and text catalogs.
///
/// Compact buckets are full width and attached to the bottom. Regular and
/// wide buckets are inset cards capped by [LingyunSheetLayout.regularMaxWidth].
/// The bucket is [resolveFlutterPageBucket], not a device idiom.
///
/// The sheet's own scroll view tracks the finger: drag up grows the detent
/// before the content scrolls; drag down at the top shrinks it. A fling's
/// leftover velocity is not handed to the sheet (待核验 against the system).
/// The bottom edge follows `MediaQuery.viewInsets.bottom`. A medium detent
/// is not promoted to large when the keyboard opens (待核验).
///
/// Outside taps dismiss when [barrierDismissible] is true. The dim is
/// [LingyunSheetLayout.lightBarrier] / [darkBarrier], 待核验, and is not the
/// alert barrier.
///
/// [backdrop] is painted in the sheet route, behind the platter. Use it
/// when the preview has to be in the same layer as the blur. On Impeller a
/// modal route does not sample the page underneath.
Future<T?> showLingyunSheet<T>(
  BuildContext context, {
  required LingyunSheetBuilder builder,
  List<LingyunSheetDetent> detents = const [
    LingyunSheetDetent.medium,
    LingyunSheetDetent.large,
  ],
  LingyunSheetDetent? initialDetent,
  bool showGrabber = true,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  LingyunSheetController? controller,
  String? horizontalSizeClass,
  String? barrierLabel,
  String grabberLabel = 'Drag handle',
  String semanticsLabel = 'Sheet',
  LingyunSheetBackdropBuilder? backdrop,
}) {
  final ordered = List<LingyunSheetDetent>.of(detents)
    ..sort((a, b) => a.index.compareTo(b.index));
  assert(ordered.isNotEmpty, 'Provide at least one detent.');
  assert(ordered.toSet().length == ordered.length, 'Detents must not repeat.');
  final initial = initialDetent ?? controller?.detent ?? ordered.first;
  assert(ordered.contains(initial), 'initialDetent must be one of detents.');
  final ownsController = controller == null;
  final effective =
      controller ?? LingyunSheetController(initialDetent: initial);
  if (effective.detent != initial) {
    effective._adopt(initial);
  }
  final brightness = Theme.of(context).brightness;
  final duration = LiquidGlassMotion.durationOf(
    context,
    LiquidGlassMotion.defaults.standard,
  );
  final label =
      barrierLabel ??
      Localizations.of<CupertinoLocalizations>(
        context,
        CupertinoLocalizations,
      )?.modalBarrierDismissLabel ??
      DefaultCupertinoLocalizations().modalBarrierDismissLabel;
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    _LingyunSheetRoute<T>(
      builder: builder,
      detents: ordered,
      sheetController: effective,
      ownsController: ownsController,
      showGrabber: showGrabber,
      dismissible: barrierDismissible,
      brightness: brightness,
      duration: duration,
      barrierLabelText: label,
      horizontalSizeClass: horizontalSizeClass,
      grabberLabel: grabberLabel,
      semanticsLabel: semanticsLabel,
      backdrop: backdrop,
    ),
  );
}

class _LingyunSheetRoute<T> extends PopupRoute<T> {
  _LingyunSheetRoute({
    required this.builder,
    required this.detents,
    required this.sheetController,
    required this.ownsController,
    required this.showGrabber,
    required this.dismissible,
    required this.brightness,
    required this.duration,
    required this.barrierLabelText,
    required this.horizontalSizeClass,
    required this.grabberLabel,
    required this.semanticsLabel,
    required this.backdrop,
  });

  final LingyunSheetBuilder builder;
  final List<LingyunSheetDetent> detents;
  final LingyunSheetController sheetController;
  final bool ownsController;
  final bool showGrabber;
  final bool dismissible;
  final Brightness brightness;
  final Duration duration;
  final String barrierLabelText;
  final String? horizontalSizeClass;
  final String grabberLabel;
  final String semanticsLabel;
  final LingyunSheetBackdropBuilder? backdrop;

  @override
  Color get barrierColor => brightness == Brightness.dark
      ? LingyunSheetLayout.darkBarrier
      : LingyunSheetLayout.lightBarrier;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => barrierLabelText;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _withCupertinoLocalizations(
      context,
      _LingyunSheetPanel(
        builder: builder,
        detents: detents,
        controller: sheetController,
        ownsController: ownsController,
        showGrabber: showGrabber,
        dismissible: dismissible,
        horizontalSizeClass: horizontalSizeClass,
        grabberLabel: grabberLabel,
        semanticsLabel: semanticsLabel,
        backdrop: backdrop,
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.standardCurve,
    );
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve)),
      ),
      child: child,
    );
  }
}

Widget _withCupertinoLocalizations(BuildContext context, Widget child) {
  if (Localizations.of<CupertinoLocalizations>(
        context,
        CupertinoLocalizations,
      ) !=
      null) {
    return child;
  }
  final locale = Localizations.maybeLocaleOf(context);
  final resolved =
      locale != null &&
          kCupertinoSupportedLanguages.contains(locale.languageCode)
      ? locale
      : const Locale('en', 'US');
  return Localizations(
    locale: resolved,
    delegates: const <LocalizationsDelegate<dynamic>>[
      DefaultCupertinoLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    child: child,
  );
}

class _LingyunSheetPanel extends StatefulWidget {
  const _LingyunSheetPanel({
    required this.builder,
    required this.detents,
    required this.controller,
    required this.ownsController,
    required this.showGrabber,
    required this.dismissible,
    required this.horizontalSizeClass,
    required this.grabberLabel,
    required this.semanticsLabel,
    required this.backdrop,
  });

  final LingyunSheetBuilder builder;
  final List<LingyunSheetDetent> detents;
  final LingyunSheetController controller;
  final bool ownsController;
  final bool showGrabber;
  final bool dismissible;
  final String? horizontalSizeClass;
  final String grabberLabel;
  final String semanticsLabel;
  final LingyunSheetBackdropBuilder? backdrop;

  @override
  State<_LingyunSheetPanel> createState() => _LingyunSheetPanelState();
}

class _LingyunSheetPanelState extends State<_LingyunSheetPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settle;
  late final ScrollController _scroll;
  LingyunSheetMetrics? _metrics;
  double _height = 0;
  double _from = 0;
  double _to = 0;
  bool _dragging = false;
  bool _fromGrabber = false;
  bool _silence = false;
  bool _syncScheduled = false;
  bool _dismissed = false;
  int? _pointer;
  double _totalDx = 0;
  double _totalDy = 0;
  double _velocity = 0;
  Duration _lastStamp = Duration.zero;

  @override
  void initState() {
    super.initState();
    _settle =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 280),
        )..addListener(() {
          setState(() {
            _height = _from + (_to - _from) * _settle.value;
          });
        });
    _scroll = ScrollController();
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    if (widget.ownsController) widget.controller.dispose();
    _scroll.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _onController() {
    if (_silence || !mounted || _dragging || _metrics == null) return;
    final target = _metrics!.heightFor(widget.controller.detent);
    if ((target - _height).abs() < 0.5) return;
    _animateTo(target);
  }

  void _animateTo(double target) {
    if (!mounted) return;
    if ((target - _height).abs() < 0.5) {
      _height = target;
      return;
    }
    _from = _height;
    _to = target;
    _settle.duration = LiquidGlassMotion.durationOf(
      context,
      const Duration(milliseconds: 280),
    );
    _settle.forward(from: 0);
  }

  void _adopt(LingyunSheetDetent detent) {
    _silence = true;
    widget.controller._adopt(detent);
    _silence = false;
  }

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  void _down(PointerDownEvent event, {required bool grabber}) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    _fromGrabber = grabber;
    _dragging = false;
    _totalDx = 0;
    _totalDy = 0;
    _velocity = 0;
    _lastStamp = event.timeStamp;
    _settle.stop();
  }

  void _move(PointerMoveEvent event) {
    if (_pointer == null || event.pointer != _pointer || _metrics == null) {
      return;
    }
    _totalDx += event.delta.dx;
    _totalDy += event.delta.dy;
    final seconds = math.max(
      (event.timeStamp - _lastStamp).inMicroseconds / 1e6,
      1 / 120,
    );
    _velocity = event.delta.dy / seconds;
    _lastStamp = event.timeStamp;
    if (!_dragging) {
      if (_totalDy.abs() < 8 && _totalDx.abs() < 8) return;
      if (_totalDx.abs() > _totalDy.abs()) {
        _pointer = null;
        return;
      }
      _dragging = true;
    }
    final metrics = _metrics!;
    final largest = metrics.heightFor(widget.detents.last);
    final atLargest = _height >= largest - 0.5;
    final offset = _scroll.hasClients ? _scroll.offset : 0.0;
    final dy = event.delta.dy;
    if (!_fromGrabber) {
      if (atLargest && dy < 0) return;
      if (atLargest && offset > 0.5 && dy > 0) return;
    }
    final maxHeight = metrics.heightFor(widget.detents.last);
    setState(() => _height = (_height - dy).clamp(0.0, maxHeight));
  }

  void _up(PointerEvent event) {
    if (_pointer == null || event.pointer != _pointer) return;
    final dragged = _dragging;
    final velocity = event is PointerUpEvent ? _velocity : 0.0;
    _pointer = null;
    _dragging = false;
    if (dragged) _finishDrag(velocity);
  }

  void _finishDrag(double velocity) {
    final metrics = _metrics;
    if (metrics == null) return;
    final shortest = metrics.heightFor(widget.detents.first);
    final below = _height < shortest * LingyunSheetLayout.dismissFraction;
    final flung = velocity > 1200 && _height <= shortest + 24;
    if (widget.dismissible && (below || flung)) {
      _dismiss();
      return;
    }
    if (_height < shortest) {
      _adopt(widget.detents.first);
      _animateTo(shortest);
      return;
    }
    final detent = _pick(metrics, velocity);
    _adopt(detent);
    _animateTo(metrics.heightFor(detent));
  }

  LingyunSheetDetent _pick(LingyunSheetMetrics metrics, double velocity) {
    var best = widget.detents.first;
    var bestScore = double.infinity;
    for (final detent in widget.detents) {
      final h = metrics.heightFor(detent);
      var score = (h - _height).abs();
      if (velocity > 500 && h > _height + 8) score += 10000;
      if (velocity < -500 && h < _height - 8) score += 10000;
      if (score < bestScore) {
        bestScore = score;
        best = detent;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final keyboard = media.viewInsets.bottom;
        final metrics = LingyunSheetMetrics(
          bounds: Size(constraints.maxWidth, constraints.maxHeight),
          safeArea: media.padding,
          keyboardInset: keyboard,
          horizontalSizeClass: widget.horizontalSizeClass,
        );
        final first = _metrics == null;
        if (first) {
          _height = metrics.heightFor(widget.controller.detent);
        }
        _metrics = metrics;
        if (!first && !_dragging && !_settle.isAnimating && !_syncScheduled) {
          final target = metrics.heightFor(widget.controller.detent);
          if ((target - _height).abs() > 1) {
            _syncScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _syncScheduled = false;
              if (!mounted || _dragging || _metrics == null) return;
              _animateTo(_metrics!.heightFor(widget.controller.detent));
            });
          }
        }
        final visual = _height <= 0
            ? 0.0
            : math.max(_height, LingyunSheetLayout.minVisualHeight);
        final bottomPad = keyboard > 0
            ? 12.0
            : metrics.isCompact
            ? metrics.safeArea.bottom + 12
            : 16.0;
        final brightness = Theme.of(context).brightness;
        final colors = LingyunColors.forBrightness(brightness);
        final sheet = LingyunSheet(
          key: const Key('lingyun-sheet-platter'),
          showGrabber: widget.showGrabber,
          attachedToBottom: metrics.attachedToBottom,
          grabberLabel: widget.grabberLabel,
          grabber: widget.showGrabber
              ? Listener(
                  key: const Key('lingyun-sheet-grabber'),
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => _down(event, grabber: true),
                  onPointerMove: _move,
                  onPointerUp: _up,
                  onPointerCancel: _up,
                  child: _SheetGrabber(label: widget.grabberLabel),
                )
              : null,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) => _down(event, grabber: false),
            onPointerMove: _move,
            onPointerUp: _up,
            onPointerCancel: _up,
            child: DefaultTextStyle(
              style: LingyunTextStyles.body(color: colors.labels.primary),
              child: ListView(
                controller: _scroll,
                primary: false,
                physics: _SheetScrollPhysics(
                  sheet: this,
                  parent: const ClampingScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  LingyunSheetLayout.contentHorizontalPadding,
                  4,
                  LingyunSheetLayout.contentHorizontalPadding,
                  bottomPad,
                ),
                children: [widget.builder(context, widget.controller)],
              ),
            ),
          ),
        );
        return LingyunTheme(
          brightness: brightness,
          child: CupertinoTheme(
            data: LingyunTheme.cupertinoThemeFor(brightness),
            child: MediaQuery(
              data: media.copyWith(
                viewInsets: EdgeInsets.zero,
                padding: keyboard > 0
                    ? media.padding.copyWith(bottom: 0)
                    : media.padding,
              ),
              child: Stack(
                // Clip.none: a hard-edge clip on this stack would isolate
                // the platter from the backdrop painted behind it.
                clipBehavior: Clip.none,
                children: [
                  if (widget.backdrop != null)
                    Positioned.fill(
                      child: widget.backdrop!(
                        context,
                        metrics,
                        Rect.fromLTWH(
                          metrics.left,
                          constraints.maxHeight - metrics.bottomOffset - visual,
                          metrics.width,
                          visual,
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.dismissible ? _dismiss : null,
                    ),
                  ),
                  Positioned(
                    left: metrics.left,
                    width: metrics.width,
                    bottom: metrics.bottomOffset,
                    height: visual,
                    child: Semantics(
                      namesRoute: true,
                      label: widget.semanticsLabel,
                      explicitChildNodes: true,
                      child: sheet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetScrollPhysics extends ScrollPhysics {
  const _SheetScrollPhysics({required this.sheet, super.parent});

  final _LingyunSheetPanelState sheet;

  @override
  _SheetScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SheetScrollPhysics(sheet: sheet, parent: buildParent(ancestor));
  }

  bool get _atLargest {
    final metrics = sheet._metrics;
    if (metrics == null) return false;
    final largest = metrics.heightFor(sheet.widget.detents.last);
    return sheet._height >= largest - 0.5;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (!_atLargest) return 0;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (!_atLargest) return null;
    return super.createBallisticSimulation(position, velocity);
  }
}
