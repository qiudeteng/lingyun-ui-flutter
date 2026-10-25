import 'package:material_ui/material_ui.dart';

import '../layout/lingyun_layout.dart';
import '../theme/lingyun_theme.dart';
import '../theme/liquid_glass_theme.dart';
import '../tokens/lingyun_text_styles.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import 'glass_surface.dart';

/// Which screen edge a [LingyunToolbar] pads for.
///
/// The bar stays horizontal. This is not the iOS 27.1 vertical system
/// toolbar (that chrome is native, under `ios/`).
enum LingyunToolbarPlacement {
  /// Floats under the top safe area.
  top,

  /// Floats above the bottom safe area.
  bottom,
}

/// Working geometry for [LingyunToolbar]. Not a Design Token table.
///
/// Hit size cites the usual 44pt control. The capsule corner is the same
/// stadium [GlassButton] uses (`BorderRadius.circular(1000)`), not a new
/// radius and not the Tab Bar Dock corner. Blur and saturation stay inside
/// the Liquid Glass catalog. **待核验** against HIG Toolbars.
abstract final class LingyunToolbarMetrics {
  /// Gap between the safe area and the floating groups. **待核验**.
  static const double edgeGap = 8;

  /// Minimum control extent. Usual HIG hit target, not a new token.
  static const double actionExtent = 44;

  /// Gap between icons inside one group. **待核验**.
  static const double actionGap = 4;

  /// Press scale. Same approximation [GlassButton] already uses. Not a
  /// new token.
  static const double pressedScale = 0.97;

  /// How far a show / hide slide travels, as a fraction of the bar.
  ///
  /// Short, not a fly-in. **对照官方观感 / 待核验**.
  static const double slideFraction = 0.35;

  static const BorderRadius capsuleRadius = BorderRadius.all(
    Radius.circular(1000),
  );
}

/// One symbol in a [LingyunToolbar] group.
@immutable
class LingyunToolbarAction {
  const LingyunToolbarAction({
    required this.icon,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.key,
  });

  final IconData icon;

  /// Spoken label. Also the tooltip-free semantics label.
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  /// Key on the pressable button, so a gallery can find one action.
  final Key? key;
}

/// Symbol button used inside a toolbar glass group.
///
/// Press feedback matches [GlassButton]: scale
/// [LingyunToolbarMetrics.pressedScale] plus that button's existing press
/// veil, on [LiquidGlassMotion.quick]. It is not a nested [GlassButton] —
/// the group is already the glass. Reduce motion collapses the duration
/// to [Duration.zero]; the pressed scale still applies.
class LingyunToolbarActionButton extends StatefulWidget {
  const LingyunToolbarActionButton({super.key, required this.action});

  final LingyunToolbarAction action;

  @override
  State<LingyunToolbarActionButton> createState() =>
      _LingyunToolbarActionButtonState();
}

class _LingyunToolbarActionButtonState
    extends State<LingyunToolbarActionButton> {
  bool _pressed = false;

  bool get _enabled => widget.action.enabled && widget.action.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
    final curve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
    final colors = LingyunTheme.colorsOf(context);
    final veil = LiquidGlassTheme.buttonPaletteOf(context).pressedVeil;
    final showPressed = _enabled && _pressed;
    final iconColor = _enabled ? colors.labels.primary : colors.labels.tertiary;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.action.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTap: _enabled ? widget.action.onPressed : null,
        child: AnimatedScale(
          scale: showPressed ? LingyunToolbarMetrics.pressedScale : 1,
          duration: duration,
          curve: curve,
          child: SizedBox(
            width: LingyunToolbarMetrics.actionExtent,
            height: LingyunToolbarMetrics.actionExtent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: showPressed ? 1 : 0,
                  duration: duration,
                  curve: curve,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: veil,
                      borderRadius: LingyunToolbarMetrics.capsuleRadius,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                Icon(widget.action.icon, color: iconColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Flutter horizontal toolbar: floating Liquid Glass **groups**.
///
/// WWDC25 Meet Liquid Glass / Adopting Liquid Glass: toolbar controls sit
/// in small floating glass clusters, and a glass piece keeps one ambient
/// appearance. It is not sliced into light and dark. This widget does that
/// with one [GlassSurface] per group at [LiquidGlassStyle.regularMedium]
/// (grouped controls). It does **not** use [LiquidGlassStyle.dock] (that
/// is [GlassTabBar]) and it does **not** use [MaterialTier.thick] (that is
/// the sheet / formal sidebar).
///
/// [leading] is the leading group. [actions] share the trailing group.
/// [title] sits between them and is not a glass slab, so the bar is not a
/// full-width material strip.
///
/// Show / hide uses [LiquidGlassMotion.standard] (slide + height). Press
/// uses [LiquidGlassMotion.quick]. No new spring token. The iOS 27.1
/// toolbar spring is unpublished (**对照官方观感 / 待核验**). `blurSigma`
/// stays the catalog approximation.
///
/// [placement] only chooses the safe-area edge and the slide direction.
/// [avoidHinge] adds [LingyunLayout.chromeInsetsFor] when the bar spans a
/// window that should keep controls off the center seam. That is a Flutter
/// inset, not a vertical system toolbar and not a Duo pose. On a split,
/// put the bar in the detail column so it never crosses the sidebar.
///
/// Needs a bounded width. The parent decides top versus bottom.
class LingyunToolbar extends StatefulWidget {
  const LingyunToolbar({
    super.key,
    this.leading,
    this.title,
    this.actions = const [],
    this.placement = LingyunToolbarPlacement.top,
    this.visible = true,
    this.avoidHinge = false,
    this.includeSafeArea = true,
    this.glassStyle = LiquidGlassStyle.regularMedium,
    this.slotKey,
  }) : assert(
         glassStyle != LiquidGlassStyle.dock,
         'LingyunToolbar does not use Dock. Dock is the tab bar. '
         'Regular Medium is the grouped-glass default.',
       );

  /// Leading cluster. Placed inside the leading glass group.
  ///
  /// Pass [LingyunToolbarActionButton] for the shared press feedback.
  /// Do not pass another glass platter.
  final Widget? leading;

  /// Centered between the groups. Not wrapped in glass.
  final Widget? title;

  /// Trailing cluster. One shared glass group.
  final List<LingyunToolbarAction> actions;

  final LingyunToolbarPlacement placement;

  /// Animates in and out. False collapses the slot.
  final bool visible;

  /// Extra side inset from [LingyunLayout.chromeInsetsFor].
  final bool avoidHinge;

  /// When false, the parent already applied the safe area.
  final bool includeSafeArea;

  /// Liquid Glass recipe for each group. Default Regular Medium.
  ///
  /// [LiquidGlassStyle.dock] is rejected. Not a [MaterialTier].
  /// **待核验** against the kit's toolbar glass name.
  final LiquidGlassStyle glassStyle;

  /// Key on the slot whose height tracks show / hide. Omit when several
  /// bars share a tree.
  final Key? slotKey;

  @override
  State<LingyunToolbar> createState() => _LingyunToolbarState();
}

class _LingyunToolbarState extends State<LingyunToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LiquidGlassMotion.defaults.standard,
      value: widget.visible ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sync() {
    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.standard,
    );
    _controller.duration = duration;
    _controller.reverseDuration = duration;
    if (duration == Duration.zero) {
      _controller.value = widget.visible ? 1 : 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant LingyunToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
    if (oldWidget.visible != widget.visible &&
        _controller.duration != Duration.zero) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final curve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.standardCurve,
    );
    final fromTop = widget.placement == LingyunToolbarPlacement.top;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = curve.transform(_controller.value);
        return ClipRect(
          key: widget.slotKey,
          child: Align(
            alignment: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
            heightFactor: t <= 0 ? 0 : t,
            child: FractionalTranslation(
              translation: Offset(
                0,
                (1 - t) *
                    (fromTop
                        ? -LingyunToolbarMetrics.slideFraction
                        : LingyunToolbarMetrics.slideFraction),
              ),
              child: IgnorePointer(
                ignoring: t < 0.99 && !widget.visible,
                child: child,
              ),
            ),
          ),
        );
      },
      child: _ToolbarBar(toolbar: widget),
    );
  }
}

class _ToolbarBar extends StatelessWidget {
  const _ToolbarBar({required this.toolbar});

  final LingyunToolbar toolbar;

  @override
  Widget build(BuildContext context) {
    final colors = LingyunTheme.colorsOf(context);
    final safe = toolbar.includeSafeArea
        ? MediaQuery.paddingOf(context)
        : EdgeInsets.zero;
    final hinge = toolbar.avoidHinge
        ? LingyunLayout.chromeInsetsFor(MediaQuery.sizeOf(context))
        : EdgeInsets.zero;
    final fromTop = toolbar.placement == LingyunToolbarPlacement.top;
    final leading = toolbar.leading;
    final actions = toolbar.actions;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        safe.left + hinge.left,
        fromTop
            ? safe.top + LingyunToolbarMetrics.edgeGap
            : LingyunToolbarMetrics.edgeGap,
        safe.right + hinge.right,
        fromTop
            ? LingyunToolbarMetrics.edgeGap
            : safe.bottom + LingyunToolbarMetrics.edgeGap,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: colors.labels.primary, size: 22),
        child: DefaultTextStyle(
          style: LingyunTextStyles.headline(color: colors.labels.primary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: Row(
            children: [
              if (leading != null)
                _ToolbarGroup(style: toolbar.glassStyle, child: leading),
              Expanded(
                child: toolbar.title == null
                    ? const SizedBox.shrink()
                    : Center(child: toolbar.title),
              ),
              if (actions.isNotEmpty)
                _ToolbarGroup(
                  style: toolbar.glassStyle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0)
                          const SizedBox(
                            width: LingyunToolbarMetrics.actionGap,
                          ),
                        LingyunToolbarActionButton(
                          key: actions[i].key,
                          action: actions[i],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarGroup extends StatelessWidget {
  const _ToolbarGroup({required this.style, required this.child});

  final LiquidGlassStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      style: style,
      borderRadius: LingyunToolbarMetrics.capsuleRadius,
      enableHoverHighlight: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: child,
    );
  }
}
