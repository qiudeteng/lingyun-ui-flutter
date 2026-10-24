import 'package:cupertino_ui/cupertino_ui.dart';

/// Role of one button on a system alert.
///
/// Mapped onto [CupertinoDialogAction] from `package:cupertino_ui`.
/// This is not a glass-button role and not a Materials tier.
enum LingyunAlertActionStyle {
  /// Dismiss. Regular weight.
  ///
  /// On a two-button alert this is the leading action (left in LTR),
  /// matching UIAlertController. With three or more actions it is last
  /// (bottom of the system stack).
  cancel,

  /// Preferred confirm. Bold ([CupertinoDialogAction.isDefaultAction]).
  confirm,

  /// Destructive confirm. System red
  /// ([CupertinoDialogAction.isDestructiveAction]).
  ///
  /// The red is Cupertino's `systemRed`, not a glass-button fill.
  destructive,
}

/// One button on a [LingyunAlertDialog].
///
/// The dialog paints it with [CupertinoDialogAction], not a glass button.
@immutable
class LingyunAlertAction {
  /// A confirm action unless [style] says otherwise.
  const LingyunAlertAction({
    required this.label,
    this.style = LingyunAlertActionStyle.confirm,
    this.onPressed,
  });

  /// Leading dismiss action.
  const LingyunAlertAction.cancel({
    required String label,
    VoidCallback? onPressed,
  }) : this(
         label: label,
         style: LingyunAlertActionStyle.cancel,
         onPressed: onPressed,
       );

  /// Trailing preferred action (bold).
  const LingyunAlertAction.confirm({
    required String label,
    VoidCallback? onPressed,
  }) : this(
         label: label,
         style: LingyunAlertActionStyle.confirm,
         onPressed: onPressed,
       );

  /// System-red destructive action. Not bold.
  const LingyunAlertAction.destructive({
    required String label,
    VoidCallback? onPressed,
  }) : this(
         label: label,
         style: LingyunAlertActionStyle.destructive,
         onPressed: onPressed,
       );

  /// Button title. The system dialog styles it.
  final String label;

  /// Cancel, confirm, or destructive.
  final LingyunAlertActionStyle style;

  /// Called before the dialog route pops. May be null; the button still
  /// dismisses and [showLingyunAlert] still returns this action's index.
  final VoidCallback? onPressed;

  /// Bold preferred action. Confirm only.
  bool get isDefaultAction => style == LingyunAlertActionStyle.confirm;

  /// System red. Destructive only.
  bool get isDestructiveAction => style == LingyunAlertActionStyle.destructive;
}

/// iOS system alert (Sketch **Alerts**), hosted by `cupertino_ui`.
///
/// [showLingyunAlert] pushes [showCupertinoDialog] + [CupertinoAlertDialog].
/// The surface, type, and barrier are the package's — not a Liquid Glass
/// drawing, not a glass button, not Dock, and not Materials Thick.
///
/// Sketch states this covers: one button, two buttons, destructive confirm,
/// title + message, and message only. Button order follows iOS: cancel is
/// leading on a two-button alert (left in LTR).
@immutable
class LingyunAlertDialog extends StatelessWidget {
  /// A system alert. Provide a [title], a [message], or both, and at least
  /// one action.
  const LingyunAlertDialog({
    super.key,
    this.title,
    this.message,
    required this.actions,
    this.onSelected,
  }) : assert(
         title != null || message != null,
         'Provide a title, a message, or both.',
       );

  /// Optional title. Omit for a message-only alert.
  final String? title;

  /// Optional message. Omit for a title-only alert.
  final String? message;

  /// Actions in caller order. Display order is [LingyunAlert.arrangedIndices].
  final List<LingyunAlertAction> actions;

  /// Original index into [actions] after that action's [LingyunAlertAction.onPressed].
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    assert(actions.isNotEmpty, 'Provide at least one action.');
    final order = LingyunAlert.arrangedIndices(actions);
    return CupertinoAlertDialog(
      title: title == null ? null : Text(title!),
      content: message == null ? null : Text(message!),
      actions: [
        for (final index in order)
          CupertinoDialogAction(
            key: ValueKey<String>('lingyun-alert-action-$index'),
            onPressed: () {
              actions[index].onPressed?.call();
              onSelected?.call(index);
            },
            isDefaultAction: actions[index].isDefaultAction,
            isDestructiveAction: actions[index].isDestructiveAction,
            child: Text(actions[index].label),
          ),
      ],
    );
  }
}

/// Ordering and presentation helpers for [LingyunAlertDialog].
abstract final class LingyunAlert {
  /// Indices into [actions] in system display order.
  ///
  /// * Fewer than two actions, or no cancel: caller order.
  /// * Exactly two, with a cancel: cancel first (leading / left in LTR).
  /// * Three or more, with a cancel: cancel last (bottom).
  ///
  /// Relative order of the other actions is preserved.
  static List<int> arrangedIndices(List<LingyunAlertAction> actions) {
    if (actions.length < 2) {
      return List<int>.generate(actions.length, (index) => index);
    }
    final cancels = <int>[];
    final others = <int>[];
    for (var index = 0; index < actions.length; index++) {
      if (actions[index].style == LingyunAlertActionStyle.cancel) {
        cancels.add(index);
      } else {
        others.add(index);
      }
    }
    if (cancels.isEmpty) {
      return List<int>.generate(actions.length, (index) => index);
    }
    if (actions.length == 2) {
      return <int>[...cancels, ...others];
    }
    return <int>[...others, ...cancels];
  }
}

/// Presents a system alert and returns the caller's action index.
///
/// Uses [showCupertinoDialog] from `package:cupertino_ui`. The barrier color
/// is left unset so the route keeps [kCupertinoModalBarrierColor]
/// (light `0x33000000`, dark `0x7A000000`).
///
/// Returns null when [barrierDismissible] is true and the barrier is tapped.
///
/// The overlay may not inherit a `cupertino_ui` theme (for example under a
/// legacy app shell). The route re-applies [CupertinoTheme.brightnessOf] and,
/// when the overlay has no `cupertino_ui` localizations, installs
/// [DefaultCupertinoLocalizations]. It does not install a compatibility bridge.
Future<int?> showLingyunAlert(
  BuildContext context, {
  String? title,
  String? message,
  required List<LingyunAlertAction> actions,
  bool barrierDismissible = false,
  bool useRootNavigator = true,
  String? barrierLabel,
}) {
  assert(
    title != null || message != null,
    'Provide a title, a message, or both.',
  );
  assert(actions.isNotEmpty, 'Provide at least one action.');
  final brightness = CupertinoTheme.brightnessOf(context);
  final locale = _alertLocale(context);
  final resolvedBarrierLabel =
      barrierLabel ??
      Localizations.of<CupertinoLocalizations>(
        context,
        CupertinoLocalizations,
      )?.modalBarrierDismissLabel ??
      DefaultCupertinoLocalizations().modalBarrierDismissLabel;
  return showCupertinoDialog<int>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    barrierLabel: resolvedBarrierLabel,
    builder: (dialogContext) {
      final dialog = LingyunAlertDialog(
        title: title,
        message: message,
        actions: actions,
        onSelected: (index) => Navigator.of(dialogContext).pop(index),
      );
      final themed = CupertinoTheme(
        data: CupertinoThemeData(brightness: brightness),
        child: dialog,
      );
      final hasCupertinoUi = Localizations.of<CupertinoLocalizations>(
        dialogContext,
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
    },
  );
}

Locale _alertLocale(BuildContext context) {
  final locale = Localizations.maybeLocaleOf(context);
  if (locale != null &&
      kCupertinoSupportedLanguages.contains(locale.languageCode)) {
    return locale;
  }
  return const Locale('en', 'US');
}
