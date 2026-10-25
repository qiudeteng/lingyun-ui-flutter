import 'dart:async';
import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import '../adaptivity/lingyun_adaptivity.dart';
import '../theme/lingyun_theme.dart';
import '../theme/liquid_glass_theme.dart';
import '../tokens/lingyun_text_styles.dart';
import '../tokens/liquid_glass_motion.dart';
import '../tokens/liquid_glass_style.dart';
import '../tokens/liquid_glass_tokens.dart';
import 'glass_button.dart';
import 'glass_surface.dart';

/// Visual role of one [LingyunMenuAction].
///
/// Destructive is system red. It does not open an action sheet — action
/// sheets are a separate component.
enum LingyunMenuActionStyle {
  /// Ordinary command.
  plain,

  /// System red label and icon. Not bold.
  destructive,
}

/// One row in a [LingyunMenu].
///
/// [children] is a single submenu level (HIG: keep submenus to one level).
/// The menu draws the chevron; the presenter pushes that level.
@immutable
class LingyunMenuAction {
  /// A plain command unless [style] says otherwise.
  const LingyunMenuAction({
    required this.label,
    this.leading,
    this.style = LingyunMenuActionStyle.plain,
    this.enabled = true,
    this.selected = false,
    this.children,
    this.onPressed,
  });

  /// System-red command. Not an action-sheet confirm.
  const LingyunMenuAction.destructive({
    required String label,
    Widget? leading,
    bool enabled = true,
    bool selected = false,
    List<LingyunMenuAction>? children,
    VoidCallback? onPressed,
  }) : this(
         label: label,
         leading: leading,
         style: LingyunMenuActionStyle.destructive,
         enabled: enabled,
         selected: selected,
         children: children,
         onPressed: onPressed,
       );

  /// Row title.
  final String label;

  /// Optional symbol, drawn in the row color at [GlassButton.iconSize].
  final Widget? leading;

  /// Plain or destructive.
  final LingyunMenuActionStyle style;

  /// Disabled rows stay visible, use the tertiary label, and do not fire.
  ///
  /// HIG context menus prefer hiding unavailable items. Pull-down menus in
  /// the gallery still show a disabled row so that state can be reviewed.
  /// 待核验 which Sketch states include a dimmed row.
  final bool enabled;

  /// Trailing check when this command is the current choice.
  final bool selected;

  /// One submenu level. Empty or null means a leaf.
  final List<LingyunMenuAction>? children;

  /// Called when a leaf is chosen, before the menu dismisses.
  final VoidCallback? onPressed;

  /// True when [children] has at least one action.
  bool get hasChildren => children != null && children!.isNotEmpty;
}

/// A separated group of [LingyunMenuAction]s.
@immutable
class LingyunMenuSection {
  /// [actions] must not be empty.
  const LingyunMenuSection({required this.actions, this.title});

  /// Optional footnote above the group. Omit unless it adds meaning (HIG).
  final String? title;

  /// Rows in this group, top to bottom.
  final List<LingyunMenuAction> actions;
}

/// What [showLingyunMenu] returns.
///
/// [path] is the chosen row at each level, flattened across sections:
/// section 0's actions are `0 .. n-1`, then section 1, and so on.
/// A submenu leaf is `[parent, child]`.
@immutable
class LingyunMenuResult {
  /// [path] is empty only if a caller builds one that way. Dismissal is null.
  const LingyunMenuResult(this.path);

  /// Indices from the root menu down to the leaf.
  final List<int> path;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LingyunMenuResult || other.path.length != path.length) {
      return false;
    }
    for (var i = 0; i < path.length; i++) {
      if (other.path[i] != path[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(path);

  @override
  String toString() => 'LingyunMenuResult($path)';
}

/// Geometry that is not a motion token and not a Design Token.
///
/// Width and the anchor gap cite Flutter's private iOS 16 context-menu
/// sheet figures (`_kMenuWidth` 250, `_kPadding` 20). They are working
/// values for an iOS 27 pull-down bubble. 待核验 vs Sketch Menus.
/// Figma was rate-limited.
///
/// Motion (morph duration, press flex) is not configured here.
abstract final class LingyunMenuLayout {
  /// Preferred menu width. See the class note. 待核验.
  static const double width = 250;

  /// Gap between the anchor and the resting bubble. 待核验.
  static const double anchorGap = 20;

  /// Extra inset inside the safe area. Same source as [anchorGap]. 待核验.
  static const double screenMargin = 20;

  /// Cupertino minimum hit target (`kMinInteractiveDimension`).
  /// Not a Sketch measurement.
  static const double minRowHeight = 44;
}

/// Where a resting menu sits relative to its anchor.
@immutable
class LingyunMenuPlacement {
  /// [above] is true when the bubble flips over the anchor.
  const LingyunMenuPlacement({required this.rect, required this.above});

  /// Resting frame in the same coordinates as [anchor].
  final Rect rect;

  /// True when there is no room below the anchor.
  final bool above;

  /// Places [menu] under [anchor], or above it when that side fits better.
  ///
  /// Prefers below (HIG pull-down). Flips above when below would leave the
  /// safe area and above fits, or when the anchor is in the lower half and
  /// neither side fits. Clamps into the safe area plus [LingyunMenuLayout.screenMargin].
  static LingyunMenuPlacement resolve({
    required Size bounds,
    required EdgeInsets safe,
    required Rect anchor,
    required Size menu,
    required TextDirection direction,
  }) {
    final margin = LingyunMenuLayout.screenMargin;
    final gap = LingyunMenuLayout.anchorGap;
    var leftLimit = safe.left + margin;
    var rightLimit = bounds.width - safe.right - margin;
    var topLimit = safe.top + margin;
    var bottomLimit = bounds.height - safe.bottom - margin;
    if (rightLimit < leftLimit) {
      leftLimit = 0;
      rightLimit = bounds.width;
    }
    if (bottomLimit < topLimit) {
      topLimit = 0;
      bottomLimit = bounds.height;
    }
    final maxWidth = math.max(0.0, rightLimit - leftLimit);
    final width = math.min(menu.width, maxWidth);
    final height = math.min(menu.height, math.max(0.0, bottomLimit - topLimit));

    final belowTop = anchor.bottom + gap;
    final aboveTop = anchor.top - gap - height;
    final fitsBelow = belowTop + height <= bottomLimit + 0.5;
    final fitsAbove = aboveTop >= topLimit - 0.5;
    final above =
        !fitsBelow && (fitsAbove || anchor.center.dy >= bounds.height / 2);
    var top = above ? aboveTop : belowTop;
    final topSlack = bottomLimit - height;
    if (topSlack >= topLimit) {
      top = top.clamp(topLimit, topSlack);
    } else {
      top = topLimit;
    }

    var left = direction == TextDirection.rtl
        ? anchor.right - width
        : anchor.left;
    final leftSlack = rightLimit - width;
    if (leftSlack >= leftLimit) {
      left = left.clamp(leftLimit, leftSlack);
    } else {
      left = leftLimit;
    }

    return LingyunMenuPlacement(
      rect: Rect.fromLTWH(left, top, width, height),
      above: above,
    );
  }
}

/// Actions in [sections], section by section.
List<LingyunMenuAction> lingyunMenuFlatten(List<LingyunMenuSection> sections) {
  return [for (final section in sections) ...section.actions];
}

/// iOS 27 menu bubble (Sketch **Menus**), Liquid Glass.
///
/// Official behavior this follows, in order:
///
/// 1. WWDC25 *Meet Liquid Glass*: a menu is a bubble that pops open from
///    the control; glass flexes and lights up under the finger; it
///    materializes by lensing rather than by fading the glass away; Reduce
///    Motion drops elastic flex.
/// 2. *Adopting Liquid Glass* and WWDC25 *Build a UIKit app*: menus adopt
///    Liquid Glass, and a glass button morphs into the menu.
/// 3. HIG Menus: near the control, dismiss on a choice or an outside tap,
///    destructive in red at the end, at most one submenu, icons when they
///    help.
/// 4. Sketch / Figma are the static check only. The Figma file was
///    rate-limited, so the style tier is a hypothesis.
///
/// Hypothesis: the resting bubble is [LiquidGlassStyle.regularLarge].
/// Meet Liquid Glass says that when a toolbar button morphs into a menu
/// the glass becomes more substantial (deeper shadow, stronger lensing).
/// Regular Large is the existing prominent-panel style. It is not
/// Materials Thick, not Regular Small (that is the button), and not the
/// opaque iOS 16 context-menu fill (long-press preview, not this bubble).
/// That widget is the wrong interaction and the wrong material, so this
/// menu does not wrap it. 待核验 vs Sketch Menus.
///
/// `blurSigma` stays the Regular Large approximation already on
/// [GlassSurface]. This widget does not publish a new blur or a spring
/// stiffness. Present / dismiss easing is [LiquidGlassMotion.standard]
/// and [LiquidGlassMotion.standardCurve]. Press flex reuses the 0.97 scale
/// [GlassButton] already uses, with [LiquidGlassMotion.quick].
///
/// [showLingyunMenu] runs the morph. This widget is the resting platter
/// the gallery can also pin in place.
class LingyunMenu extends StatelessWidget {
  /// A resting menu. [sections] must not be empty.
  const LingyunMenu({
    super.key,
    required this.sections,
    this.style = LiquidGlassStyle.regularLarge,
    this.width = LingyunMenuLayout.width,
    this.maxHeight,
    this.contentOpacity = 1,
    this.forcePressedIndex,
    this.interactive = true,
    this.showKeys = true,
    this.showBack = false,
    this.backLabel = 'Back',
    this.onBack,
    this.onSelected,
    this.animateContent = false,
    this.contentKey,
    this.layoutOnly = false,
  });

  /// Groups, top to bottom.
  final List<LingyunMenuSection> sections;

  /// Liquid Glass style. Default Regular Large. Ignored if you need a
  /// Materials tier — this widget never sets one.
  final LiquidGlassStyle style;

  /// Preferred width before the presenter clamps it to the safe area.
  final double width;

  /// Caps the platter and scrolls the rows. Null sizes to the rows.
  final double? maxHeight;

  /// Label reveal inside the bubble, 0 to 1.
  ///
  /// The glass itself stays opaque. Meet Liquid Glass: materialize by
  /// lensing, don't fade the glass away. The labels are what appear.
  final double contentOpacity;

  /// Pins one flattened row in the pressed flex. Gallery only.
  final int? forcePressedIndex;

  /// When false, rows paint but do not take taps (static plates).
  final bool interactive;

  /// When false, rows omit the keys used by the live menu.
  ///
  /// The morph overlay keeps an offstage copy for measurement.
  final bool showKeys;

  /// Back row, shown on the submenu level.
  final bool showBack;

  /// Back row title. The gallery passes 「返回」.
  final String backLabel;

  /// Pops the submenu level.
  final VoidCallback? onBack;

  /// Flattened index of a leaf, or of a row that has [LingyunMenuAction.children].
  final ValueChanged<int>? onSelected;

  /// Slides submenu content with [LiquidGlassMotion.quick]. The glass
  /// bubble does not slide. 待核验 vs the system push.
  final bool animateContent;

  /// Identity for [animateContent]. Change it when the level changes.
  final Key? contentKey;

  /// Skip caller [LingyunMenuAction.leading] widgets.
  ///
  /// The morph overlay measures an offstage copy. Leading widgets cannot
  /// be mounted twice. Row height stays on [LingyunMenuLayout.minRowHeight].
  final bool layoutOnly;

  @override
  Widget build(BuildContext context) {
    assert(sections.isNotEmpty, 'Provide at least one menu section.');
    assert(
      sections.every((section) => section.actions.isNotEmpty),
      'Menu sections must not be empty.',
    );
    final labels = LingyunTheme.colorsOf(context).liquidGlassLabels;
    final colors = LingyunTheme.colorsOf(context);
    final flat = lingyunMenuFlatten(sections);
    var running = 0;
    final rows = <Widget>[];
    if (showBack) {
      rows.add(
        _MenuRow(
          key: showKeys ? const Key('lingyun-menu-back') : null,
          label: backLabel,
          color: labels.primary,
          chevronBack: true,
          interactive: interactive,
          onTap: onBack,
        ),
      );
    }
    for (final section in sections) {
      if (rows.isNotEmpty) rows.add(_hairline(labels.tertiary));
      if (section.title != null) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _kHorizontal,
              vertical: _kVertical,
            ),
            child: Text(
              section.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LingyunTextStyles.footnote(
                emphasized: true,
                color: labels.primary,
              ),
            ),
          ),
        );
      }
      for (var i = 0; i < section.actions.length; i++) {
        if (i > 0 || section.title != null) {
          rows.add(_hairline(labels.tertiary));
        }
        final action = section.actions[i];
        final index = running + i;
        final destructive = action.style == LingyunMenuActionStyle.destructive;
        final color = !action.enabled
            ? labels.tertiary
            : destructive
            ? colors.system.red
            : labels.primary;
        rows.add(
          _MenuRow(
            key: showKeys ? Key('lingyun-menu-action-$index') : null,
            label: action.label,
            color: color,
            leading: layoutOnly ? null : action.leading,
            selected: action.selected,
            submenu: action.hasChildren,
            enabled: action.enabled,
            interactive: interactive,
            forcePressed: forcePressedIndex == index,
            showPressedKey: showKeys,
            checkKey: showKeys ? Key('lingyun-menu-check-$index') : null,
            chevronKey: showKeys ? Key('lingyun-menu-chevron-$index') : null,
            onTap: action.enabled ? () => onSelected?.call(index) : null,
          ),
        );
      }
      running += section.actions.length;
    }
    assert(running == flat.length, 'Flat index walked every action.');

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
    final keyed = animateContent
        ? AnimatedSwitcher(
            duration: LiquidGlassMotion.durationOf(
              context,
              LiquidGlassMotion.defaults.quick,
            ),
            switchInCurve: LiquidGlassMotion.curveOf(
              context,
              LiquidGlassMotion.defaults.standardCurve,
            ),
            switchOutCurve: LiquidGlassMotion.curveOf(
              context,
              LiquidGlassMotion.defaults.quickCurve,
            ),
            layoutBuilder: (current, previous) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [...previous, if (current != null) current],
              );
            },
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation);
              return ClipRect(
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: KeyedSubtree(
              key: contentKey ?? const ValueKey<int>(0),
              child: column,
            ),
          )
        : column;
    final scrolled = maxHeight == null
        ? keyed
        : ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight!),
            child: SingleChildScrollView(primary: false, child: keyed),
          );
    final revealed = Opacity(
      opacity: contentOpacity.clamp(0.0, 1.0),
      child: scrolled,
    );

    return SizedBox(
      width: width,
      child: GlassSurface(
        style: style,
        padding: EdgeInsets.zero,
        enableHoverHighlight: false,
        child: revealed,
      ),
    );
  }

  static Widget _hairline(Color color) {
    return ColoredBox(
      color: color,
      child: const SizedBox(height: LiquidGlassTokens.hairlineWidth),
    );
  }
}

/// Horizontal inset shared by rows and section titles. 待核验 vs Sketch.
const double _kHorizontal = 16;

/// Vertical inset inside a row. 待核验 vs Sketch.
const double _kVertical = 10;

/// Press flex. Same scale [GlassButton] documents for its pressed state.
/// Not a new token. Reduce Motion leaves the row at 1.
const double _kPressScale = 0.97;

class _MenuRow extends StatefulWidget {
  const _MenuRow({
    super.key,
    required this.label,
    required this.color,
    this.leading,
    this.selected = false,
    this.submenu = false,
    this.chevronBack = false,
    this.enabled = true,
    this.interactive = true,
    this.forcePressed = false,
    this.showPressedKey = true,
    this.checkKey,
    this.chevronKey,
    this.onTap,
  });

  final String label;
  final Color color;
  final Widget? leading;
  final bool selected;
  final bool submenu;
  final bool chevronBack;
  final bool enabled;
  final bool interactive;
  final bool forcePressed;
  final bool showPressedKey;
  final Key? checkKey;
  final Key? chevronKey;
  final VoidCallback? onTap;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _pressed = false;

  bool get _active =>
      widget.interactive && widget.enabled && widget.onTap != null;

  bool get _showPressed => widget.forcePressed || (_active && _pressed);

  @override
  Widget build(BuildContext context) {
    final reduced = LiquidGlassMotion.reduceMotionOf(context);
    final duration = LiquidGlassMotion.durationOf(
      context,
      LiquidGlassMotion.defaults.quick,
    );
    final curve = LiquidGlassMotion.curveOf(
      context,
      LiquidGlassMotion.defaults.quickCurve,
    );
    final veil = LiquidGlassTheme.buttonPaletteOf(context).pressedVeil;
    // Meet Liquid Glass: flex + light under the finger. Reduce Motion
    // disables the elastic flex. The light (veil) still switches, instantly.
    final scale = _showPressed && !reduced ? _kPressScale : 1.0;
    final glyph = widget.color;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _active ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: _active ? () => setState(() => _pressed = false) : null,
      onTapUp: _active
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      child: AnimatedScale(
        scale: scale,
        duration: duration,
        curve: curve,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: duration,
          curve: curve,
          color: _showPressed ? veil : const Color(0x00000000),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: LingyunMenuLayout.minRowHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontal,
                vertical: _kVertical,
              ),
              child: Row(
                children: [
                  if (widget.chevronBack) ...[
                    _Chevron(color: glyph, back: true),
                    const SizedBox(width: 8),
                  ],
                  if (widget.leading != null) ...[
                    IconTheme.merge(
                      data: IconThemeData(
                        color: glyph,
                        size: GlassButton.iconSize,
                      ),
                      child: widget.leading!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LingyunTextStyles.body(color: glyph),
                    ),
                  ),
                  if (widget.selected)
                    KeyedSubtree(
                      key: widget.checkKey,
                      child: _Check(color: glyph),
                    ),
                  if (widget.submenu)
                    KeyedSubtree(
                      key: widget.chevronKey,
                      child: _Chevron(color: glyph),
                    ),
                  if (_showPressed && widget.showPressedKey)
                    const SizedBox(
                      key: Key('lingyun-menu-row-pressed'),
                      width: 0,
                      height: 0,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color, this.back = false});

  final Color color;
  final bool back;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(GlassButton.iconSize, GlassButton.iconSize),
      painter: _ChevronPainter(color: color, back: back),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color, required this.back});

  final Color color;
  final bool back;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final mid = size.height / 2;
    final inset = size.width * 0.28;
    final path = Path();
    if (back) {
      path
        ..moveTo(size.width - inset, size.height * 0.22)
        ..lineTo(inset, mid)
        ..lineTo(size.width - inset, size.height * 0.78);
    } else {
      path
        ..moveTo(inset, size.height * 0.22)
        ..lineTo(size.width - inset, mid)
        ..lineTo(inset, size.height * 0.78);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.back != back;
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(GlassButton.iconSize, GlassButton.iconSize),
      painter: _CheckPainter(color: color),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.30);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Anchor rect in global coordinates.
Rect lingyunMenuAnchorOf(BuildContext context) {
  final box = context.findRenderObject()! as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Presents [sections] as a Liquid Glass bubble grown from [anchor].
///
/// The bubble's resting frame is [LingyunMenuPlacement]. Enter and exit
/// lerp that frame from [anchor] (WWDC: the button morphs into the menu;
/// the bubble pops open). Duration and easing are
/// [LiquidGlassMotion.standard] / [LiquidGlassMotion.standardCurve] —
/// the same duration and curve the sheet route already uses. There is no new
/// spring stiffness. The action-sheet spring inside `cupertino_ui`
/// (dialogs / action sheets) is not reused.
///
/// Glass opacity stays 1. [LingyunMenu.contentOpacity] follows the morph
/// so the labels are revealed inside the lens.
///
/// Reduce Motion ([LingyunAdaptivity.reduceMotion] or
/// [MediaQuery.disableAnimations]) snaps the bubble into place and skips
/// the row scale. The press veil still appears.
///
/// Returns null when the barrier is tapped. [barrierDismissible] defaults
/// to true (HIG: tap outside dismisses).
///
/// The overlay is the current route's overlay so [GlassSurface] can sample
/// the page. A new modal route on Impeller does not (see sheets).
Future<LingyunMenuResult?> showLingyunMenu(
  BuildContext context, {
  required List<LingyunMenuSection> sections,
  required Rect anchor,
  LiquidGlassStyle style = LiquidGlassStyle.regularLarge,
  bool barrierDismissible = true,
  String backLabel = 'Back',
  String barrierLabel = 'Dismiss menu',
}) {
  assert(sections.isNotEmpty, 'Provide at least one menu section.');
  final overlay = Overlay.of(context);
  final overlayBox = overlay.context.findRenderObject()! as RenderBox;
  final origin = overlayBox.localToGlobal(Offset.zero);
  final localAnchor = anchor.shift(-origin);
  final reduceMotion = LiquidGlassMotion.reduceMotionOf(context);
  final inherited = context.dependOnInheritedWidgetOfExactType<LingyunTheme>();
  final brightness =
      inherited?.brightness ?? CupertinoTheme.brightnessOf(context);
  final completer = Completer<LingyunMenuResult?>();
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) {
      return LingyunAdaptivity(
        reduceMotion: reduceMotion,
        child: LingyunTheme(
          brightness: brightness,
          child: CupertinoTheme(
            data: LingyunTheme.cupertinoThemeFor(brightness),
            child: _MenuMorph(
              anchor: localAnchor,
              sections: sections,
              style: style,
              barrierDismissible: barrierDismissible,
              backLabel: backLabel,
              barrierLabel: barrierLabel,
              reduceMotion: reduceMotion,
              onClosed: (result) {
                if (entry.mounted) entry.remove();
                if (!completer.isCompleted) completer.complete(result);
              },
            ),
          ),
        ),
      );
    },
  );
  overlay.insert(entry);
  return completer.future;
}

class _MenuMorph extends StatefulWidget {
  const _MenuMorph({
    required this.anchor,
    required this.sections,
    required this.style,
    required this.barrierDismissible,
    required this.backLabel,
    required this.barrierLabel,
    required this.reduceMotion,
    required this.onClosed,
  });

  final Rect anchor;
  final List<LingyunMenuSection> sections;
  final LiquidGlassStyle style;
  final bool barrierDismissible;
  final String backLabel;
  final String barrierLabel;
  final bool reduceMotion;
  final ValueChanged<LingyunMenuResult?> onClosed;

  @override
  State<_MenuMorph> createState() => _MenuMorphState();
}

class _MenuMorphState extends State<_MenuMorph>
    with SingleTickerProviderStateMixin {
  final GlobalKey _measureKey = GlobalKey();
  late final AnimationController _motion;
  Size? _menuSize;
  int? _parent;
  bool _started = false;
  bool _closing = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _motion =
        AnimationController(
          vsync: this,
          duration: widget.reduceMotion
              ? Duration.zero
              : LiquidGlassMotion.defaults.standard,
        )..addListener(() {
          if (mounted) setState(() {});
        });
  }

  @override
  void dispose() {
    _motion.dispose();
    final notify = !_finished;
    _finished = true;
    super.dispose();
    if (notify) {
      scheduleMicrotask(() => widget.onClosed(null));
    }
  }

  List<LingyunMenuSection> get _visible {
    if (_parent == null) return widget.sections;
    final parent = lingyunMenuFlatten(widget.sections)[_parent!];
    return [
      LingyunMenuSection(
        actions: [
          for (final action in parent.children!)
            LingyunMenuAction(
              label: action.label,
              leading: action.leading,
              style: action.style,
              enabled: action.enabled,
              selected: action.selected,
              onPressed: action.onPressed,
            ),
        ],
      ),
    ];
  }

  void _onMeasured(Size size) {
    if (!mounted || _menuSize == size) return;
    setState(() => _menuSize = size);
    if (_started) return;
    _started = true;
    if (widget.reduceMotion) {
      _motion.value = 1;
    } else {
      _motion.animateTo(
        1,
        duration: LiquidGlassMotion.defaults.standard,
        curve: LiquidGlassMotion.defaults.standardCurve,
      );
    }
  }

  Future<void> _close(LingyunMenuResult? result) async {
    if (_closing || _finished) return;
    _closing = true;
    if (widget.reduceMotion) {
      _motion.value = 0;
      _finish(result);
      return;
    }
    try {
      await _motion.animateTo(
        0,
        duration: LiquidGlassMotion.defaults.standard,
        curve: LiquidGlassMotion.defaults.standardCurve,
      );
    } catch (_) {
      // The overlay was removed while the bubble was shrinking.
    }
    _finish(result);
  }

  void _finish(LingyunMenuResult? result) {
    if (_finished) return;
    _finished = true;
    widget.onClosed(result);
  }

  void _choose(int index) {
    if (_closing) return;
    if (_parent == null) {
      final action = lingyunMenuFlatten(widget.sections)[index];
      if (action.hasChildren) {
        setState(() => _parent = index);
        return;
      }
      action.onPressed?.call();
      _close(LingyunMenuResult([index]));
      return;
    }
    final action = _visible.single.actions[index];
    action.onPressed?.call();
    _close(LingyunMenuResult([_parent!, index]));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bounds = media.size;
    final safe = media.padding;
    final direction = Directionality.of(context);
    final menuWidth = _menuWidth(bounds, safe);
    final maxHeight = _maxHeight(bounds, safe);
    final measured = _menuSize;
    final resting = measured == null
        ? null
        : LingyunMenuPlacement.resolve(
            bounds: bounds,
            safe: safe,
            anchor: widget.anchor,
            menu: measured,
            direction: direction,
          ).rect;
    final t = _motion.value.clamp(0.0, 1.0);
    final visual = resting == null
        ? null
        : Rect.lerp(widget.anchor, resting, t)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Semantics(
            button: true,
            label: widget.barrierLabel,
            child: GestureDetector(
              key: const Key('lingyun-menu-barrier'),
              behavior: HitTestBehavior.opaque,
              onTap: widget.barrierDismissible ? () => _close(null) : null,
              child: const ColoredBox(color: Color(0x00000000)),
            ),
          ),
        ),
        Offstage(
          child: Align(
            alignment: Alignment.topLeft,
            child: _Measure(
              onSize: _onMeasured,
              child: LingyunMenu(
                key: _measureKey,
                sections: _visible,
                style: widget.style,
                width: menuWidth,
                maxHeight: maxHeight,
                showBack: _parent != null,
                backLabel: widget.backLabel,
                showKeys: false,
                interactive: false,
                layoutOnly: true,
              ),
            ),
          ),
        ),
        if (visual != null && measured != null)
          Positioned(
            left: visual.left,
            top: visual.top,
            width: math.max(visual.width, 1),
            height: math.max(visual.height, 1),
            child: KeyedSubtree(
              key: const Key('lingyun-menu-panel'),
              child: FittedBox(
                fit: BoxFit.fill,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: measured.width,
                  height: measured.height,
                  child: LingyunMenu(
                    sections: _visible,
                    style: widget.style,
                    width: measured.width,
                    maxHeight: measured.height,
                    contentOpacity: t,
                    showBack: _parent != null,
                    backLabel: widget.backLabel,
                    onBack: () => setState(() => _parent = null),
                    onSelected: _choose,
                    animateContent: true,
                    contentKey: ValueKey<int>(_parent ?? -1),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _menuWidth(Size bounds, EdgeInsets safe) {
    final room =
        bounds.width -
        safe.left -
        safe.right -
        LingyunMenuLayout.screenMargin * 2;
    if (room <= 0) return math.min(LingyunMenuLayout.width, bounds.width);
    return math.min(LingyunMenuLayout.width, room);
  }

  double _maxHeight(Size bounds, EdgeInsets safe) {
    final margin = LingyunMenuLayout.screenMargin;
    final gap = LingyunMenuLayout.anchorGap;
    final topLimit = safe.top + margin;
    final bottomLimit = bounds.height - safe.bottom - margin;
    final below = bottomLimit - (widget.anchor.bottom + gap);
    final above = widget.anchor.top - gap - topLimit;
    final room = math.max(below, above);
    if (room < LingyunMenuLayout.minRowHeight) {
      return math.max(LingyunMenuLayout.minRowHeight, bottomLimit - topLimit);
    }
    return room;
  }
}

class _Measure extends StatefulWidget {
  const _Measure({required this.onSize, required this.child});

  final ValueChanged<Size> onSize;
  final Widget child;

  @override
  State<_Measure> createState() => _MeasureState();
}

class _MeasureState extends State<_Measure> {
  final GlobalKey _key = GlobalKey();
  Size? _sent;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant _Measure oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedule();
  }

  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final size = box.size;
      if (size == _sent || size.isEmpty) return;
      _sent = size;
      widget.onSize(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    _schedule();
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

/// Dark catalog sentinel. Compared by identity in [showLingyunMenu].
