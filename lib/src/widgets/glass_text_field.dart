import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/lingyun_theme.dart';
import '../theme/liquid_glass_theme.dart';
import '../tokens/lingyun_text_styles.dart';
import '../tokens/liquid_glass_style.dart';
import '../tokens/liquid_glass_tokens.dart';
import 'glass_cupertino_host.dart';
import 'glass_surface.dart';

/// Single-line **Liquid Glass** text field.
///
/// The editable control is a [CupertinoTextField] (clear button, obscure
/// text, placeholder). Its Cupertino fill is removed (`borderless` /
/// `decoration: null`). Chrome is [GlassSurface] at
/// [LiquidGlassStyle.regularSmall] — the compact control capsule — not
/// Materials Thick and not the Cupertino white/black field fill.
///
/// Label hierarchy:
/// * [label] — liquid-glass Primary from [LingyunTheme], above the field
/// * entered text — liquid-glass Primary, [LingyunTextStyles.body]
/// * [placeholder] and [helperText] — liquid-glass Tertiary
/// * [errorText] — [LingyunColors.system] red, replaces the helper
///
/// Focused and error draw the shared ~0.5px hairline in System Blue or
/// system red. That accent is not a per-tier rim and not a blur token.
/// [forceFocused] pins the focused hairline the way a button pins pressed.
class GlassTextField extends StatefulWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.onObscureChanged,
    this.obscureToggle = false,
    this.showSecretLabel = 'Show password',
    this.hideSecretLabel = 'Hide password',
    this.clearButtonMode = OverlayVisibilityMode.editing,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.forceFocused = false,
    this.glassStyle = LiquidGlassStyle.regularSmall,
    this.tint,
    this.forceOpaque = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Primary label above the field. Omit for a field with no caption.
  final String? label;

  /// Tertiary placeholder inside the field.
  final String? placeholder;

  /// Tertiary helper under the field. Hidden while [errorText] is set.
  final String? helperText;

  /// System-red message under the field. Also paints the error hairline.
  final String? errorText;

  final bool enabled;

  /// Current secure state. When [onObscureChanged] is null and
  /// [obscureToggle] is true, the eye button updates an internal flag
  /// that starts at this value.
  final bool obscureText;

  final ValueChanged<bool>? onObscureChanged;

  /// Shows an eye / eye-slash button. Does not by itself obscure text;
  /// pair it with [obscureText].
  final bool obscureToggle;

  /// Semantics label for the eye button while the value is hidden.
  final String showSecretLabel;

  /// Semantics label for the eye button while the value is visible.
  final String hideSecretLabel;

  /// When the Cupertino clear button is visible. Default is while editing,
  /// which is the iOS text-field behavior.
  final OverlayVisibilityMode clearButtonMode;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// Pins the focused hairline without requiring focus.
  final bool forceFocused;

  /// Liquid Glass chrome. Default Regular Small (capsule). Not a Materials tier.
  final LiquidGlassStyle glassStyle;

  /// Caret and focused hairline. Defaults to System Blue.
  final Color? tint;

  final bool forceOpaque;

  bool get hasError => errorText != null && errorText!.isNotEmpty;

  /// Focused / error hairline. Null when the field stays on the glass rim only.
  static Color? resolveAccent({
    required bool enabled,
    required bool focused,
    required bool hasError,
    required Color tint,
    required Color error,
  }) {
    if (hasError) return error;
    if (focused && enabled) return tint;
    return null;
  }

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocus;
  late bool _localObscure;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  FocusNode get _focus => widget.focusNode ?? _ownedFocus!;

  bool get _obscure =>
      widget.onObscureChanged != null ? widget.obscureText : _localObscure;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _ownedFocus = FocusNode();
    }
    _localObscure = widget.obscureText;
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(GlassTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onObscureChanged == null &&
        widget.obscureText != oldWidget.obscureText) {
      _localObscure = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ownedController?.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  void _toggleObscure() {
    final next = !_obscure;
    if (widget.onObscureChanged != null) {
      widget.onObscureChanged!(next);
    } else {
      setState(() => _localObscure = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lingyun = context.dependOnInheritedWidgetOfExactType<LingyunTheme>();
    final colors = lingyun?.colors ?? LingyunTheme.colorsOf(context);
    final brightness =
        lingyun?.brightness ?? LiquidGlassTheme.brightnessOf(context);
    final labels = colors.liquidGlassLabels;
    final primary = labels.primary;
    final tertiary = labels.tertiary;
    final tint = widget.tint ?? colors.system.blue;
    final focused = widget.forceFocused || _focus.hasFocus;
    final accent = GlassTextField.resolveAccent(
      enabled: widget.enabled,
      focused: focused,
      hasError: widget.hasError,
      tint: tint,
      error: colors.system.red,
    );
    final tokens = LiquidGlassTheme.styleOf(context, widget.glassStyle);
    final valueColor = widget.enabled ? primary : tertiary;
    final caption = widget.hasError ? widget.errorText : widget.helperText;
    final captionColor = widget.hasError ? colors.system.red : tertiary;

    final field = CupertinoTextField.borderless(
      controller: _controller,
      focusNode: _focus,
      enabled: widget.enabled,
      obscureText: _obscure,
      placeholder: widget.placeholder,
      placeholderStyle: LingyunTextStyles.body(color: tertiary),
      style: LingyunTextStyles.body(color: valueColor),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      clearButtonMode: widget.enabled
          ? widget.clearButtonMode
          : OverlayVisibilityMode.never,
      suffix: widget.obscureToggle ? _obscureButton(tertiary) : null,
      suffixMode: OverlayVisibilityMode.always,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      keyboardAppearance: brightness,
      cursorColor: tint,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );

    Widget chrome = Stack(
      children: [
        GlassSurface(
          style: widget.glassStyle,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          forceOpaque: widget.forceOpaque,
          child: SizedBox(height: 48, child: field),
        ),
        if (accent != null)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: tokens.borderRadius,
                  border: Border.all(
                    color: accent,
                    width: LiquidGlassTokens.hairlineWidth,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    chrome = GlassCupertinoHost(child: chrome);
    if (Localizations.of<CupertinoLocalizations>(
          context,
          CupertinoLocalizations,
        ) ==
        null) {
      chrome = Localizations.override(
        context: context,
        delegates: const [DefaultCupertinoLocalizations.delegate],
        child: chrome,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: LingyunTextStyles.footnote(
              emphasized: true,
              color: widget.enabled ? primary : tertiary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        chrome,
        if (caption != null) ...[
          const SizedBox(height: 6),
          Text(caption, style: LingyunTextStyles.caption1(color: captionColor)),
        ],
      ],
    );
  }

  Widget _obscureButton(Color color) {
    final show = _obscure;
    return Semantics(
      button: true,
      label: show ? widget.showSecretLabel : widget.hideSecretLabel,
      child: GestureDetector(
        onTap: widget.enabled ? _toggleObscure : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            show ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}
