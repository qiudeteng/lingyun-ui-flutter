import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';

import '../adaptivity/lingyun_adaptivity.dart';
import '../theme/lingyun_theme.dart';
import '../tokens/lingyun_colors.dart';

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
/// [showLingyunAlert] pushes [CupertinoDialogRoute] (the same route as
/// [showCupertinoDialog]) with [CupertinoAlertDialog]. The surface, type,
/// and barrier are the package's — not a Liquid Glass drawing, not a glass
/// button, not Dock, and not Materials Thick.
///
/// Non-destructive actions use the kit system blue
/// ([LingyunAlert.actionBlue]) as [CupertinoThemeData.primaryColor].
/// [CupertinoDialogAction] still paints the label. Destructive stays on
/// Cupertino `systemRed`.
///
/// The dialog's own styles keep `fontFamily: CupertinoSystemText` (the Apple
/// proxy for SF Pro Text). This package does not bundle SF Pro. On other
/// platforms, when the surrounding [DefaultTextStyle] already names a real
/// family, title, message, and actions adopt that family so the missing
/// proxy does not replace the app face. See [LingyunAlert.desktopTypeStyle].
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
    final brightness = CupertinoTheme.brightnessOf(context);
    final desktop = LingyunAlert.desktopTypeStyle(context);
    final order = LingyunAlert.arrangedIndices(actions);
    return CupertinoTheme(
      data: LingyunTheme.cupertinoThemeFor(brightness),
      child: CupertinoAlertDialog(
        title: title == null ? null : Text(title!, style: desktop),
        content: message == null ? null : Text(message!, style: desktop),
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
              textStyle: desktop,
              child: Text(actions[index].label),
            ),
        ],
      ),
    );
  }
}

/// Ordering, color, type, and motion helpers for [LingyunAlertDialog].
abstract final class LingyunAlert {
  /// Family the system dialog hardcodes. On Apple platforms this is the
  /// SF Pro Text proxy. This package does not bundle SF Pro.
  static const String systemFontFamily = 'CupertinoSystemText';

  /// Nominal [CupertinoDialogRoute.transitionDuration] when motion is on.
  ///
  /// The route then runs its own spring (about 0.4s to rest), not a linear
  /// tween of this length. Not a kit token. [showLingyunAlert] passes
  /// [Duration.zero] instead when [reduceMotionOf] is true.
  static const Duration cupertinoTransitionDuration = Duration(
    milliseconds: 250,
  );

  /// Kit system blue for a non-destructive action.
  ///
  /// Light `#0088FF`, dark `#0091FF`. Not Cupertino `systemBlue`
  /// (`#007AFF` / `#0A84FF`). Wired through [CupertinoThemeData.primaryColor]
  /// so [CupertinoDialogAction] paints it. Destructive actions ignore this
  /// and stay on Cupertino `systemRed`.
  static Color actionBlue(Brightness brightness) {
    return LingyunColors.forBrightness(brightness).system.blue;
  }

  /// CJK UI faces tried after the ambient Latin family on non-Apple hosts.
  ///
  /// Used only by [desktopTypeStyle]. Apple keeps the system cascade.
  static const List<String> desktopCjkFallback = <String>[
    'PingFang SC',
    'Hiragino Sans GB',
    'Microsoft YaHei',
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'Source Han Sans SC',
    'WenQuanYi Micro Hei',
    'Droid Sans Fallback',
  ];

  /// Type override for title, message, and actions.
  ///
  /// Null on iOS and macOS, and when the ambient family is missing or is
  /// already [systemFontFamily] / `CupertinoSystemDisplay`. Otherwise the
  /// ambient family plus [desktopCjkFallback], so a missing system-font
  /// proxy does not replace the app face. Sizes and weights stay on the
  /// system dialog styles.
  static TextStyle? desktopTypeStyle(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return null;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        break;
    }
    final ambient = DefaultTextStyle.of(context).style;
    final family = ambient.fontFamily;
    if (family == null ||
        family.isEmpty ||
        family == systemFontFamily ||
        family == 'CupertinoSystemDisplay') {
      return null;
    }
    final seen = ambient.fontFamilyFallback ?? const <String>[];
    return TextStyle(
      fontFamily: family,
      fontFamilyFallback: <String>[
        ...seen,
        for (final name in desktopCjkFallback)
          if (!seen.contains(name)) name,
      ],
    );
  }

  /// True when the system dialog transition should not play.
  ///
  /// [MediaQueryData.disableAnimations] or [LingyunAdaptivity.reduceMotion].
  static bool reduceMotionOf(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media != null && media.disableAnimations) return true;
    return LingyunAdaptivity.maybeOf(context)?.reduceMotion ?? false;
  }

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
/// Pushes [CupertinoDialogRoute] from `package:cupertino_ui` (the route
/// [showCupertinoDialog] uses). The barrier color is left unset so the route
/// keeps [kCupertinoModalBarrierColor] (light `0x33000000`, dark `0x7A000000`).
///
/// Entrance is that route's fade plus scale (1.3 → 1.0) on its spring.
/// [LingyunAlert.reduceMotionOf] switches the same route to
/// [Duration.zero] and an identity transition. This does not draw a second
/// animation.
///
/// Returns null when [barrierDismissible] is true and the barrier is tapped.
///
/// The overlay may not inherit a `cupertino_ui` theme (for example under a
/// legacy app shell). The route re-applies [LingyunTheme.cupertinoThemeFor]
/// and, when the overlay has no `cupertino_ui` localizations, installs
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
  final reduceMotion = LingyunAlert.reduceMotionOf(context);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<int>(
    CupertinoDialogRoute<int>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: resolvedBarrierLabel,
      transitionDuration: reduceMotion
          ? Duration.zero
          : LingyunAlert.cupertinoTransitionDuration,
      transitionBuilder: reduceMotion ? _stillAlertTransition : null,
      builder: (dialogContext) {
        final dialog = LingyunAlertDialog(
          title: title,
          message: message,
          actions: actions,
          onSelected: (index) => Navigator.of(dialogContext).pop(index),
        );
        final themed = CupertinoTheme(
          data: LingyunTheme.cupertinoThemeFor(brightness),
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
    ),
  );
}

Widget _stillAlertTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return child;
}

Locale _alertLocale(BuildContext context) {
  final locale = Localizations.maybeLocaleOf(context);
  if (locale != null &&
      kCupertinoSupportedLanguages.contains(locale.languageCode)) {
    return locale;
  }
  return const Locale('en', 'US');
}
