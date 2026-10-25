import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'gallery_catalog.dart';
import 'wallpaper.dart';

/// Top-right cluster: 浅色 / 暗黑, 降低透明度, 画板, 画布.
class GalleryPreviewCluster extends StatelessWidget {
  const GalleryPreviewCluster({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.reduceTransparency,
    required this.onReduceTransparency,
    required this.frame,
    required this.onFrameChanged,
    required this.background,
    required this.onBackgroundChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final bool reduceTransparency;
  final ValueChanged<bool> onReduceTransparency;
  final GalleryPreviewFrame frame;
  final ValueChanged<GalleryPreviewFrame> onFrameChanged;
  final GalleryBackground background;
  final ValueChanged<GalleryBackground> onBackgroundChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('gallery-preview-cluster'),
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GalleryThemeToggle(mode: themeMode, onChanged: onThemeModeChanged),
        GalleryReduceTransparencyToggle(
          value: reduceTransparency,
          onChanged: onReduceTransparency,
        ),
        GalleryDeviceButton(frame: frame, onChanged: onFrameChanged),
        GalleryBackgroundButton(
          mode: background,
          onChanged: onBackgroundChanged,
        ),
      ],
    );
  }
}

/// Leading control plus the preview cluster. Stacks when the row is narrow.
class GalleryPreviewBar extends StatelessWidget {
  const GalleryPreviewBar({super.key, this.leading, required this.cluster});

  final Widget? leading;
  final Widget cluster;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leading != null)
                Align(alignment: Alignment.centerLeft, child: leading),
              Align(alignment: Alignment.centerRight, child: cluster),
            ],
          );
        }
        return Row(
          children: [if (leading != null) leading!, const Spacer(), cluster],
        );
      },
    );
  }
}

class GalleryThemeToggle extends StatelessWidget {
  const GalleryThemeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final ink = _GalleryInk.of(context);
    return DecoratedBox(
      key: const Key('gallery-theme-control'),
      decoration: ink.pill,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeChip(
            label: '浅色',
            selected: mode == ThemeMode.light,
            ink: ink,
            onTap: () => onChanged(ThemeMode.light),
            chipKey: const Key('gallery-theme-light'),
            selectedKey: const Key('gallery-theme-light-on'),
          ),
          _ThemeChip(
            label: '暗黑',
            selected: mode == ThemeMode.dark,
            ink: ink,
            onTap: () => onChanged(ThemeMode.dark),
            chipKey: const Key('gallery-theme-dark'),
            selectedKey: const Key('gallery-theme-dark-on'),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.ink,
    required this.onTap,
    required this.chipKey,
    required this.selectedKey,
  });

  final String label;
  final bool selected;
  final _GalleryInk ink;
  final VoidCallback onTap;
  final Key chipKey;
  final Key selectedKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ink.fg : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: chipKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          key: selected ? selectedKey : null,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            label,
            style: ink.label.copyWith(color: selected ? ink.onFg : ink.fg),
          ),
        ),
      ),
    );
  }
}

/// Switch only. The shell writes this into LingyunAdaptivity.reduceTransparency.
class GalleryReduceTransparencyToggle extends StatelessWidget {
  const GalleryReduceTransparencyToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ink = _GalleryInk.of(context);
    return MergeSemantics(
      child: DecoratedBox(
        decoration: ink.pill,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('降低透明度', style: ink.label),
              Switch(
                key: const Key('gallery-reduce-transparency'),
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GalleryDeviceButton extends StatelessWidget {
  const GalleryDeviceButton({
    super.key,
    required this.frame,
    required this.onChanged,
  });

  final GalleryPreviewFrame frame;
  final ValueChanged<GalleryPreviewFrame> onChanged;

  @override
  Widget build(BuildContext context) {
    final ink = _GalleryInk.of(context);
    return PopupMenuButton<GalleryPreviewFrame>(
      key: const Key('gallery-device-control'),
      tooltip: '画板尺寸',
      initialValue: frame,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final item in GalleryPreviewFrame.values)
          PopupMenuItem(
            key: Key('gallery-device-option-${item.query}'),
            value: item,
            child: Text(item.label),
          ),
      ],
      child: DecoratedBox(
        decoration: ink.pill,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.devices_outlined, size: 18, color: ink.fg),
              const SizedBox(width: 6),
              Text(frame.shortLabel, style: ink.label),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centers and clips [child] to [frame].
///
/// The child lays out at [GalleryPreviewFrame.logicalSize]. When the
/// window is smaller, the board — bezel included — scales down uniformly
/// (`scale ≤ 1`) and stays centered. Nothing is stretched, and there is no
/// [InteractiveViewer]. Callers keep the preview cluster and the window
/// backdrop outside this box. 「自适应窗口」 returns [child] with no bezel.
///
/// [backdrop] is painted inside the clip, under [child]. [FittedBox] and
/// the clip keep the Dock's backdrop filter from seeing the window
/// wallpaper, so the board carries its own copy. The default matches
/// [SystemWallpaper].
///
/// Platform identity is [Theme.platform] via `Theme.copyWith(platform:)`,
/// plus [MediaQuery.size] / padding / viewPadding from the frame. Widgets
/// that still call [defaultTargetPlatform] see the same value in debug
/// builds through [bindGalleryFramePlatform]. That setter throws outside
/// debug mode (including a release web build), so those builds rely on
/// [Theme.platform] and [MediaQuery] alone. The vector bezel is a sibling
/// outside the clip and does not hit-test.
class GalleryDeviceStage extends StatelessWidget {
  const GalleryDeviceStage({
    super.key,
    required this.frame,
    required this.child,
    this.backdrop = const SystemWallpaper(keyPrefix: 'gallery-device-bg'),
  });

  final GalleryPreviewFrame frame;
  final Widget child;

  /// Sample source for glass inside the board.
  final Widget backdrop;

  @override
  Widget build(BuildContext context) {
    final logical = frame.logicalSize;
    if (logical == null) return child;
    final metrics = _BezelMetrics.of(frame.form);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final outerWidth = logical.width + metrics.outset.horizontal;
        final outerHeight = logical.height + metrics.outset.vertical;
        final scale = (!maxW.isFinite || !maxH.isFinite)
            ? 1.0
            : math.min(1, math.min(maxW / outerWidth, maxH / outerHeight));
        final media = MediaQuery.of(context);
        final safe = frame.safePadding;
        return Center(
          child: SizedBox(
            width: outerWidth * scale,
            height: outerHeight * scale,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FittedBox(
                    child: SizedBox(
                      width: outerWidth,
                      height: outerHeight,
                      child: IgnorePointer(
                        key: const Key('gallery-device-bezel'),
                        child: CustomPaint(
                          painter: _DeviceBezelPainter(
                            form: frame.form,
                            platform: frame.platform,
                            metrics: metrics,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: metrics.outset.left * scale,
                  top: metrics.outset.top * scale,
                  width: logical.width * scale,
                  height: logical.height * scale,
                  child: SizedBox(
                    key: const Key('gallery-device-frame'),
                    width: logical.width * scale,
                    height: logical.height * scale,
                    child: FittedBox(
                      child: SizedBox(
                        width: logical.width,
                        height: logical.height,
                        child: _FramePlatform(
                          platform: frame.platform,
                          child: MediaQuery(
                            data: media.copyWith(
                              size: logical,
                              padding: safe,
                              viewPadding: safe,
                              viewInsets: EdgeInsets.zero,
                              systemGestureInsets: EdgeInsets.zero,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                metrics.screenRadius,
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  IgnorePointer(child: backdrop),
                                  child,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Owns [bindGalleryFramePlatform] for a board that is mounted on its own.
///
/// The app also binds before `setState`, so switching back to 「自适应窗口」
/// clears the override before the unframed page builds. Dispose clears it
/// only when this frame is still the published value.
class _FramePlatform extends StatefulWidget {
  const _FramePlatform({required this.platform, required this.child});

  final TargetPlatform? platform;
  final Widget child;

  @override
  State<_FramePlatform> createState() => _FramePlatformState();
}

class _FramePlatformState extends State<_FramePlatform> {
  @override
  void initState() {
    super.initState();
    bindGalleryFramePlatform(widget.platform);
  }

  @override
  void didUpdateWidget(_FramePlatform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.platform != widget.platform) {
      bindGalleryFramePlatform(widget.platform);
    }
  }

  @override
  void dispose() {
    if (kDebugMode && debugDefaultTargetPlatformOverride == widget.platform) {
      debugDefaultTargetPlatformOverride = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform;
    if (platform == null) return widget.child;
    return Theme(
      data: Theme.of(context).copyWith(platform: platform),
      child: widget.child,
    );
  }
}

class _BezelMetrics {
  const _BezelMetrics({
    required this.outset,
    required this.screenRadius,
    required this.outerRadius,
  });

  /// Thickness outside the logical screen. Left and right match so the
  /// screen stays centered in the stage.
  final EdgeInsets outset;
  final double screenRadius;
  final double outerRadius;

  static const _BezelMetrics _window = _BezelMetrics(
    outset: EdgeInsets.zero,
    screenRadius: 0,
    outerRadius: 0,
  );

  static _BezelMetrics of(GalleryPreviewForm form) => switch (form) {
    GalleryPreviewForm.window => _window,
    GalleryPreviewForm.phone => const _BezelMetrics(
      outset: EdgeInsets.all(14),
      screenRadius: 36,
      outerRadius: 50,
    ),
    GalleryPreviewForm.pad => const _BezelMetrics(
      outset: EdgeInsets.all(18),
      screenRadius: 18,
      outerRadius: 36,
    ),
    GalleryPreviewForm.duo => const _BezelMetrics(
      outset: EdgeInsets.all(12),
      screenRadius: 16,
      outerRadius: 28,
    ),
    GalleryPreviewForm.desktop => const _BezelMetrics(
      outset: EdgeInsets.fromLTRB(8, 32, 8, 8),
      screenRadius: 8,
      outerRadius: 14,
    ),
  };
}

/// Vector device shell. No image assets. Painted behind the screen and
/// wrapped in [IgnorePointer] by the stage.
class _DeviceBezelPainter extends CustomPainter {
  const _DeviceBezelPainter({
    required this.form,
    required this.platform,
    required this.metrics,
  });

  final GalleryPreviewForm form;
  final TargetPlatform? platform;
  final _BezelMetrics metrics;

  static const Color _metalTop = Color(0xFF3A3A3C);
  static const Color _metalMid = Color(0xFF1C1C1E);
  static const Color _metalBottom = Color(0xFF0E0E10);
  static const Color _edge = Color(0xFF8E8E93);
  static const Color _slot = Color(0xFF050506);

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(metrics.outerRadius),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_metalTop, _metalMid, _metalBottom],
        ).createShader(Offset.zero & size),
    );
    canvas.drawRRect(
      outer.deflate(0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _edge.withValues(alpha: 0.55),
    );

    final screen = Rect.fromLTWH(
      metrics.outset.left,
      metrics.outset.top,
      size.width - metrics.outset.horizontal,
      size.height - metrics.outset.vertical,
    );
    final lip = RRect.fromRectAndRadius(
      screen.inflate(1.2),
      Radius.circular(metrics.screenRadius + 1.2),
    );
    canvas.drawRRect(
      lip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x66FFFFFF),
    );

    switch (form) {
      case GalleryPreviewForm.phone:
        _paintEarpiece(canvas, size, screen);
        _paintSideButton(canvas, size, top: screen.top + 84, height: 28);
        _paintSideButton(canvas, size, top: screen.top + 124, height: 48);
      case GalleryPreviewForm.pad:
        _paintCamera(canvas, size, screen, radius: 4);
      case GalleryPreviewForm.duo:
        _paintCamera(canvas, size, screen, radius: 3.2);
        _paintHinge(canvas, size, screen);
      case GalleryPreviewForm.desktop:
        _paintDesktopChrome(canvas, size, screen);
      case GalleryPreviewForm.window:
        break;
    }
  }

  void _paintEarpiece(Canvas canvas, Size size, Rect screen) {
    final ear = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, screen.top / 2),
        width: 58,
        height: 5,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(ear, Paint()..color = _slot);
  }

  void _paintCamera(
    Canvas canvas,
    Size size,
    Rect screen, {
    required double radius,
  }) {
    final center = Offset(size.width / 2, screen.top / 2);
    canvas.drawCircle(center, radius, Paint()..color = _slot);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF5C5C60),
    );
  }

  void _paintSideButton(
    Canvas canvas,
    Size size, {
    required double top,
    required double height,
  }) {
    final button = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 3.2, top, 2.2, height),
      const Radius.circular(1),
    );
    canvas.drawRRect(button, Paint()..color = const Color(0xFF5A5A5E));
  }

  void _paintHinge(Canvas canvas, Size size, Rect screen) {
    final paint = Paint()..color = const Color(0xFF3A3A3E);
    final mid = screen.center.dy;
    for (final x in [
      metrics.outset.left / 2,
      size.width - metrics.outset.right / 2,
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, mid), width: 3, height: 36),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  void _paintDesktopChrome(Canvas canvas, Size size, Rect screen) {
    canvas.drawLine(
      Offset(screen.left, screen.top),
      Offset(screen.right, screen.top),
      Paint()..color = const Color(0x33FFFFFF),
    );
    final y = screen.top / 2;
    if (platform == TargetPlatform.windows) {
      _paintWindowsGlyphs(canvas, size, y);
      return;
    }
    const lights = <Color>[
      Color(0xFFFF5F57),
      Color(0xFFFEBC2E),
      Color(0xFF28C840),
    ];
    for (var i = 0; i < lights.length; i++) {
      canvas.drawCircle(Offset(16 + i * 16, y), 5, Paint()..color = lights[i]);
    }
  }

  void _paintWindowsGlyphs(Canvas canvas, Size size, double y) {
    final paint = Paint()
      ..color = const Color(0xFFE6E6EA)
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final closeX = size.width - 16;
    final maxX = closeX - 20;
    final minX = maxX - 20;
    canvas.drawLine(
      Offset(minX - 4.5, y + 3),
      Offset(minX + 4.5, y + 3),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(maxX, y), width: 9, height: 9),
        const Radius.circular(1),
      ),
      paint,
    );
    canvas.drawLine(
      Offset(closeX - 4.5, y - 4.5),
      Offset(closeX + 4.5, y + 4.5),
      paint,
    );
    canvas.drawLine(
      Offset(closeX - 4.5, y + 4.5),
      Offset(closeX + 4.5, y - 4.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DeviceBezelPainter oldDelegate) =>
      oldDelegate.form != form || oldDelegate.platform != platform;
}

class _GalleryInk {
  const _GalleryInk({required this.fg, required this.onFg, required this.bg});

  final Color fg;
  final Color onFg;
  final Color bg;

  static _GalleryInk of(BuildContext context) {
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final fg = dark ? Colors.white : const Color(0xFF1A1A1A);
    return _GalleryInk(
      fg: fg,
      onFg: dark ? const Color(0xFF1A1A1A) : Colors.white,
      bg: dark ? const Color(0xCC1C1C1E) : const Color(0xE6FFFFFF),
    );
  }

  BoxDecoration get pill => BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: fg.withValues(alpha: 0.16)),
  );

  TextStyle get label =>
      TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13);
}
