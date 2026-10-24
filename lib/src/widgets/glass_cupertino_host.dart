import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/lingyun_theme.dart';
import '../theme/liquid_glass_theme.dart';

/// Points [CupertinoTheme] at the host Liquid Glass brightness.
///
/// [CupertinoTheme] otherwise follows platform brightness, so a dark app
/// theme on a light platform would resolve Cupertino dynamic colors for
/// the wrong appearance. This host is not a Materials fill.
class GlassCupertinoHost extends StatelessWidget {
  const GlassCupertinoHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lingyun = context.dependOnInheritedWidgetOfExactType<LingyunTheme>();
    final brightness =
        lingyun?.brightness ?? LiquidGlassTheme.brightnessOf(context);
    return CupertinoTheme(
      data: CupertinoThemeData(brightness: brightness),
      child: child,
    );
  }
}
