import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'gallery_catalog.dart';
import 'wallpaper.dart';

/// Top-right cluster: 浅色 / 暗黑, 降低透明度, 画板, 横竖屏, 画布.
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
    this.orientation,
    this.swapOrientation = false,
    this.onOrientationChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final bool reduceTransparency;
  final ValueChanged<bool> onReduceTransparency;
  final GalleryPreviewFrame frame;
  final ValueChanged<GalleryPreviewFrame> onFrameChanged;
  final GalleryBackground background;
  final ValueChanged<GalleryBackground> onBackgroundChanged;

  /// Active `orientation=`. Null keeps each board's canonical side.
  final GalleryPreviewOrientation? orientation;

  /// Active `swap=` / `rotate=` when [orientation] is null.
  final bool swapOrientation;

  /// Sets an explicit orientation and clears [swapOrientation].
  final ValueChanged<GalleryPreviewOrientation>? onOrientationChanged;

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
        GalleryDeviceButton(
          frame: frame,
          orientation: orientation,
          swapOrientation: swapOrientation,
          onChanged: onFrameChanged,
        ),
        if (frame.canRotate && onOrientationChanged != null)
          GalleryOrientationButton(
            frame: frame,
            orientation: orientation,
            swapOrientation: swapOrientation,
            onChanged: onOrientationChanged!,
          ),
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
    this.orientation,
    this.swapOrientation = false,
  });

  final GalleryPreviewFrame frame;
  final ValueChanged<GalleryPreviewFrame> onChanged;
  final GalleryPreviewOrientation? orientation;
  final bool swapOrientation;

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
            child: Text(item.labelFor(orientation, swap: swapOrientation)),
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
              Text(
                frame.shortLabelFor(orientation, swap: swapOrientation),
                style: ink.label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tap swaps width and height of the active board.
///
/// Hidden for macOS, Windows, and 「自适应窗口」. The label is the orientation
/// the board is showing now (竖屏 / 横屏).
class GalleryOrientationButton extends StatelessWidget {
  const GalleryOrientationButton({
    super.key,
    required this.frame,
    required this.onChanged,
    this.orientation,
    this.swapOrientation = false,
  });

  final GalleryPreviewFrame frame;
  final GalleryPreviewOrientation? orientation;
  final bool swapOrientation;
  final ValueChanged<GalleryPreviewOrientation> onChanged;

  @override
  Widget build(BuildContext context) {
    final ink = _GalleryInk.of(context);
    final landscape = frame.showsLandscape(orientation, swap: swapOrientation);
    return DecoratedBox(
      decoration: ink.pill,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('gallery-orientation-control'),
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(
            landscape
                ? GalleryPreviewOrientation.portrait
                : GalleryPreviewOrientation.landscape,
          ),
          child: Padding(
            key: Key(
              landscape
                  ? 'gallery-orientation-landscape'
                  : 'gallery-orientation-portrait',
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.screen_rotation_outlined, size: 18, color: ink.fg),
                const SizedBox(width: 6),
                Text(landscape ? '横屏' : '竖屏', style: ink.label),
              ],
            ),
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
/// outside the clip and does not hit-test. Phone Dynamic Island chrome is
/// a second [IgnorePointer] painted over the screen.
class GalleryDeviceStage extends StatelessWidget {
  const GalleryDeviceStage({
    super.key,
    required this.frame,
    required this.child,
    this.backdrop = const SystemWallpaper(keyPrefix: 'gallery-device-bg'),
    this.orientation,
    this.swapOrientation = false,
  });

  final GalleryPreviewFrame frame;
  final Widget child;

  /// Sample source for glass inside the board.
  final Widget backdrop;

  /// See [GalleryPreviewFrame.logicalSizeFor].
  final GalleryPreviewOrientation? orientation;

  /// See [GalleryPreviewFrame.logicalSizeFor].
  final bool swapOrientation;

  @override
  Widget build(BuildContext context) {
    final logical = frame.logicalSizeFor(orientation, swap: swapOrientation);
    if (logical == null) return child;
    final canonical = frame.logicalSize;
    final swapped = canonical != null && canonical.width != logical.width;
    final metrics = _BezelMetrics.of(
      frame.form,
      landscape: logical.width > logical.height,
    );
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
        final safe = frame.safePaddingFor(orientation, swap: swapOrientation);
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
                            frame: frame,
                            metrics: metrics,
                            swapped: swapped,
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
                                  if (frame.form == GalleryPreviewForm.phone)
                                    IgnorePointer(
                                      key: const Key('gallery-device-camera'),
                                      child: CustomPaint(
                                        foregroundPainter:
                                            _DynamicIslandPainter(
                                              swapped: swapped,
                                            ),
                                        child: const SizedBox.expand(),
                                      ),
                                    ),
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

  static _BezelMetrics of(GalleryPreviewForm form, {bool landscape = false}) =>
      switch (form) {
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
        // Laptop fold keeps the deck under the display. Book fold parks it
        // on the right. The logical rect is only the facing screen.
        GalleryPreviewForm.duoHalf =>
          landscape
              ? const _BezelMetrics(
                  outset: EdgeInsets.fromLTRB(16, 14, 16, 96),
                  screenRadius: 16,
                  outerRadius: 26,
                )
              : const _BezelMetrics(
                  outset: EdgeInsets.fromLTRB(16, 14, 96, 16),
                  screenRadius: 16,
                  outerRadius: 26,
                ),
        // The peaked rear panel and the base hinge live in the margin.
        GalleryPreviewForm.duoTent => const _BezelMetrics(
          outset: EdgeInsets.fromLTRB(28, 36, 28, 18),
          screenRadius: 16,
          outerRadius: 24,
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
///
/// Phone, iPad, and flat Duo bezels are symmetric, so a swapped orientation
/// redraws the canonical shell and rotates it a quarter turn. The physical
/// top — and the camera on it — moves to the left. Half-fold and tent keep
/// their posture and only move the deck. Windows draws no camera. 「自适应窗口」
/// never reaches this painter.
class _DeviceBezelPainter extends CustomPainter {
  const _DeviceBezelPainter({
    required this.frame,
    required this.metrics,
    required this.swapped,
  });

  final GalleryPreviewFrame frame;
  final _BezelMetrics metrics;
  final bool swapped;

  static const Color _metalTop = Color(0xFF3A3A3C);
  static const Color _metalMid = Color(0xFF1C1C1E);
  static const Color _metalBottom = Color(0xFF0E0E10);
  static const Color _edge = Color(0xFF8E8E93);
  static const Color _slot = Color(0xFF050506);

  bool get _spins => switch (frame.form) {
    GalleryPreviewForm.phone ||
    GalleryPreviewForm.pad ||
    GalleryPreviewForm.duo => true,
    _ => false,
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (swapped && _spins) {
      canvas.save();
      // Canonical (x, y) lands at (y, canonicalWidth - x): the old top
      // edge becomes the left edge. [size] is already the swapped outer.
      canvas.transform(
        Float64List.fromList(<double>[
          0,
          -1,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          size.height,
          0,
          1,
        ]),
      );
      _paintBody(canvas, Size(size.height, size.width));
      canvas.restore();
      return;
    }
    _paintBody(canvas, size);
  }

  void _paintBody(Canvas canvas, Size size) {
    switch (frame.form) {
      case GalleryPreviewForm.duoHalf:
        _paintHalfFold(canvas, size);
        return;
      case GalleryPreviewForm.duoTent:
        _paintTent(canvas, size);
        return;
      case GalleryPreviewForm.window:
        return;
      case GalleryPreviewForm.phone:
      case GalleryPreviewForm.pad:
      case GalleryPreviewForm.duo:
      case GalleryPreviewForm.desktop:
        _paintSlab(canvas, size);
    }
    final screen = _screenRect(size);
    _paintLip(canvas, screen);
    switch (frame.form) {
      case GalleryPreviewForm.phone:
        _paintSideButton(canvas, size, top: screen.top + 84, height: 28);
        _paintSideButton(canvas, size, top: screen.top + 124, height: 48);
      case GalleryPreviewForm.pad:
        _paintLens(canvas, Offset(size.width / 2, screen.top / 2), 5);
      case GalleryPreviewForm.duo:
        _paintDuoCamera(canvas, size, screen);
        _paintHinge(canvas, size, screen);
      case GalleryPreviewForm.desktop:
        _paintDesktopChrome(canvas, size, screen);
      case GalleryPreviewForm.window:
      case GalleryPreviewForm.duoHalf:
      case GalleryPreviewForm.duoTent:
        break;
    }
  }

  Rect _screenRect(Size size) {
    return Rect.fromLTWH(
      metrics.outset.left,
      metrics.outset.top,
      size.width - metrics.outset.horizontal,
      size.height - metrics.outset.vertical,
    );
  }

  void _paintSlab(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(metrics.outerRadius),
    );
    _paintMetal(canvas, outer);
  }

  void _paintMetal(Canvas canvas, RRect rect) {
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_metalTop, _metalMid, _metalBottom],
        ).createShader(rect.outerRect),
    );
    canvas.drawRRect(
      rect.deflate(0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _edge.withValues(alpha: 0.55),
    );
  }

  void _paintLip(Canvas canvas, Rect screen) {
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
  }

  /// Front lens. The center stays dark so it reads as glass, not a highlight.
  void _paintLens(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius + 1.3,
      Paint()..color = const Color(0xFF6A6A70),
    );
    canvas.drawCircle(center, radius, Paint()..color = _slot);
    canvas.drawCircle(
      center,
      radius * 0.55,
      Paint()..color = const Color(0xFF071820),
    );
    canvas.drawCircle(
      center + Offset(-radius * 0.22, -radius * 0.24),
      radius * 0.16,
      Paint()..color = const Color(0xFF9EC4D4),
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

  /// Flat Duo front cameras, each on the canonical top bezel.
  ///
  /// Outer is centered and carries a mic dot. Inner portrait sits toward
  /// the right of the upper panel. Inner landscape sits on the right panel.
  void _paintDuoCamera(Canvas canvas, Size size, Rect screen) {
    final y = screen.top / 2;
    final Offset center = switch (frame) {
      GalleryPreviewFrame.duoInnerPortrait => Offset(
        screen.left + screen.width * 0.72,
        y,
      ),
      GalleryPreviewFrame.duoInnerLandscape => Offset(
        screen.left + screen.width * 0.78,
        y,
      ),
      _ => Offset(size.width / 2, y),
    };
    _paintLens(canvas, center, 3.6);
    if (frame == GalleryPreviewFrame.duoOuter) {
      canvas.drawCircle(
        center + const Offset(14, 0),
        1.3,
        Paint()..color = _slot,
      );
    }
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

  /// Half-fold: facing screen plus a foreshortened deck and a hinge slot.
  void _paintHalfFold(Canvas canvas, Size size) {
    final screen = _screenRect(size);
    final deckBelow = metrics.outset.bottom >= metrics.outset.right;
    final display = RRect.fromRectAndRadius(
      screen.inflate(10),
      Radius.circular(metrics.outerRadius),
    );
    final Path deck;
    final RRect hinge;
    if (deckBelow) {
      final top = screen.bottom + 16;
      final bottom = size.height - 8;
      deck = Path()
        ..moveTo(screen.left + 4, top)
        ..lineTo(screen.right - 4, top)
        ..lineTo(screen.right - 28, bottom)
        ..lineTo(screen.left + 28, bottom)
        ..close();
      hinge = RRect.fromRectAndRadius(
        Rect.fromLTWH(screen.left + 8, screen.bottom + 3, screen.width - 16, 8),
        const Radius.circular(3),
      );
    } else {
      final left = screen.right + 16;
      deck = Path()
        ..moveTo(left, screen.top + 4)
        ..lineTo(size.width - 8, screen.top + 28)
        ..lineTo(size.width - 8, screen.bottom - 28)
        ..lineTo(left, screen.bottom - 4)
        ..close();
      hinge = RRect.fromRectAndRadius(
        Rect.fromLTWH(screen.right + 3, screen.top + 8, 8, screen.height - 16),
        const Radius.circular(3),
      );
    }
    canvas.drawPath(
      deck,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A4A4E), Color(0xFF2A2A2E), Color(0xFF141416)],
        ).createShader(deck.getBounds()),
    );
    canvas.drawPath(
      deck,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _edge.withValues(alpha: 0.45),
    );
    canvas.drawRRect(hinge, Paint()..color = _slot);
    _paintMetal(canvas, display);
    _paintLip(canvas, screen);
    _paintLens(canvas, Offset(screen.center.dx, screen.top / 2), 3.6);
  }

  /// Tent / calendar stand: a peaked rear panel behind a front face.
  void _paintTent(Canvas canvas, Size size) {
    final screen = _screenRect(size);
    final rear = Path()
      ..moveTo(screen.center.dx - 42, 8)
      ..lineTo(screen.center.dx + 42, 8)
      ..lineTo(screen.right + 16, screen.bottom + 4)
      ..lineTo(screen.left - 16, screen.bottom + 4)
      ..close();
    canvas.drawPath(rear, Paint()..color = const Color(0xFF2E2E32));
    canvas.drawPath(
      rear,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _edge.withValues(alpha: 0.4),
    );
    final rearGlass = Path()
      ..moveTo(screen.center.dx - 28, 18)
      ..lineTo(screen.center.dx + 28, 18)
      ..lineTo(screen.right - 6, screen.top - 2)
      ..lineTo(screen.left + 6, screen.top - 2)
      ..close();
    canvas.drawPath(rearGlass, Paint()..color = const Color(0xFF121214));
    final front = RRect.fromRectAndRadius(
      screen.inflate(11),
      Radius.circular(metrics.outerRadius),
    );
    _paintMetal(canvas, front);
    _paintLip(canvas, screen);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(screen.center.dx, screen.bottom + 8),
          width: screen.width * 0.7,
          height: 7,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = _slot,
    );
    _paintLens(canvas, Offset(screen.center.dx, screen.top - 6), 3.4);
  }

  void _paintDesktopChrome(Canvas canvas, Size size, Rect screen) {
    canvas.drawLine(
      Offset(screen.left, screen.top),
      Offset(screen.right, screen.top),
      Paint()..color = const Color(0x33FFFFFF),
    );
    final y = screen.top / 2;
    if (frame.platform == TargetPlatform.windows) {
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
    _paintMacNotch(canvas, size, y);
  }

  /// Menu-bar notch with a camera. Stays in the top band, off the screen.
  void _paintMacNotch(Canvas canvas, Size size, double y) {
    final notch = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width / 2, y), width: 86, height: 14),
      const Radius.circular(7),
    );
    canvas.drawRRect(notch, Paint()..color = _slot);
    _paintLens(canvas, Offset(size.width / 2, y), 2.4);
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
      oldDelegate.frame != frame ||
      oldDelegate.swapped != swapped ||
      oldDelegate.metrics != metrics;
}

/// Dynamic Island over the phone screen. [IgnorePointer] in the stage.
///
/// Portrait parks the pill on the top. A swapped board parks it on the
/// left, the same physical edge the bezel rotation uses.
class _DynamicIslandPainter extends CustomPainter {
  const _DynamicIslandPainter({required this.swapped});

  final bool swapped;

  static const double _length = 126;
  static const double _thickness = 37;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = swapped
        ? Rect.fromLTWH(12, (size.height - _length) / 2, _thickness, _length)
        : Rect.fromLTWH((size.width - _length) / 2, 12, _length, _thickness);
    final island = RRect.fromRectAndRadius(
      rect,
      Radius.circular(_thickness / 2),
    );
    canvas.drawRRect(island, Paint()..color = const Color(0xFF0A0A0C));
    canvas.drawRRect(
      island,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF3A3A3C),
    );
    final lens = swapped
        ? Offset(rect.center.dx, rect.top + 22)
        : Offset(rect.right - 22, rect.center.dy);
    canvas.drawCircle(lens, 6, Paint()..color = const Color(0xFF141418));
    canvas.drawCircle(lens, 3.1, Paint()..color = const Color(0xFF071820));
    canvas.drawCircle(
      lens + const Offset(-1.2, -1.2),
      1.1,
      Paint()..color = const Color(0xFF9EC4D4),
    );
  }

  @override
  bool shouldRepaint(_DynamicIslandPainter oldDelegate) =>
      oldDelegate.swapped != swapped;
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
