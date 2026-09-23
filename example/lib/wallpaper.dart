import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Gallery backdrops for comparing Materials / Liquid Glass with the Sketch
/// UI Kit, and for stressing refraction on richer scenes.
///
/// The kit file does not record a page-canvas hex in this repo. [canvas]
/// uses Apple systemGray4 `#D1D1D6` in light (a quiet mid gray — systemGray6
/// `#F2F2F7` is the grouped background and reads nearly white, so glass
/// vanishes against it) and `#000000` in dark (Sketch dark preview canvas /
/// `systemBackground`).
enum GalleryBackground {
  canvas('canvas', 'Canvas', 'Design canvas'),
  wash('wash', 'Wash', 'Muted wash'),
  meadow('meadow', 'Nature', 'Nature'),
  abstract('abstract', 'Color', 'Abstract color'),
  busy('busy', 'Busy', 'Busy UI');

  const GalleryBackground(this.query, this.shortLabel, this.label);

  /// `?bg=` value.
  final String query;

  /// Compact chip label.
  final String shortLabel;

  /// Menu label.
  final String label;

  static GalleryBackground fromQuery(String? raw) {
    for (final mode in GalleryBackground.values) {
      if (mode.query == raw) return mode;
    }
    return GalleryBackground.canvas;
  }
}

/// Light / dark design-canvas neutrals. See [GalleryBackground.canvas].
abstract final class GalleryCanvasColors {
  static const Color light = Color(0xFFD1D1D6);
  static const Color dark = Color(0xFF000000);
}

/// Session-wide backdrop. Tab-bar phone stages read this so they match the
/// page behind them.
class GalleryBackgroundScope extends InheritedWidget {
  const GalleryBackgroundScope({
    super.key,
    required this.mode,
    required super.child,
  });

  final GalleryBackground mode;

  static GalleryBackground modeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<GalleryBackgroundScope>();
    return scope?.mode ?? GalleryBackground.canvas;
  }

  @override
  bool updateShouldNotify(GalleryBackgroundScope oldWidget) =>
      oldWidget.mode != mode;
}

/// Backdrop behind gallery pages. Resolves [GalleryBackgroundScope].
class SystemWallpaper extends StatelessWidget {
  const SystemWallpaper({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = GalleryBackgroundScope.modeOf(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return KeyedSubtree(
      key: Key('gallery-bg-${mode.query}'),
      child: switch (mode) {
        GalleryBackground.canvas => ColoredBox(
          color: dark ? GalleryCanvasColors.dark : GalleryCanvasColors.light,
          child: const SizedBox.expand(),
        ),
        GalleryBackground.wash => _WashBackdrop(dark: dark),
        GalleryBackground.meadow => CustomPaint(
          painter: _MeadowPainter(dark: dark),
          child: const SizedBox.expand(),
        ),
        GalleryBackground.abstract => CustomPaint(
          painter: _AbstractPainter(dark: dark),
          child: const SizedBox.expand(),
        ),
        GalleryBackground.busy => CustomPaint(
          painter: _BusyUiPainter(dark: dark),
          child: const SizedBox.expand(),
        ),
      },
    );
  }
}

/// Global chip. Shown on every demo page (hidden when `chrome=0`).
class GalleryBackgroundButton extends StatelessWidget {
  const GalleryBackgroundButton({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final GalleryBackground mode;
  final ValueChanged<GalleryBackground> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final fg = dark ? Colors.white : const Color(0xFF1A1A1A);
    final bg = dark ? const Color(0xCC1C1C1E) : const Color(0xE6FFFFFF);
    return PopupMenuButton<GalleryBackground>(
      key: const Key('gallery-bg-control'),
      tooltip: 'Gallery background',
      initialValue: mode,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final item in GalleryBackground.values)
          PopupMenuItem(
            key: Key('gallery-bg-option-${item.query}'),
            value: item,
            child: Text(item.label),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: fg.withValues(alpha: 0.16)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wallpaper_outlined, size: 18, color: fg),
              const SizedBox(width: 6),
              Text(
                mode.shortLabel,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Previous muted system wash, kept as an optional comparison mode.
class _WashBackdrop extends StatelessWidget {
  const _WashBackdrop({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  Color(0xFF1A2330),
                  Color(0xFF2A3038),
                  Color(0xFF243044),
                  Color(0xFF1C2228),
                ]
              : const [
                  Color(0xFFB9C9D8),
                  Color(0xFFE4D6C4),
                  Color(0xFFC5D0C4),
                  Color(0xFFD2C8BE),
                ],
          stops: const [0.0, 0.32, 0.68, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _MutedWashPainter(dark: dark),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MutedWashPainter extends CustomPainter {
  const _MutedWashPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = dark ? const Color(0x59344A66) : const Color(0x668FA8C0);
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.2),
      size.shortestSide * 0.48,
      paint,
    );

    paint.color = dark ? const Color(0x66405670) : const Color(0x7396B0C6);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.36),
      size.shortestSide * 0.5,
      paint,
    );

    paint.color = dark ? const Color(0x4D4A4034) : const Color(0x5CC4B49A);
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.26),
      size.shortestSide * 0.44,
      paint,
    );

    paint.color = dark ? const Color(0x40384A40) : const Color(0x52A8B8A8);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.86),
      size.shortestSide * 0.56,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MutedWashPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _MeadowPainter extends CustomPainter {
  const _MeadowPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? const [Color(0xFF071422), Color(0xFF1B3E68), Color(0xFF102E32)]
            : const [Color(0xFF6EB6F2), Color(0xFFC5E4FA), Color(0xFFE9F3C9)],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    final glow = Paint()
      ..color = dark ? const Color(0x66E7E2CC) : const Color(0x99FFF6D0);
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.16),
      size.shortestSide * 0.16,
      glow,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.16),
      size.shortestSide * 0.07,
      Paint()..color = dark ? const Color(0xFFF3EFE0) : const Color(0xFFFFF4C8),
    );

    if (dark) {
      final star = Paint()..color = const Color(0xCCFFFFFF);
      const spots = <Offset>[
        Offset(0.12, 0.1),
        Offset(0.22, 0.22),
        Offset(0.4, 0.08),
        Offset(0.48, 0.2),
        Offset(0.62, 0.12),
        Offset(0.9, 0.28),
      ];
      for (final spot in spots) {
        canvas.drawCircle(
          Offset(size.width * spot.dx, size.height * spot.dy),
          1.6,
          star,
        );
      }
    }

    _hill(
      canvas,
      size,
      y: size.height * 0.62,
      bump: size.height * 0.08,
      color: dark ? const Color(0xFF1A3D34) : const Color(0xFF7EBF6A),
    );
    _hill(
      canvas,
      size,
      y: size.height * 0.74,
      bump: size.height * 0.1,
      color: dark ? const Color(0xFF123028) : const Color(0xFF3E8F55),
    );
    _hill(
      canvas,
      size,
      y: size.height * 0.86,
      bump: size.height * 0.05,
      color: dark ? const Color(0xFF0C241C) : const Color(0xFF2F6B45),
    );
  }

  void _hill(
    Canvas canvas,
    Size size, {
    required double y,
    required double bump,
    required Color color,
  }) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, y)
      ..quadraticBezierTo(size.width * 0.28, y - bump, size.width * 0.52, y)
      ..quadraticBezierTo(
        size.width * 0.8,
        y + bump * 0.55,
        size.width,
        y - bump * 0.35,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MeadowPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _AbstractPainter extends CustomPainter {
  const _AbstractPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF1A1030), Color(0xFF0E1C28)]
              : const [Color(0xFFFFF1E4), Color(0xFFE7F4FF)],
        ).createShader(rect),
    );

    final blobs = dark
        ? const <(Alignment, Color, double)>[
            (Alignment(-0.7, -0.55), Color(0xE6FF4D6D), 0.42),
            (Alignment(0.65, -0.4), Color(0xD9FFD60A), 0.36),
            (Alignment(-0.2, 0.15), Color(0xCC7C4DFF), 0.48),
            (Alignment(0.75, 0.45), Color(0xD91DE9B6), 0.4),
            (Alignment(-0.55, 0.75), Color(0xCC448AFF), 0.38),
          ]
        : const <(Alignment, Color, double)>[
            (Alignment(-0.7, -0.55), Color(0xE6FF6B6B), 0.42),
            (Alignment(0.7, -0.45), Color(0xD9FFB703), 0.34),
            (Alignment(-0.15, 0.1), Color(0xCC7B61FF), 0.46),
            (Alignment(0.8, 0.4), Color(0xD92EC4B6), 0.4),
            (Alignment(-0.6, 0.72), Color(0xCC4CC9F0), 0.36),
          ];

    for (final (alignment, color, scale) in blobs) {
      canvas.drawCircle(
        alignment.alongSize(size),
        size.shortestSide * scale,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AbstractPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

/// Home-screen-like tiles and list rows, so frost and rim have hard edges
/// to refract.
class _BusyUiPainter extends CustomPainter {
  const _BusyUiPainter({required this.dark});

  final bool dark;

  static const _palette = <Color>[
    Color(0xFF5C6BC0),
    Color(0xFFFF7043),
    Color(0xFF26A69A),
    Color(0xFFAB47BC),
    Color(0xFFFFCA28),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = dark ? const Color(0xFF16181E) : const Color(0xFFE6E2DA),
    );

    final icon = math.min(56.0, size.shortestSide * 0.08);
    final gap = icon * 0.45;
    final cols = math.max(4, (size.width / (icon + gap)).floor());
    var i = 0;
    for (var y = gap; y < size.height * 0.42; y += icon + gap) {
      for (var c = 0; c < cols; c++) {
        final x = gap + c * (icon + gap);
        final color = _palette[i % _palette.length];
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, icon, icon),
          Radius.circular(icon * 0.28),
        );
        canvas.drawRRect(
          rrect,
          Paint()..color = dark ? color.withValues(alpha: 0.85) : color,
        );
        i++;
      }
    }

    final rowTop = size.height * 0.48;
    final rowH = math.min(64.0, size.height * 0.08);
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.06,
        rowTop,
        size.width * 0.88,
        size.height * 0.46,
      ),
      const Radius.circular(22),
    );
    canvas.drawRRect(
      card,
      Paint()..color = dark ? const Color(0xFF242830) : const Color(0xFFF7F4EE),
    );

    final bar = Paint()
      ..color = dark ? const Color(0xFF3A4150) : const Color(0xFFD5D0C6);
    for (var r = 0; r < 5; r++) {
      final y = rowTop + 18 + r * (rowH * 0.85);
      if (y + 16 > rowTop + size.height * 0.46) break;
      canvas.drawCircle(
        Offset(size.width * 0.12, y + 10),
        10,
        Paint()..color = _palette[(r + 2) % _palette.length],
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.18, y + 4, size.width * 0.42, 8),
          const Radius.circular(4),
        ),
        bar,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.18, y + 16, size.width * 0.28, 6),
          const Radius.circular(4),
        ),
        bar,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BusyUiPainter oldDelegate) =>
      oldDelegate.dark != dark;
}
