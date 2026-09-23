import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Viewport presets that simulate the four target surfaces without hardware.
enum LayoutPreset {
  live('Live window', null, null),
  phone('iPhone compact', Size(390, 844), 'Classic phone portrait'),
  duoCover(
    'Duo cover',
    Size(780, 360),
    'Closed / wide-short, side-edge chrome',
  ),
  duoInner('Duo inner', Size(820, 640), 'Regular width + hinge band'),
  ipad('iPad', Size(1024, 768), 'Expanded / Split View capable'),
  desktop('macOS', Size(1440, 900), 'Large window, pointer hover');

  const LayoutPreset(this.label, this.size, this.caption);
  final String label;
  final Size? size;
  final String? caption;
}

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  LayoutPreset _preset = LayoutPreset.duoInner;

  @override
  void initState() {
    super.initState();
    final name = Uri.base.queryParameters['preset'];
    if (name != null) {
      for (final preset in LayoutPreset.values) {
        if (preset.name == name) {
          _preset = preset;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: LingyunLayout.layoutMarginOf(context).copyWith(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Layout',
                key: const Key('layout-title'),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Responsive breakpoints only — no device APIs. Pick a preset '
                'or use the live window (resize on macOS / web).',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in LayoutPreset.values)
                    ChoiceChip(
                      key: Key('preset-${preset.name}'),
                      label: Text(preset.label),
                      selected: _preset == preset,
                      onSelected: (_) => setState(() => _preset = preset),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _preset.size == null
                ? const _LayoutStage()
                : Center(
                    child: FittedBox(
                      child: SizedBox(
                        width: _preset.size!.width,
                        height: _preset.size!.height,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                size: _preset.size,
                                padding: _paddingFor(_preset),
                              ),
                              child: const _LayoutStage(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  static EdgeInsets _paddingFor(LayoutPreset preset) {
    return switch (preset) {
      LayoutPreset.phone => const EdgeInsets.fromLTRB(0, 47, 0, 34),
      LayoutPreset.duoCover => const EdgeInsets.fromLTRB(20, 12, 20, 12),
      LayoutPreset.duoInner => const EdgeInsets.fromLTRB(8, 20, 8, 20),
      LayoutPreset.ipad => const EdgeInsets.fromLTRB(20, 20, 20, 20),
      LayoutPreset.desktop => EdgeInsets.zero,
      LayoutPreset.live => EdgeInsets.zero,
    };
  }
}

class _LayoutStage extends StatelessWidget {
  const _LayoutStage();

  @override
  Widget build(BuildContext context) {
    return LingyunLayoutBuilder(
      builder: (context, data) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0x22000000)),
            if (data.avoidHinge) _HingeOverlay(band: data.hingeBand),
            Padding(
              padding: data.layoutMargin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassSurface(
                    material: MaterialTier.thin,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${data.widthClass.name} · '
                      '${data.size.width.toStringAsFixed(0)}×'
                      '${data.size.height.toStringAsFixed(0)}'
                      '${data.isWideShort ? ' · wide-short' : ''}'
                      '${data.avoidHinge ? ' · hinge-safe' : ''}',
                      key: const Key('layout-class-label'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LingyunSplitBody(
                      leading: GlassCard(
                        material: MaterialTier.regular,
                        child: _PaneCopy(
                          title: data.isCompact && !data.isWideShort
                              ? 'Single column'
                              : 'Leading pane',
                          body: _caption(data),
                        ),
                      ),
                      trailing: GlassCard(
                        material: MaterialTier.regular,
                        child: const _PaneCopy(
                          title: 'Trailing pane',
                          body:
                              'Split View / Duo inner / desktop two-pane. '
                              'The center gutter is not interactive.',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            LingyunSideChrome(
              leading: _EdgeButton(
                key: const Key('edge-leading'),
                icon: Icons.chevron_left_rounded,
                label: 'Back',
              ),
              trailing: _EdgeButton(
                key: const Key('edge-trailing'),
                icon: Icons.more_horiz_rounded,
                label: 'More',
              ),
            ),
          ],
        );
      },
    );
  }

  static String _caption(LingyunLayoutData data) {
    if (data.isWideShort) {
      return 'Closed-cover heuristic: place controls on the side edges, '
          'not across the short vertical center.';
    }
    return switch (data.widthClass) {
      LingyunWidthClass.compact =>
        'iPhone-style compact column. No hinge band.',
      LingyunWidthClass.regular =>
        'Duo inner / iPad Split View. Keep chrome off the center division.',
      LingyunWidthClass.expanded =>
        'iPad-width. Sidebar or split patterns; still hinge-safe.',
      LingyunWidthClass.large =>
        'Desktop-width. Resize the window; hover glass for specular lift.',
    };
  }
}

class _PaneCopy extends StatelessWidget {
  const _PaneCopy({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(body, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EdgeButton extends StatelessWidget {
  const _EdgeButton({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassButton.label(label: label, icon: icon, onPressed: () {});
  }
}

class _HingeOverlay extends StatelessWidget {
  const _HingeOverlay({required this.band});

  final Rect band;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HingePainter(band),
      child: const SizedBox.expand(),
    );
  }
}

class _HingePainter extends CustomPainter {
  _HingePainter(this.band);
  final Rect band;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0x33FFEB3B);
    canvas.drawRect(band, fill);
    final stroke = Paint()
      ..color = const Color(0xCCFFEB3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(band, stroke);
  }

  @override
  bool shouldRepaint(covariant _HingePainter oldDelegate) =>
      oldDelegate.band != band;
}
