import 'package:flutter/material.dart';

/// Colors for `GlassButton` treatments.
///
/// Kit sources (Sketch Buttons page, iOS 27 UI Kit):
/// * **Glass Prominent** fill — System Blue, white label
/// * **Destructive** — system red label, or a system-red fill when combined
///   with Glass Prominent
/// * **Disabled** — Glass uses a tertiary label (light `#BFBFBF`). Glass
///   Prominent keeps the accent fill; the widget fades it to about 50%.
///
/// [pressedVeil] is an **implementation approximation — not an official
/// Design Token**. It only makes the pressed state readable. Do not print
/// it in the gallery as a kit value.
///
/// These are button colors, not Materials tiers. Materials Thick is never
/// a button fill.
@immutable
class GlassButtonPalette {
  const GlassButtonPalette({
    required this.systemBlue,
    required this.systemRed,
    required this.filledLabel,
    required this.disabledLabel,
    required this.pressedVeil,
  });

  /// Light Glass Prominent fill. Sampled from
  /// `Buttons/Light/Large/Glass Prominent/Default` (`#0088FF`).
  static const Color systemBlueLight = Color(0xFF0088FF);

  /// Dark Glass Prominent fill. Sampled from
  /// `Buttons/Dark/Large/Glass Prominent/Default` (`#0091FF`).
  static const Color systemBlueDark = Color(0xFF0091FF);

  /// Light Destructive. Sampled from
  /// `Buttons/Light/Large/Destructive/Destructive` (`#FF383C`).
  static const Color systemRedLight = Color(0xFFFF383C);

  /// Dark Destructive. Sampled from
  /// `Buttons/Dark/Large/Destructive/Destructive` (`#FF4245`).
  static const Color systemRedDark = Color(0xFFFF4245);

  /// Label on a filled Glass Prominent button (kit: white).
  static const Color filledLabelColor = Color(0xFFFFFFFF);

  /// White plate under a Glass Prominent tint (Figma "White Backing").
  ///
  /// The accent tint is opaque, so the plate does not shift the fill. It is
  /// flattened with the tint before the disabled 50% fade.
  static const Color prominentBacking = Color(0xFFFFFFFF);

  /// Light disabled Glass label.
  ///
  /// Acceptance brief: Vibrant Controls Tertiary ≈ `#BFBFBF`
  /// (Is Enabled = False on Style Glass). Replaces the earlier composited
  /// sample `#6D6D6F`.
  static const Color disabledLabelLight = Color(0xFFBFBFBF);

  /// Dark disabled Glass label.
  ///
  /// The acceptance brief published one tertiary, `#BFBFBF`. The old
  /// `#59595C` sample came from Dark Glass Prominent Disabled, which is
  /// the 50% fade of the accent fill, not this label. Dark uses the same
  /// tertiary until a separate dark value is re-read.
  static const Color disabledLabelDark = Color(0xFFBFBFBF);

  /// Light palette.
  static const GlassButtonPalette light = GlassButtonPalette(
    systemBlue: systemBlueLight,
    systemRed: systemRedLight,
    filledLabel: filledLabelColor,
    disabledLabel: disabledLabelLight,
    // Press wash. Approximation — not a kit token. Kept light enough
    // that the capsule, rim, and label stay readable.
    pressedVeil: Color(0x33000000),
  );

  /// Dark palette.
  static const GlassButtonPalette dark = GlassButtonPalette(
    systemBlue: systemBlueDark,
    systemRed: systemRedDark,
    filledLabel: filledLabelColor,
    disabledLabel: disabledLabelDark,
    pressedVeil: Color(0x40FFFFFF),
  );

  static GlassButtonPalette forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  /// System Blue — kit **Glass Prominent** fill.
  final Color systemBlue;

  /// System red — kit **Destructive** label and prominent destructive fill.
  final Color systemRed;

  /// White label used on filled Glass Prominent buttons.
  final Color filledLabel;

  /// Muted label for `onPressed == null`.
  final Color disabledLabel;

  /// Press wash. Implementation approximation — not a kit token.
  final Color pressedVeil;

  GlassButtonPalette lerp(GlassButtonPalette other, double t) {
    return GlassButtonPalette(
      systemBlue: Color.lerp(systemBlue, other.systemBlue, t)!,
      systemRed: Color.lerp(systemRed, other.systemRed, t)!,
      filledLabel: Color.lerp(filledLabel, other.filledLabel, t)!,
      disabledLabel: Color.lerp(disabledLabel, other.disabledLabel, t)!,
      pressedVeil: Color.lerp(pressedVeil, other.pressedVeil, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlassButtonPalette &&
        other.systemBlue == systemBlue &&
        other.systemRed == systemRed &&
        other.filledLabel == filledLabel &&
        other.disabledLabel == disabledLabel &&
        other.pressedVeil == pressedVeil;
  }

  @override
  int get hashCode => Object.hash(
    systemBlue,
    systemRed,
    filledLabel,
    disabledLabel,
    pressedVeil,
  );
}
