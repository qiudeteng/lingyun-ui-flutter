import 'package:cupertino_ui/cupertino_ui.dart';

/// Brightness for a Controls-layer widget.
///
/// An explicit override wins. Otherwise the Cupertino theme, then the
/// platform brightness. Gallery pages should pass the theme brightness
/// in so a light / dark switch is honored.
Brightness controlBrightnessOf(BuildContext context, Brightness? override) {
  if (override != null) return override;
  return CupertinoTheme.maybeBrightnessOf(context) ??
      MediaQuery.platformBrightnessOf(context);
}
