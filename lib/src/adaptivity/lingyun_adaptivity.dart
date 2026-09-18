import 'package:flutter/material.dart';

/// Gallery / app overrides for accessibility that Flutter does not expose
/// as first-class [MediaQuery] flags on every platform.
///
/// Flutter already has [MediaQueryData.highContrast] and
/// [MediaQueryData.disableAnimations] (Reduce Motion). There is **no**
/// built-in Reduce Transparency flag, so apps should set
/// [reduceTransparency] here (or pass `forceOpaque` to [GlassSurface]).
///
/// This inherited widget is optional. Tokens and [GlassSurface] work on
/// iPhone, foldables, iPad, macOS, and web without it.
class LingyunAdaptivity extends InheritedWidget {
  const LingyunAdaptivity({
    super.key,
    this.reduceTransparency = false,
    this.reduceMotion = false,
    this.highContrast = false,
    required super.child,
  });

  /// When true, glass paints the opaque fallback instead of blur.
  final bool reduceTransparency;

  /// When true, motion durations collapse to zero.
  /// Also honored via [MediaQuery.disableAnimationsOf].
  final bool reduceMotion;

  /// When true, glass uses the opaque high-contrast fallback.
  /// Also honored via [MediaQuery.highContrastOf].
  final bool highContrast;

  static LingyunAdaptivity? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LingyunAdaptivity>();
  }

  static LingyunAdaptivity of(BuildContext context) {
    final found = maybeOf(context);
    assert(found != null, 'LingyunAdaptivity not found in context.');
    return found!;
  }

  /// Opaque fallback: explicit force, Reduce Transparency, or high contrast.
  static bool useOpaqueFallback(
    BuildContext context, {
    bool forceOpaque = false,
  }) {
    if (forceOpaque) return true;
    final adaptivity = maybeOf(context);
    if (adaptivity != null &&
        (adaptivity.reduceTransparency || adaptivity.highContrast)) {
      return true;
    }
    return MediaQuery.highContrastOf(context);
  }

  @override
  bool updateShouldNotify(LingyunAdaptivity oldWidget) {
    return reduceTransparency != oldWidget.reduceTransparency ||
        reduceMotion != oldWidget.reduceMotion ||
        highContrast != oldWidget.highContrast;
  }
}
