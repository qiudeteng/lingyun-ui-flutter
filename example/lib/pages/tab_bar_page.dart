import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

import '../wallpaper.dart';

/// iPhone-portrait Tab Bars: standard, floating pill (3, 4, and 5), tinted.
///
/// Chrome is Liquid Glass Dock. The gallery does not print blur / saturation.
class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  int _standard = 0;
  int _float3 = 1;
  int _float4 = 0;
  int _float5 = 0;
  int _tinted = 2;

  static const _standardItems = <GlassTabBarItem>[
    GlassTabBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    GlassTabBarItem(icon: Icons.search, label: 'Search', badge: '2'),
    GlassTabBarItem(icon: Icons.grid_view_rounded, label: 'Library'),
    GlassTabBarItem(icon: Icons.lock_outline, label: 'Locked', enabled: false),
    GlassTabBarItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  static const _float5Items = <GlassTabBarItem>[
    GlassTabBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    GlassTabBarItem(icon: Icons.search, label: 'Search', badge: '3'),
    GlassTabBarItem(icon: Icons.grid_view_rounded, label: 'Library'),
    GlassTabBarItem(icon: Icons.play_circle_outline, label: 'Play'),
    GlassTabBarItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  static const _float4Items = <GlassTabBarItem>[
    GlassTabBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    GlassTabBarItem(icon: Icons.search, label: 'Search', badge: '1'),
    GlassTabBarItem(icon: Icons.grid_view_rounded, label: 'Library'),
    GlassTabBarItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  static const _float3Items = <GlassTabBarItem>[
    GlassTabBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    GlassTabBarItem(icon: Icons.search, label: 'Search'),
    GlassTabBarItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final label = LiquidGlassLabels.primaryOf(context);
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final stageWidth = wide
            ? math.min(402.0, (constraints.maxWidth - 28) / 2)
            : math.min(402.0, constraints.maxWidth);
        return ListView(
          padding: LingyunLayout.layoutMarginOf(context),
          children: [
            Text(
              'Tab Bars',
              key: const Key('tab-bar-title'),
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: label,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Liquid Glass Dock platter — not Materials Thick, and not a '
              'toolbar material. Icon + Caption. Unselected labels use '
              'Liquid Glass Primary (#1A1A1A / #EDEDED), softened. Selected '
              'icon and caption are System Blue. The floating pill is a '
              'stadium capsule; 18 / 26 / 34 are not its radius. '
              'iPad vertical / sidebar (GlassTabBarStyle.sidebar) is reserved.',
              style: text.bodyMedium?.copyWith(color: label),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 28,
              runSpacing: 28,
              children: [
                _LabeledStage(
                  width: stageWidth,
                  kicker: 'Standard · edge to bottom',
                  stageKey: const Key('tab-stage-standard'),
                  child: GlassTabBar(
                    key: const Key('tab-bar-standard'),
                    style: GlassTabBarStyle.standard,
                    glassStyle: LiquidGlassStyle.dock,
                    items: _standardItems,
                    currentIndex: _standard,
                    onChanged: (i) => setState(() => _standard = i),
                  ),
                ),
                _LabeledStage(
                  width: stageWidth,
                  kicker: 'Floating pill · 3',
                  stageKey: const Key('tab-stage-floating-3'),
                  child: GlassTabBar(
                    key: const Key('tab-bar-floating-3'),
                    style: GlassTabBarStyle.floatingPill,
                    glassStyle: LiquidGlassStyle.dock,
                    items: _float3Items,
                    currentIndex: _float3,
                    onChanged: (i) => setState(() => _float3 = i),
                  ),
                ),
                _LabeledStage(
                  width: stageWidth,
                  kicker: 'Floating pill · 4',
                  stageKey: const Key('tab-stage-floating-4'),
                  child: GlassTabBar(
                    key: const Key('tab-bar-floating-4'),
                    style: GlassTabBarStyle.floatingPill,
                    glassStyle: LiquidGlassStyle.dock,
                    items: _float4Items,
                    currentIndex: _float4,
                    onChanged: (i) => setState(() => _float4 = i),
                  ),
                ),
                _LabeledStage(
                  width: stageWidth,
                  kicker: 'Floating pill · 5',
                  stageKey: const Key('tab-stage-floating-5'),
                  child: GlassTabBar(
                    key: const Key('tab-bar-floating-5'),
                    style: GlassTabBarStyle.floatingPill,
                    glassStyle: LiquidGlassStyle.dock,
                    items: _float5Items,
                    currentIndex: _float5,
                    onChanged: (i) => setState(() => _float5 = i),
                  ),
                ),
                _LabeledStage(
                  width: stageWidth,
                  kicker: 'Tinted bar · System Blue',
                  stageKey: const Key('tab-stage-tinted'),
                  child: GlassTabBar(
                    key: const Key('tab-bar-tinted'),
                    style: GlassTabBarStyle.floatingPill,
                    glassStyle: LiquidGlassStyle.dock,
                    tintedBar: true,
                    items: _float5Items,
                    currentIndex: _tinted,
                    onChanged: (i) => setState(() => _tinted = i),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _LabeledStage extends StatelessWidget {
  const _LabeledStage({
    required this.width,
    required this.kicker,
    required this.stageKey,
    required this.child,
  });

  final double width;
  final String kicker;
  final Key stageKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final label = LiquidGlassLabels.primaryOf(context);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: label,
            ),
          ),
          const SizedBox(height: 8),
          _PhoneStage(key: stageKey, width: width, child: child),
        ],
      ),
    );
  }
}

class _PhoneStage extends StatelessWidget {
  const _PhoneStage({super.key, required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final label = LiquidGlassLabels.primaryOf(context);
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (dark ? Colors.white : Colors.black).withValues(alpha: 0.18),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          width: width,
          height: 300,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(bottom: 34),
              viewPadding: const EdgeInsets.only(bottom: 34),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const SystemWallpaper(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Library',
                      style: TextStyle(
                        color: label,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                Align(alignment: Alignment.bottomCenter, child: child),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: _HomeIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 128,
          height: 5,
          decoration: BoxDecoration(
            color: (dark ? Colors.white : Colors.black).withValues(
              alpha: dark ? 0.5 : 0.32,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
