import 'dart:math' as math;

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
/// window is smaller, the board scales down uniformly. Callers keep the
/// preview cluster and the backdrop outside this box.
class GalleryDeviceStage extends StatelessWidget {
  const GalleryDeviceStage({
    super.key,
    required this.frame,
    required this.child,
  });

  final GalleryPreviewFrame frame;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final logical = frame.logicalSize;
    if (logical == null) return child;
    final ink = _GalleryInk.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final scale = (!maxW.isFinite || !maxH.isFinite)
            ? 1.0
            : math.min(
                1,
                math.min(maxW / logical.width, maxH / logical.height),
              );
        final media = MediaQuery.of(context);
        return Center(
          child: SizedBox(
            key: const Key('gallery-device-frame'),
            width: logical.width * scale,
            height: logical.height * scale,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  child: SizedBox(
                    width: logical.width,
                    height: logical.height,
                    child: MediaQuery(
                      data: media.copyWith(
                        size: logical,
                        padding: EdgeInsets.zero,
                        viewPadding: EdgeInsets.zero,
                        viewInsets: EdgeInsets.zero,
                        systemGestureInsets: EdgeInsets.zero,
                      ),
                      child: ClipRect(child: child),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: ink.fg.withValues(alpha: 0.28)),
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
