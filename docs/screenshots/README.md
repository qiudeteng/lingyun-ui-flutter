# Screenshots

Gallery captures (committed as PNGs in this folder):

- `materials_light.png` — Materials Ultrathin / Thin / Regular / Thick, light, design canvas `#D1D1D6`, 1280×1200. Gray bands behind each plate are the specimen field (Figma Materials page), not a token.
- `materials_dark.png` — same page, dark, design canvas `#000000`, 1280×1200
- `materials.png` — alias of the light materials capture
- `glass_button_light.png` — GlassButton gallery (sizes Small / Medium / Large, states, Clear, Destructive, Glass Prominent, Symbol) on design canvas `#D1D1D6`
- `glass_button_dark.png` — same button gallery, dark, design canvas `#000000`
- `tab_bar_light.png` — Tab Bars: standard, floating pill (3, 4, and 5), tinted, light, design canvas `#D1D1D6`
- `tab_bar_dark.png` — same page, dark, design canvas `#000000`
- `alerts_light.png` — Alerts probe: system `cupertino_ui` dialogs (one button, two buttons with cancel leading, destructive, title + message, message only) on `kCupertinoModalBarrierColor`, design canvas `#D1D1D6`. Demo copy is Simplified Chinese.
- `alerts_dark.png` — same states, dark, design canvas `#000000`. Demo copy is Simplified Chinese.

Alerts captures are the system dialog from `package:cupertino_ui`, not a Liquid Glass drawing. The typeface is Flutter's desktop fallback, not SF Pro on device. Regenerate from `example/`:

```bash
flutter test tool/capture_alert_screenshots.dart
```

The color around **Clear** on `glass_button_light.png` / `glass_button_dark.png` is the gallery rich-media plate behind `LiquidGlassStyle.clear`. It is not a selection or focus ring, and it is not the button rim. Sketch Clear keeps the shared ~0.5px hairline; the plate is only there so the translucent style stays visible. It is a muted wash, not a saturated rainbow stroke. The page behind that plate is the design canvas.

Regenerate the GlassButton captures from the example gallery (1280×800, Glass page, chrome hidden, light then dark):

```bash
cd example
flutter run -d chrome
```

Open `http://localhost:<port>/?page=glass&chrome=0` and `?page=glass&theme=dark&chrome=0`, then save the viewport. The Pressed chips are pinned with `forcePressed`. Prominent Disabled is the accent fill at about 50% opacity. Blur strength in the capture is an implementation approximation, not a kit token. Control heights 28 / 34 / 50 are the Figma Text export; they are not blur sigmas.

- `page_compact_light.png` / `page_compact_dark.png` — compact portrait stage 390×844, bottom Liquid Glass Dock. Image includes a 24px design-canvas margin (`#D1D1D6` / `#000000`).
- `page_regular_light.png` / `page_regular_dark.png` — regular landscape stage 1024×768, glass rail + primary. No bottom Dock.
- `page_wide_light.png` / `page_wide_dark.png` — wide stage 1440×900 (viewport wider than 1200), rail + secondary + primary.

These are skeleton captures, not pixel sign-off against Duo / Pad / PC frames. The capture sets `themeMode` and `themeAnimationDuration: Duration.zero` so a dark shot is the `#000000` canvas, and it fills the stage instead of letterboxing every bucket inside one 1100-wide gallery view.

Regenerate from `example/` (bash, PowerShell, or cmd):

```bash
PAGE_CAPTURE=1 flutter test test/page_capture_test.dart
```

```powershell
$env:PAGE_CAPTURE='1'; flutter test test/page_capture_test.dart
```

```bat
set PAGE_CAPTURE=1&& flutter test test/page_capture_test.dart
```

Older hinge-helper captures (`layout_phone.png`, `layout_duo_cover.png`, `layout_duo_inner.png`, `layout_ipad.png`, `layout_desktop.png`) predate `LingyunPage`.

颜色和文本样式画廊（页面文案为简体中文，`chrome=0`，没有顶栏切换）：

- `colors_light.png` — 颜色页，浅色，设计画布 `#D1D1D6`，1280×1997。色块上的细边是分隔线的不透明色，用来看清浅色块，不是新的圆角或模糊 token。
- `colors_dark.png` — 同一页，深色，设计画布 `#000000`，1280×1998。
- `text_light.png` — 文本样式页，浅色，设计画布 `#D1D1D6`，1280×1202。只展示大号内容尺寸。系统字体没有打进安装包。
- `text_dark.png` — 同一页，深色，设计画布 `#000000`，1280×1202。

重新生成（在 `example/` 里，Windows 的 cmd 或 PowerShell 同样可用）：

```bash
flutter run -d chrome -t lib/foundation_app.dart
```

打开 `http://localhost:<端口>/?page=colors&theme=light&chrome=0`，以及 `theme=dark`。文本页把 `page` 换成 `text`。
