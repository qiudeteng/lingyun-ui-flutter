import 'package:cupertino_ui/cupertino_ui.dart';

import '../tokens/liquid_glass_motion.dart';

/// Role of one row on a system action sheet.
///
/// Mapped onto [CupertinoActionSheetAction] from `package:cupertino_ui`.
/// This is not a glass-button role and not a Materials tier.
enum LingyunActionSheetActionStyle {
  /// Ordinary choice. Regular weight, label color.
  ///
  /// This is [UIAlertAction.Style.default]: not bold, not red, and not the
  /// separated cancel. It stays in the upper group.
  regular,

  /// Preferred choice. Bold ([CupertinoActionSheetAction.isDefaultAction]).
  ///
  /// Still the label color. Not a tinted primary fill and not Glass Prominent.
  confirm,

  /// Destructive choice. System red
  /// ([CupertinoActionSheetAction.isDestructiveAction]), regular weight.
  ///
  /// The red is Cupertino's `systemRed`, not a glass-button fill.
  destructive,

  /// Dismiss. Pulled out of the upper group into the separated cancel slot.
  ///
  /// Regular weight. The package does not bold this slot on its own.
  cancel,
}

/// One row on a [LingyunActionSheet].
///
/// The sheet paints it with [CupertinoActionSheetAction], not a glass button.
@immutable
class LingyunActionSheetAction {
  /// A regular action unless [style] says otherwise.
  const LingyunActionSheetAction({
    required this.label,
    this.style = LingyunActionSheetActionStyle.regular,
    this.onPressed,
  });

  /// Ordinary choice in the upper group.
  const LingyunActionSheetAction.regular({
    required String label,
    VoidCallback? onPressed,
  }) : this(
         label: label,
         style: LingyunActionSheetActionStyle.regular,
         onPressed: onPressed,
       );

  /// Bold preferred choice in the upper group.
  const LingyunActionSheetAction.confirm({
    required String label,
    VoidCallback? onPressed,
  }) : this(
         label: label,
         style: LingyunActionSheetActionStyle.confirm,
         onPressed: onPressed,
       );

  /// System-red destructive choice in the upper group. Not bold.
  const LingyunActionSheetAction.destructive({
    required String label,
    VoidCallback? onPressed,
  }) : this(
         label: label,
         style: LingyunActionSheetActionStyle.destructive,
         onPressed: onPressed,
       );

  /// Separated bottom dismiss row.
  const LingyunActionSheetAction.cancel({
    required String label,
    VoidCallback? onPressed,
  }) : this(
         label: label,
         style: LingyunActionSheetActionStyle.cancel,
         onPressed: onPressed,
       );

  /// Row title. The system sheet styles it.
  final String label;

  /// Regular, confirm, destructive, or cancel.
  final LingyunActionSheetActionStyle style;

  /// Called before the sheet route pops. May be null; the row still
  /// dismisses and [showLingyunActionSheet] still returns this row's index.
  final VoidCallback? onPressed;

  /// Bold preferred row. Confirm only.
  bool get isDefaultAction => style == LingyunActionSheetActionStyle.confirm;

  /// System red. Destructive only.
  bool get isDestructiveAction =>
      style == LingyunActionSheetActionStyle.destructive;
}

/// Which caller indices go in the upper group, and which cancel is separated.
@immutable
class LingyunActionSheetArrangement {
  /// [actionIndices] keep caller order. [cancelIndex] is the first cancel.
  const LingyunActionSheetArrangement({
    required this.actionIndices,
    this.cancelIndex,
  });

  /// Non-cancel rows, plus any cancel after the first, in caller order.
  final List<int> actionIndices;

  /// The first cancel, drawn in the separated slot. Null when there is none.
  final int? cancelIndex;
}

/// iOS system action sheet (Sketch **Action Sheets**), hosted by `cupertino_ui`.
///
/// [showLingyunActionSheet] pushes [showCupertinoModalPopup] and this widget
/// builds a [CupertinoActionSheet]. The surface, type, press fill, and the
/// enter / exit spring belong to that package. This is not a Liquid Glass
/// drawing, not a glass button, not Dock, and not Materials Thick.
///
/// Ordinary rows use the label color. The package's default
/// [CupertinoThemeData.primaryColor] is system blue, which would tint every
/// row. Destructive rows still use `systemRed`.
@immutable
class LingyunActionSheet extends StatelessWidget {
  /// A system action sheet. Provide at least one action.
  const LingyunActionSheet({
    super.key,
    this.title,
    this.message,
    required this.actions,
    this.onSelected,
  });

  /// Optional title. When [message] is also set, the package bolds the title.
  final String? title;

  /// Optional message.
  final String? message;

  /// Actions in caller order. Display order is [arrange].
  final List<LingyunActionSheetAction> actions;

  /// Original index into [actions] after that row's
  /// [LingyunActionSheetAction.onPressed].
  final ValueChanged<int>? onSelected;

  /// Upper-group indices and the separated cancel.
  ///
  /// The first [LingyunActionSheetActionStyle.cancel] is [cancelIndex].
  /// Every other row, including a second cancel, stays in [actionIndices]
  /// in caller order. The upper group is top to bottom. The cancel slot
  /// sits below it with the package's gap.
  static LingyunActionSheetArrangement arrange(
    List<LingyunActionSheetAction> actions,
  ) {
    int? cancelIndex;
    final actionIndices = <int>[];
    for (var index = 0; index < actions.length; index++) {
      final isCancel =
          actions[index].style == LingyunActionSheetActionStyle.cancel;
      if (isCancel && cancelIndex == null) {
        cancelIndex = index;
      } else {
        actionIndices.add(index);
      }
    }
    return LingyunActionSheetArrangement(
      actionIndices: actionIndices,
      cancelIndex: cancelIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(actions.isNotEmpty, 'Provide at least one action.');
    final arrangement = arrange(actions);
    final theme = CupertinoTheme.of(context);
    final label = CupertinoColors.label.resolveFrom(context);
    return CupertinoTheme(
      data: theme.copyWith(primaryColor: label),
      child: CupertinoActionSheet(
        title: title == null ? null : Text(title!),
        message: message == null ? null : Text(message!),
        actions: [
          for (final index in arrangement.actionIndices)
            _row(index, actions[index]),
        ],
        cancelButton: arrangement.cancelIndex == null
            ? null
            : _row(arrangement.cancelIndex!, actions[arrangement.cancelIndex!]),
      ),
    );
  }

  Widget _row(int index, LingyunActionSheetAction action) {
    return CupertinoActionSheetAction(
      key: ValueKey<String>('lingyun-action-sheet-action-$index'),
      onPressed: () {
        action.onPressed?.call();
        onSelected?.call(index);
      },
      isDefaultAction: action.isDefaultAction,
      isDestructiveAction: action.isDestructiveAction,
      child: Text(action.label),
    );
  }
}

/// Presents a system action sheet and returns the caller's action index.
///
/// Motion on: a [CupertinoModalPopupRoute], the same route
/// [showCupertinoModalPopup] pushes. Pushed directly so the barrier can carry
/// a localized label; that function does not take one. The route owns the
/// spring and the bottom slide. This function does not copy the spring into
/// a token.
///
/// Reduce Motion ([LiquidGlassMotion.reduceMotionOf]): the spring is not
/// run. The sheet is pushed on a route whose duration is
/// [LiquidGlassMotion.durationOf] (zero) and whose curve is
/// [LiquidGlassMotion.curveOf] (linear). Press feedback is unchanged; the
/// package swaps the row fill immediately and has no press duration.
///
/// Returns null when [barrierDismissible] is true and the barrier is tapped.
/// That tap does not call the cancel row's callback and does not return the
/// cancel index.
///
/// The barrier color is [kCupertinoModalBarrierColor]. The package resolves
/// it for the current brightness (light `0x33000000`, dark `0x7A000000`).
///
/// The overlay may not inherit a `cupertino_ui` theme. The route re-applies
/// [CupertinoTheme.brightnessOf] and, when the overlay has no `cupertino_ui`
/// localizations, installs [DefaultCupertinoLocalizations]. It does not
/// install a compatibility bridge.
Future<int?> showLingyunActionSheet(
  BuildContext context, {
  String? title,
  String? message,
  required List<LingyunActionSheetAction> actions,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  String? barrierLabel,
}) {
  assert(actions.isNotEmpty, 'Provide at least one action.');
  final brightness = CupertinoTheme.brightnessOf(context);
  final locale = _actionSheetLocale(context);
  final resolvedBarrierLabel =
      barrierLabel ??
      Localizations.of<CupertinoLocalizations>(
        context,
        CupertinoLocalizations,
      )?.modalBarrierDismissLabel ??
      DefaultCupertinoLocalizations().modalBarrierDismissLabel;
  Widget sheet(BuildContext popupContext) {
    return _hostedSheet(
      popupContext: popupContext,
      brightness: brightness,
      locale: locale,
      child: LingyunActionSheet(
        title: title,
        message: message,
        actions: actions,
        onSelected: (index) => Navigator.of(popupContext).pop(index),
      ),
    );
  }

  if (LiquidGlassMotion.reduceMotionOf(context)) {
    return Navigator.of(context, rootNavigator: useRootNavigator).push<int>(
      _LingyunActionSheetReducedRoute<int>(
        builder: sheet,
        duration: LiquidGlassMotion.durationOf(context, Duration.zero),
        curve: LiquidGlassMotion.curveOf(context, Curves.linear),
        barrierLabelText: resolvedBarrierLabel,
        dismissible: barrierDismissible,
        barrier: CupertinoDynamicColor.resolve(
          kCupertinoModalBarrierColor,
          context,
        ),
      ),
    );
  }

  return Navigator.of(context, rootNavigator: useRootNavigator).push<int>(
    CupertinoModalPopupRoute<int>(
      builder: sheet,
      barrierLabel: resolvedBarrierLabel,
      barrierDismissible: barrierDismissible,
      barrierColor: CupertinoDynamicColor.resolve(
        kCupertinoModalBarrierColor,
        context,
      ),
    ),
  );
}

Widget _hostedSheet({
  required BuildContext popupContext,
  required Brightness brightness,
  required Locale locale,
  required Widget child,
}) {
  final themed = CupertinoTheme(
    data: CupertinoThemeData(brightness: brightness),
    child: child,
  );
  final hasCupertinoUi = Localizations.of<CupertinoLocalizations>(
    popupContext,
    CupertinoLocalizations,
  );
  if (hasCupertinoUi != null) return themed;
  return Localizations(
    locale: locale,
    delegates: const <LocalizationsDelegate<dynamic>>[
      DefaultCupertinoLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    child: themed,
  );
}

Locale _actionSheetLocale(BuildContext context) {
  final locale = Localizations.maybeLocaleOf(context);
  if (locale != null &&
      kCupertinoSupportedLanguages.contains(locale.languageCode)) {
    return locale;
  }
  return const Locale('en', 'US');
}

/// Zero-duration stand-in used only while Reduce Motion is on.
///
/// The slide is the same bottom translation the system popup uses, with no
/// spring. [showCupertinoModalPopup] cannot turn its private simulation off.
class _LingyunActionSheetReducedRoute<T> extends PopupRoute<T> {
  _LingyunActionSheetReducedRoute({
    required this.builder,
    required this.duration,
    required this.curve,
    required this.barrierLabelText,
    required this.dismissible,
    required this.barrier,
  });

  final WidgetBuilder builder;
  final Duration duration;
  final Curve curve;
  final String barrierLabelText;
  final bool dismissible;
  final Color barrier;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  @override
  Color get barrierColor => barrier;

  @override
  bool get barrierDismissible => dismissible;

  @override
  String get barrierLabel => barrierLabelText;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: DisplayFeatureSubScreen(child: Builder(builder: builder)),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).chain(CurveTween(curve: curve)).evaluate(animation);
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(translation: offset, child: child),
    );
  }
}
