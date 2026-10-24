import 'package:material_ui/material_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// Shows the iOS LYPage host, plus compact / regular notes when the host
/// is not in this process.
class NativePage extends StatefulWidget {
  const NativePage({super.key});

  @override
  State<NativePage> createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  LingyunPageChrome _chrome = LingyunPageChrome.tab;
  LingyunPageNavigation _navigation = LingyunPageNavigation.stack;
  LingyunPageSnapshot? _snapshot;

  LingyunPageSpec get _spec => LingyunPageSpec(
    chrome: _chrome,
    navigation: _navigation,
    primaryLabel: 'Primary',
    secondaryLabel: 'Secondary',
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final spec = _spec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Native Page',
                  key: const Key('native-page-title'),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'iOS host uses horizontal size class and this view\'s '
                  'bounds. Folded outer is Compact. Half-open and fully '
                  'open are Regular. The hinge is a reserved region.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _ChoiceRow<LingyunPageChrome>(
                  label: 'Chrome',
                  values: LingyunPageChrome.values,
                  selected: _chrome,
                  onChanged: (value) => setState(() => _chrome = value),
                ),
                const SizedBox(height: 8),
                _ChoiceRow<LingyunPageNavigation>(
                  label: 'Navigation',
                  values: LingyunPageNavigation.values,
                  selected: _navigation,
                  onChanged: (value) => setState(() => _navigation = value),
                ),
                const SizedBox(height: 12),
                _BucketNote(
                  noteKey: const Key('native-page-compact-note'),
                  title: 'Compact',
                  body:
                      'Horizontal size class Compact, including a folded '
                      'outer display. ${_line(spec, LingyunPageWidthBucket.compact)} '
                      'System tab chrome may sit on the side. Content uses '
                      'each safe-area edge.',
                ),
                _BucketNote(
                  noteKey: const Key('native-page-regular-note'),
                  title: 'Regular',
                  body:
                      'Horizontal size class Regular. Half-open and fully '
                      'open share it. ${_line(spec, LingyunPageWidthBucket.regular)} '
                      'An active division region is the hinge. Keep controls '
                      'out of that frame.',
                ),
                _BucketNote(
                  noteKey: const Key('native-page-wide-note'),
                  title: 'Wide',
                  body:
                      'Regular, and available width at least '
                      '${LingyunBreakpoints.large.toStringAsFixed(0)} pt '
                      '(LingyunBreakpoints.large, not a kit token). '
                      '${_line(spec, LingyunPageWidthBucket.wide)}',
                ),
                if (_snapshot != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Live ${_snapshot!.widthBucket} '
                    'H ${_snapshot!.horizontalSizeClass} '
                    'mounted ${_snapshot!.mountedRoot} '
                    'columns ${_snapshot!.columns}',
                    key: const Key('native-page-live'),
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white54),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LingyunNativePage(
                  key: const Key('native-page-host'),
                  spec: spec,
                  onSnapshot: (snapshot) {
                    if (!mounted) return;
                    setState(() => _snapshot = snapshot);
                  },
                  placeholder: const _HostPlaceholder(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _line(LingyunPageSpec spec, LingyunPageWidthBucket bucket) {
    final container = resolveLingyunPageContainer(spec, bucket: bucket);
    final columns = container.columns == 0
        ? 'system arrangement'
        : '${container.columns} column'
              '${container.columns == 1 ? '' : 's'}';
    return '${container.root}, $columns.';
  }
}

class _HostPlaceholder extends StatelessWidget {
  const _HostPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x22000000),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            'LYPage is an iOS platform view. This process has no UIKit '
            'host, so the skeleton is not simulated with a fixed resolution. '
            'Run the example on an iOS 27.1 SDK to see TabView, '
            'NavigationSplitView, and, when LY_IOS_27_1_SDK is set, '
            'ArrangementView.',
            key: Key('native-page-placeholder'),
          ),
        ),
      ),
    );
  }
}

class _BucketNote extends StatelessWidget {
  const _BucketNote({
    required this.noteKey,
    required this.title,
    required this.body,
  });

  final Key noteKey;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$title. ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: body),
          ],
        ),
        key: noteKey,
      ),
    );
  }
}

class _ChoiceRow<T extends Enum> extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<T> values;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label),
        for (final value in values)
          ChoiceChip(
            key: Key('native-${label.toLowerCase()}-${value.name}'),
            label: Text(value.name),
            selected: value == selected,
            onSelected: (_) => onChanged(value),
          ),
      ],
    );
  }
}
