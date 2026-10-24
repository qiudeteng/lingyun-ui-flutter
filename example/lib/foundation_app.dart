import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

import 'pages/colors_page.dart';
import 'pages/text_styles_page.dart';

/// Colors + Text gallery.
///
/// Separate from the Material shell in `main.dart` so this entry can be
/// Cupertino-only. The older gallery still hosts Materials, Glass, and
/// Tabs on the in-framework theme extension.
///
/// ```bash
/// cd example
/// flutter run -d chrome -t lib/foundation_app.dart
/// ```
///
/// `?page=colors` or `?page=text`, `&theme=dark`, `&chrome=0`.
void main() {
  final query = Uri.base.queryParameters;
  runApp(
    FoundationGallery(
      initialPage: query['page'] == 'text'
          ? FoundationPage.text
          : FoundationPage.colors,
      initialBrightness: query['theme'] == 'dark'
          ? Brightness.dark
          : Brightness.light,
      showChrome: query['chrome'] != '0',
    ),
  );
}

enum FoundationPage { colors, text }

class FoundationGallery extends StatefulWidget {
  const FoundationGallery({
    super.key,
    this.initialPage = FoundationPage.colors,
    this.initialBrightness = Brightness.light,
    this.showChrome = true,
  });

  final FoundationPage initialPage;
  final Brightness initialBrightness;
  final bool showChrome;

  @override
  State<FoundationGallery> createState() => _FoundationGalleryState();
}

class _FoundationGalleryState extends State<FoundationGallery> {
  late FoundationPage _page = widget.initialPage;
  late Brightness _brightness = widget.initialBrightness;

  @override
  void didUpdateWidget(FoundationGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPage != widget.initialPage) {
      _page = widget.initialPage;
    }
    if (oldWidget.initialBrightness != widget.initialBrightness) {
      _brightness = widget.initialBrightness;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = LingyunColors.forBrightness(_brightness);
    final canvas = _brightness == Brightness.dark
        ? colors.backgrounds.primary
        : colors.grays.gray4;
    return LingyunTheme(
      brightness: _brightness,
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: LingyunTheme.cupertinoThemeFor(_brightness),
        home: CupertinoPageScaffold(
          backgroundColor: canvas,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showChrome)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CupertinoSlidingSegmentedControl<FoundationPage>(
                          groupValue: _page,
                          children: const {
                            FoundationPage.colors: Text('颜色'),
                            FoundationPage.text: Text('文本'),
                          },
                          onValueChanged: (value) {
                            if (value != null) setState(() => _page = value);
                          },
                        ),
                        CupertinoSlidingSegmentedControl<Brightness>(
                          groupValue: _brightness,
                          children: const {
                            Brightness.light: Text('浅色'),
                            Brightness.dark: Text('深色'),
                          },
                          onValueChanged: (value) {
                            if (value != null) {
                              setState(() => _brightness = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _page == FoundationPage.colors
                      ? const ColorsPage()
                      : const TextStylesPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
