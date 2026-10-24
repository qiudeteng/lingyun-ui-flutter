# lingyun-ui-flutter example

Gallery: **Materials** (Ultrathin / Thin / Regular / Thick), **Glass**
(Clear / Regular S·M·L / Dock / Widget Glass + GlassButton sizes
Small / Medium / Large, states Default / Pressed / Disabled, variants
Glass, Clear, Destructive, Glass Prominent, Symbol), **Tabs**
(`GlassTabBar` standard + floating pill + tinted bar), Themes,
Layout (`LingyunPage` compact / regular / wide bounds), Accessibility,
**Native** (iOS `LYPage` host: compact / regular / wide notes;
`?page=native`). The UIKit skeleton is iOS-only. See
[`docs/IOS-LYPAGE.md`](../docs/IOS-LYPAGE.md) and
[`docs/PAGE.md`](../docs/PAGE.md).
**Alerts** (`?page=alerts`): system `cupertino_ui` dialog, not Liquid Glass.
Demo titles, buttons, and messages on that page are Simplified Chinese.
**Sheets** (`?page=sheets`): Materials Thick platter, grabber, medium / large
detents. 浅色 / 深色 is on the page. Demo copy is Simplified Chinese.
Run `flutter run` from this directory, then open that query (or the 工作表 rail).
**主题** (`?page=themes` or the nav item): color swatches by default, Large
text specimens with `?page=text` or the 文本 segment. Light / dark is
浅色 / 深色. Titles, buttons, group names, and samples are Simplified Chinese.
**旋钮** (`?page=knob`, also `track` / `controls`): Controls knob and track
layer styles, composed as a circular knob on a toggle or slider track.
浅色 / 深色. Titles and notes are Simplified Chinese.
**开关** (`?page=toggles`, also `sliders` / `steppers`): live `LingyunToggle`,
`LingyunSlider`, and `LingyunStepper` on those styles. 浅色 / 深色. The
segment switches 开关 / 滑杆 / 步进器. Copy is Simplified Chinese.

**列表** / **文本框** / **进度**（`?page=lists|fields|progress`）的标题、按钮、标签、占位符和辅助说明是简体中文。代码标识保持英文。

Default backdrop is the design canvas (light `#D1D1D6`, dark `#000000`).
The **Canvas** chip on every page also selects muted wash, nature,
abstract color, and a busy UI pattern. Query: `?bg=canvas|wash|meadow|abstract|busy`
(with `page`, `theme`, `chrome=0`).

```bash
flutter run -d chrome
flutter run -d macos
flutter run -d ios
```

Web production build (GitHub Pages):

```bash
flutter build web --base-href /lingyun-ui-flutter/
```
