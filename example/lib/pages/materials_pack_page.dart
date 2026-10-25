import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../wallpaper.dart';
import 'gallery_stripes.dart';

/// Which block of [MaterialsPackPage] a legacy `?page=` should reveal.
///
/// The page's own id (`materials-pack`) has no section: it stays at the top.
enum MaterialsPackSection {
  /// Sketch `Controls/*`. Knob and track parts.
  controls,

  /// Sketch `Liquid Glass/*`.
  liquidGlass,

  /// Sketch `Materials/*`.
  materials;

  /// Anchor for a gallery `?page=` value, or null for the page itself.
  static MaterialsPackSection? fromQuery(String? page) {
    return switch (page) {
      'knob' || 'controls' || 'track' => MaterialsPackSection.controls,
      'glass' => MaterialsPackSection.liquidGlass,
      'materials' => MaterialsPackSection.materials,
      _ => null,
    };
  }
}

/// Sketch `Materials/*` order.
///
/// Not [MaterialTier.values]: that enum runs Ultrathin → Thick.
const List<MaterialTier> _materialSketchOrder = [
  MaterialTier.thick,
  MaterialTier.regular,
  MaterialTier.thin,
  MaterialTier.ultrathin,
];

/// Sketch `Liquid Glass/*` order. Same sequence as [LiquidGlassStyle],
/// written out so a future enum reorder cannot silently invert the page.
const List<LiquidGlassStyle> _glassSketchOrder = [
  LiquidGlassStyle.clear,
  LiquidGlassStyle.regularSmall,
  LiquidGlassStyle.regularMedium,
  LiquidGlassStyle.regularLarge,
  LiquidGlassStyle.dock,
  LiquidGlassStyle.widgetGlass,
];

/// **材质封装** — Controls, then Liquid Glass, then Materials.
///
/// One leaf (`?page=materials-pack`). Legacy `materials`, `glass`, `knob`,
/// `controls`, and `track` open this page on the matching section.
/// Glass buttons stay on `?page=buttons`. Catalogs are not redefined here.
class MaterialsPackPage extends StatefulWidget {
  const MaterialsPackPage({super.key, this.initialSection});

  final MaterialsPackSection? initialSection;

  @override
  State<MaterialsPackPage> createState() => _MaterialsPackPageState();
}

class _MaterialsPackPageState extends State<MaterialsPackPage> {
  final _controlsAnchor = GlobalKey();
  final _glassAnchor = GlobalKey();
  final _materialsAnchor = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scheduleAnchor(widget.initialSection);
  }

  @override
  void didUpdateWidget(MaterialsPackPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSection != oldWidget.initialSection) {
      _scheduleAnchor(widget.initialSection);
    }
  }

  void _scheduleAnchor(MaterialsPackSection? section) {
    if (section == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = switch (section) {
        MaterialsPackSection.controls => _controlsAnchor.currentContext,
        MaterialsPackSection.liquidGlass => _glassAnchor.currentContext,
        MaterialsPackSection.materials => _materialsAnchor.currentContext,
      };
      if (target == null) return;
      Scrollable.ensureVisible(target, alignment: 0, duration: Duration.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = LingyunColors.forBrightness(Theme.brightnessOf(context));
    final label = colors.liquidGlassLabels.primary;
    final secondary = colors.liquidGlassLabels.secondary;
    return SingleChildScrollView(
      key: const Key('materials-pack-scroll'),
      padding: LingyunLayout.layoutMarginOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '材质封装',
            key: const Key('materials-pack-title'),
            style: LingyunTextStyles.largeTitle(emphasized: true, color: label),
          ),
          const SizedBox(height: 8),
          Text(
            '这一页对照层样式的三个顶层，顺序是控件层、液态玻璃、材质。'
            '材质是内容填充，不是液态玻璃。玻璃按钮在单独的一页。',
            style: LingyunTextStyles.body(color: label),
          ),
          const SizedBox(height: 28),
          KeyedSubtree(
            key: _controlsAnchor,
            child: _ControlsSection(label: label),
          ),
          const SizedBox(height: 28),
          KeyedSubtree(
            key: _glassAnchor,
            child: _GlassSection(label: label, secondary: secondary),
          ),
          const SizedBox(height: 28),
          KeyedSubtree(
            key: _materialsAnchor,
            child: _MaterialsSection(label: label, secondary: secondary),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ControlsSection extends StatelessWidget {
  const _ControlsSection({required this.label});

  final Color label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '控件层',
          key: const Key('controls-title'),
          style: LingyunTextStyles.headline(color: label),
        ),
        const SizedBox(height: 8),
        Text(
          '旋钮与轨道的零件样张。浅色和深色各一套。'
          '不是开关、滑杆或步进器，也不是材质四档，也不是液态玻璃。'
          '层样式没有圆角。圆和短条只是零件外形。'
          '深色没有静止旋钮。着色轨道没有禁用样式。',
          style: LingyunTextStyles.body(color: label),
        ),
        const SizedBox(height: 16),
        const _ControlTone(brightness: Brightness.light),
        const SizedBox(height: 12),
        const _ControlTone(brightness: Brightness.dark),
      ],
    );
  }
}

class _ControlTone extends StatelessWidget {
  const _ControlTone({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final catalog = ControlLayerCatalog.forBrightness(brightness);
    final ink = LiquidGlassLabels.primaryFor(brightness);
    final tone = brightness.name;
    final plate = brightness == Brightness.dark
        ? GalleryCanvasColors.dark
        : GalleryCanvasColors.light;
    return ColoredBox(
      color: plate,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _toneName(brightness),
              style: LingyunTextStyles.headline(color: ink),
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                if (catalog.knobIdle != null)
                  _Part(
                    label: '静止旋钮',
                    ink: ink,
                    child: _Knob(
                      key: Key('knob-$tone-idle'),
                      brightness: brightness,
                    ),
                  )
                else
                  _Part(
                    label: '静止旋钮',
                    ink: ink,
                    child: Text(
                      '深色没有静止旋钮。',
                      key: Key('knob-$tone-idle-missing'),
                      style: LingyunTextStyles.caption1(color: ink),
                    ),
                  ),
                _Part(
                  label: '按下旋钮',
                  ink: ink,
                  child: _Knob(
                    key: Key('knob-$tone-clicked'),
                    brightness: brightness,
                    clicked: true,
                  ),
                ),
                for (final track in _trackParts(catalog))
                  _Part(
                    label: track.label,
                    ink: ink,
                    child: ControlLayerView(
                      key: Key('track-$tone-${track.id}'),
                      style: track.style,
                      width: 132,
                      height: 12,
                      borderRadius: ControlMetrics.stadium(12),
                    ),
                  ),
                _Part(
                  label: '着色 · 禁用',
                  ink: ink,
                  child: Text(
                    '没有这一层。',
                    key: Key('track-$tone-filled-disabled-missing'),
                    style: LingyunTextStyles.caption1(color: ink),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackPart {
  const _TrackPart(this.id, this.label, this.style);

  final String id;
  final String label;
  final ControlLayerStyle style;
}

List<_TrackPart> _trackParts(ControlLayerCatalog catalog) {
  return [
    _TrackPart('filled-idle', '着色 · 静止', catalog.trackFilledIdle),
    _TrackPart('filled-clicked', '着色 · 按下', catalog.trackFilledClicked),
    _TrackPart('unfilled-idle', '未着色 · 静止', catalog.trackUnfilledIdle),
    _TrackPart('unfilled-clicked', '未着色 · 按下', catalog.trackUnfilledClicked),
    _TrackPart('unfilled-disabled', '未着色 · 禁用', catalog.trackUnfilledDisabled),
  ];
}

/// Caller shape only. The layer style has no corner radius.
class _Knob extends StatelessWidget {
  const _Knob({super.key, required this.brightness, this.clicked = false});

  final Brightness brightness;
  final bool clicked;

  @override
  Widget build(BuildContext context) {
    final diameter = ControlMetrics.knobDiameter;
    return SizedBox(
      width: 72,
      height: 72,
      child: Center(
        child: ControlKnobStack(
          brightness: brightness,
          width: diameter,
          height: diameter,
          clicked: clicked,
          showRingOnBlack: brightness == Brightness.dark && clicked,
          borderRadius: ControlMetrics.stadium(diameter),
        ),
      ),
    );
  }
}

class _Part extends StatelessWidget {
  const _Part({required this.label, required this.ink, required this.child});

  final String label;
  final Color ink;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: LingyunTextStyles.caption1(color: ink)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.label, required this.secondary});

  final Color label;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '液态玻璃',
          key: const Key('glass-title'),
          style: LingyunTextStyles.headline(color: label),
        ),
        const SizedBox(height: 8),
        Text(
          '清透、常规小、常规中、常规大、程序坞、小组件玻璃。'
          '浅色和深色各一套。不是材质。玻璃按钮不在这一页。',
          style: LingyunTextStyles.body(color: label),
        ),
        const SizedBox(height: 16),
        for (final style in _glassSketchOrder) ...[
          Text(
            _glassName(style),
            style: LingyunTextStyles.subheadline(
              emphasized: true,
              color: label,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _glassUsage(style),
            style: LingyunTextStyles.footnote(color: secondary),
          ),
          const SizedBox(height: 8),
          _TonePair(
            light: _GlassPlate(style: style, brightness: Brightness.light),
            dark: _GlassPlate(style: style, brightness: Brightness.dark),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _GlassPlate extends StatelessWidget {
  const _GlassPlate({required this.style, required this.brightness});

  final LiquidGlassStyle style;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final pageInk = LingyunColors.forBrightness(Theme.brightnessOf(context))
        .liquidGlassLabels
        .primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _toneName(brightness),
          style: LingyunTextStyles.caption1(color: pageInk),
        ),
        const SizedBox(height: 6),
        _ToneScope(
          brightness: brightness,
          child: _StripeField(
            child: GlassSurface(
              key: Key('glass-${brightness.name}-${style.name}'),
              style: style,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialsSection extends StatelessWidget {
  const _MaterialsSection({required this.label, required this.secondary});

  final Color label;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '材质',
          key: const Key('materials-title'),
          style: LingyunTextStyles.headline(color: label),
        ),
        const SizedBox(height: 8),
        Text(
          '厚、常规、薄、超薄。浅色和深色各一套。不是液态玻璃。'
          '条纹是样张底，用来看透度，不是设计令牌。',
          style: LingyunTextStyles.body(color: label),
        ),
        const SizedBox(height: 8),
        Text(
          '厚（Thick）只用于工作表（Sheet）和侧栏（Sidebar）。',
          key: const Key('materials-thick-note'),
          style: LingyunTextStyles.body(color: label),
        ),
        const SizedBox(height: 16),
        for (final tier in _materialSketchOrder) ...[
          Text(
            _tierTitle(tier),
            style: LingyunTextStyles.subheadline(
              emphasized: true,
              color: label,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _tierUsage(tier),
            style: LingyunTextStyles.footnote(color: secondary),
          ),
          const SizedBox(height: 8),
          _TonePair(
            light: _MaterialPlate(tier: tier, brightness: Brightness.light),
            dark: _MaterialPlate(tier: tier, brightness: Brightness.dark),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          '圆角',
          style: LingyunTextStyles.subheadline(emphasized: true, color: label),
        ),
        const SizedBox(height: 6),
        Text(
          '18 / 26 / 34 在对照官方套件量完之前标为待核验。与材质档位无关。',
          style: LingyunTextStyles.footnote(color: secondary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final scale in GlassRadiusScale.values)
              _RadiusChip(scale: scale),
          ],
        ),
      ],
    );
  }
}

class _MaterialPlate extends StatelessWidget {
  const _MaterialPlate({required this.tier, required this.brightness});

  final MaterialTier tier;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final pageInk = LingyunColors.forBrightness(Theme.brightnessOf(context))
        .liquidGlassLabels
        .primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _toneName(brightness),
          style: LingyunTextStyles.caption1(color: pageInk),
        ),
        const SizedBox(height: 6),
        _ToneScope(
          brightness: brightness,
          child: _StripeField(
            child: GlassSurface(
              key: Key('material-${brightness.name}-${tier.name}'),
              material: tier,
              radiusScale: GlassRadiusScale.large,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TonePair extends StatelessWidget {
  const _TonePair({required this.light, required this.dark});

  final Widget light;
  final Widget dark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [light, const SizedBox(height: 12), dark],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: light),
            const SizedBox(width: 16),
            Expanded(child: dark),
          ],
        );
      },
    );
  }
}

class _ToneScope extends StatelessWidget {
  const _ToneScope({required this.brightness, required this.child});

  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glass = brightness == Brightness.dark
        ? LiquidGlassTheme.dark
        : LiquidGlassTheme.light;
    return Theme(
      data: Theme.of(context)
          .copyWith(brightness: brightness, extensions: [glass]),
      child: child,
    );
  }
}

class _StripeField extends StatelessWidget {
  const _StripeField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const GalleryStripes(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.scale});

  final GlassRadiusScale scale;

  @override
  Widget build(BuildContext context) {
    final r = LiquidGlassRadii.value(scale);
    final name = switch (scale) {
      GlassRadiusScale.small => '小',
      GlassRadiusScale.medium => '中',
      GlassRadiusScale.large => '大',
    };
    final label = LingyunColors.forBrightness(Theme.brightnessOf(context))
        .liquidGlassLabels
        .primary;
    return GlassSurface(
      key: Key('radius-${scale.name}'),
      material: MaterialTier.regular,
      radiusScale: scale,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        '$name  ${r.toStringAsFixed(0)}  待核验',
        style: LingyunTextStyles.subheadline(emphasized: true, color: label),
      ),
    );
  }
}

String _toneName(Brightness brightness) {
  return brightness == Brightness.dark ? '深色' : '浅色';
}

String _tierTitle(MaterialTier tier) => switch (tier) {
  MaterialTier.thick => '厚',
  MaterialTier.regular => '常规',
  MaterialTier.thin => '薄',
  MaterialTier.ultrathin => '超薄',
};

String _tierUsage(MaterialTier tier) => switch (tier) {
  MaterialTier.thick => '厚（Thick）只用于工作表（Sheet）和侧栏（Sidebar）。',
  MaterialTier.regular => '默认的内容层分隔。不是液态玻璃的常规。',
  MaterialTier.thin => '轻霜，用于紧凑内容和行内分组。',
  MaterialTier.ultrathin => '最轻的内容填充。条纹仍能透出。',
};

String _glassName(LiquidGlassStyle style) => switch (style) {
  LiquidGlassStyle.clear => '清透',
  LiquidGlassStyle.regularSmall => '常规小',
  LiquidGlassStyle.regularMedium => '常规中',
  LiquidGlassStyle.regularLarge => '常规大',
  LiquidGlassStyle.dock => '程序坞',
  LiquidGlassStyle.widgetGlass => '小组件玻璃',
};

String _glassUsage(LiquidGlassStyle style) => switch (style) {
  LiquidGlassStyle.clear => '铺在丰富媒体上。壁纸需要保持鲜明时，可作按钮备选。',
  LiquidGlassStyle.regularSmall => '默认按钮和紧凑控件玻璃。',
  LiquidGlassStyle.regularMedium => '嵌套玻璃面板和成组控件。',
  LiquidGlassStyle.regularLarge => '大块玻璃面板。不是材质常规。',
  LiquidGlassStyle.dock => '程序坞和浮动条饰条。',
  LiquidGlassStyle.widgetGlass => '主屏幕式的小组件磁贴。',
};
