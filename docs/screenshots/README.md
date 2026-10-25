# Screenshots

Gallery chrome is Simplified Chinese. The PNGs in this folder still show the previous English labels. Re-shoot them on a Mac after this copy change. Do not treat these files as current.

Gallery captures (committed as PNGs in this folder):

- `materials_light.png` — 材质 超薄 / 薄 / 常规 / 厚，浅色，设计画布 `#D1D1D6`，1280×1200。板后灰条是材质页样张，不是令牌。越薄越能看见条纹，越厚越不透明。
- `materials_dark.png` — 同一页，深色，设计画布 `#000000`，1280×1200
- `materials.png` — 浅色材质截图的副本

示例材质页文案只有简体中文。隐藏系统栏后重拍（Linux）：

```bash
cd example
flutter build linux --debug --dart-define=GALLERY_CHROME=0 --dart-define=GALLERY_THEME=light
# 深色把 GALLERY_THEME 换成 dark。窗口 1280×1200。
```
- `glass_button_light.png` — GlassButton gallery (sizes Small / Medium / Large, states, Clear, Destructive, Glass Prominent, Symbol) on design canvas `#D1D1D6`
- `glass_button_dark.png` — same button gallery, dark, design canvas `#000000`
- `tab_bar_light.png` — Tab Bars: standard, floating pill (3, 4, and 5), tinted, light, design canvas `#D1D1D6`
- `tab_bar_dark.png` — same page, dark, design canvas `#000000`
- `alerts_light.png` — Alerts formal: system `cupertino_ui` dialogs (one button, two buttons with cancel leading, destructive, title + message, message only) on `kCupertinoModalBarrierColor`, design canvas `#D1D1D6`, 1280×960. Confirm and cancel use kit system blue. Demo copy is Simplified Chinese. The capture host is a Material theme so desktop type can follow the ambient family; it is still not SF Pro.
- `alerts_dark.png` — same states, dark, design canvas `#000000`, 1280×960. Confirm and cancel use the dark kit system blue. Demo copy is Simplified Chinese.
- [lists_light.png](./lists_light.png) / [lists_dark.png](./lists_dark.png) — 列表：内嵌分组（液态玻璃常规中号托盘）与通栏。浅色画布 `#D1D1D6`，深色画布 `#000000`，1280×900，隐藏导航。页面文案为简体中文。设计已验收。
- [text_fields_light.png](./text_fields_light.png) / [text_fields_dark.png](./text_fields_dark.png) — 文本框：默认、聚焦、错误、禁用、密码、实时编辑。同上画布与视口。设计已验收。
- [progress_light.png](./progress_light.png) / [progress_dark.png](./progress_dark.png) — 进度指示器：线性与圆形，确定与不确定，以及着色。同上画布与视口。设计已验收。

这六张是已验收的对照图，链接相对本目录，在 GitHub raw 上可直接打开：

- https://github.com/qiudeteng/lingyun-ui-flutter/raw/cursor/wave-1a-form-controls-633f/docs/screenshots/lists_light.png
- https://github.com/qiudeteng/lingyun-ui-flutter/raw/cursor/wave-1a-form-controls-633f/docs/screenshots/lists_dark.png
- https://github.com/qiudeteng/lingyun-ui-flutter/raw/cursor/wave-1a-form-controls-633f/docs/screenshots/text_fields_light.png
- https://github.com/qiudeteng/lingyun-ui-flutter/raw/cursor/wave-1a-form-controls-633f/docs/screenshots/text_fields_dark.png
- https://github.com/qiudeteng/lingyun-ui-flutter/raw/cursor/wave-1a-form-controls-633f/docs/screenshots/progress_light.png
- https://github.com/qiudeteng/lingyun-ui-flutter/raw/cursor/wave-1a-form-controls-633f/docs/screenshots/progress_dark.png

- `sheets_light.png` — 工作表：紧凑中档、紧凑高档、宽屏浮起卡片。Chrome 是 **Materials Thick**（`d451503` 配方，未改）。文案简体中文。设计画布 `#D1D1D6`，1440×1520。
- `sheets_dark.png` — 同一版面，深色，设计画布 `#000000`，1440×1520。

在 `example/` 重拍（bash、PowerShell、cmd 相同）：

```bash
flutter test tool/capture_sheet_screenshots.dart
```

```powershell
flutter test tool/capture_sheet_screenshots.dart
```

```bat
flutter test tool/capture_sheet_screenshots.dart
```

- `action_sheets_light.png` — 操作表：标题和信息、破坏性、多项（取消在最下）、仅操作。系统 `cupertino_ui` 操作表，遮罩 `kCupertinoModalBarrierColor`，设计画布 `#D1D1D6`，1280×1400。文案简体中文。静帧，不含弹簧中间帧。
- `action_sheets_dark.png` — 同一版面，深色，设计画布 `#000000`，1280×1400。

在 `example/` 重拍（bash、PowerShell、cmd 相同）：

```bash
flutter test tool/capture_action_sheet_screenshots.dart
```

```powershell
flutter test tool/capture_action_sheet_screenshots.dart
```

```bat
flutter test tool/capture_action_sheet_screenshots.dart
```

- `popovers_light.png` — 弹出框：箭头朝上、朝下、朝后，以及钉住的按下。Chrome 是 **液态玻璃 Regular Medium**（非约束，待核验，不是厚材质）。文案简体中文。设计画布 `#D1D1D6`，1440×1200。进出场缩放不在这张静帧里。
- `popovers_dark.png` — 同一版面，深色，设计画布 `#000000`，1440×1200。

在 `example/` 重拍（bash、PowerShell、cmd 相同）：

```bash
flutter test tool/capture_popover_screenshots.dart
```

```powershell
flutter test tool/capture_popover_screenshots.dart
```

```bat
flutter test tool/capture_popover_screenshots.dart
```

- `menus_light.png` — 菜单：分组与破坏性、选中、禁用、按下、子菜单、锚点。Chrome 是 **Liquid Glass Regular Large**（假设，待核验）。文案简体中文。设计画布 `#D1D1D6`，1440×1180。
- `menus_dark.png` — 同一版面，深色，设计画布 `#000000`，1440×1180。

在 `example/` 重拍（bash、PowerShell、cmd 相同）：

```bash
flutter test tool/capture_menu_screenshots.dart
```

```powershell
flutter test tool/capture_menu_screenshots.dart
```

```bat
flutter test tool/capture_menu_screenshots.dart
```

地址 `?page=menus&theme=light&chrome=0`。深色把 `theme` 换成 `dark`。页上的分段也能切。弹出、收起和按压要在运行中的画廊里点「打开菜单」，截图是静止盘子。
Alerts captures are the system dialog from `package:cupertino_ui`, not a Liquid Glass drawing. Confirm and cancel are the kit system blue. The typeface on these boards is the ambient desktop family (Roboto on this Linux host, plus a CJK UI fallback when a glyph is missing), not SF Pro on device. Regenerate from `example/` (bash, PowerShell, or cmd):

```bash
flutter test tool/capture_alert_screenshots.dart
```

```powershell
flutter test tool/capture_alert_screenshots.dart
```

```bat
flutter test tool/capture_alert_screenshots.dart
```

重新截列表、文本框、进度（在 `example/build/web` 里起静态服务后，用无头浏览器打开）。这三页只作对照，验收以 example 能跑通为准：

- `?page=lists&theme=light&chrome=0&bg=canvas`
- `?page=lists&theme=dark&chrome=0&bg=canvas`
- `?page=fields&theme=light&chrome=0&bg=canvas`
- `?page=fields&theme=dark&chrome=0&bg=canvas`
- `?page=progress&theme=light&chrome=0&bg=canvas`
- `?page=progress&theme=dark&chrome=0&bg=canvas`

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

颜色和文本样式在主画廊「主题」里（文案为简体中文，`chrome=0`，没有侧栏）：

- `colors_light.png` — 主题页的颜色色板，浅色，设计画布 `#D1D1D6`，1280×2168。色块上的细边是分隔线的不透明色，用来看清浅色块，不是新的圆角或模糊 token。
- `colors_dark.png` — 同一色板，深色，设计画布 `#000000`，1280×2168。
- `text_light.png` — 主题页的文本字阶，浅色，设计画布 `#D1D1D6`，1280×1375。只展示大号内容尺寸。系统字体没有打进安装包。
- `text_dark.png` — 同一字阶，深色，设计画布 `#000000`，1280×1375。

重新生成（在 `example/` 里，Windows 的 cmd 或 PowerShell 同样可用）：

```bash
flutter run -d chrome
```

打开 `http://localhost:<端口>/?page=colors&theme=light&chrome=0`，以及 `theme=dark`。文本页把 `page` 换成 `text`。导航里点「主题」，默认就是颜色色板，再点「文本」。

- `controls_knob_track_light.png` — 旋钮与轨道，浅色，设计画布 `#D1D1D6`，1280×1160。圆旋钮叠在开关和滑杆轨道上。直径 24、开关轨道 64×28、滑杆轨道高 6 是示意外形，不是圆角令牌。四周留空，让静止阴影露出来。
- `controls_knob_track_dark.png` — 同一页，深色，设计画布 `#000000`，1280×1160。深色没有静止旋钮层样式，页上写明了。按下仍是圆旋钮叠在轨道上。

重新生成（在 `example/` 里）：

```bash
flutter test tool/capture_control_screenshots.dart
```

```powershell
flutter test tool/capture_control_screenshots.dart
```

```bat
flutter test tool/capture_control_screenshots.dart
```

导航里点「旋钮」。地址 `?page=knob&theme=light&chrome=0`，深色把 `theme` 换成 `dark`。`page=track` 和 `page=controls` 打开同一页。

开关、滑杆、步进器（导航「开关」，文案为简体中文）：

- `form_controls_toggles_light.png` / `form_controls_toggles_dark.png` — 开关：关/开、静止/按下/禁用，可点按。浅色画布 `#D1D1D6`，深色 `#000000`，1280×1500。
- `form_controls_sliders_light.png` / `form_controls_sliders_dark.png` — 滑杆中部静止、按下、禁用，可拖动。
- `form_controls_steppers_light.png` / `form_controls_steppers_dark.png` — 步进器静止、减少按下、增加按下、禁用，可点按。步进器没有旋钮。

四周留白是为了看见模糊 36 的阴影，不是令牌。深色静止旋钮不画。重新生成（在 `example/` 里）：

```bash
flutter test tool/capture_form_control_screenshots.dart
```

```powershell
flutter test tool/capture_form_control_screenshots.dart
```

```bat
flutter test tool/capture_form_control_screenshots.dart
```

地址 `?page=toggles&theme=light&chrome=0`。滑杆把 `page` 换成 `sliders`，步进器换成 `steppers`。深色把 `theme` 换成 `dark`。页上的分段也能切。

分段控件与页面控件（导航「分段」，文案为简体中文）：

- `segmented_controls_light.png` — 分段：小尺寸、按下、五段、大尺寸、禁用、着色、实时。选中透镜是液态玻璃常规小，轨道是三级填充，不是厚材质。浅色画布 `#D1D1D6`，1280×1040。
- `segmented_controls_dark.png` — 同一页，深色，设计画布 `#000000`，1280×1040。
- `page_controls_light.png` — 页点：当前点高亮，其余低对比。默认不能点。忙碌底上的托盘是液态玻璃常规小。浅色画布 `#D1D1D6`，1280×760。
- `page_controls_dark.png` — 同一页，深色，设计画布 `#000000`，1280×760。

高 32 / 50、内边距 2、段间距 4、样张宽 370、页点直径 7 与间距 9 标为待核验，不是令牌。重新生成（在 `example/` 里）：

```bash
flutter test tool/capture_wave1c_screenshots.dart
```

```powershell
flutter test tool/capture_wave1c_screenshots.dart
```

```bat
flutter test tool/capture_wave1c_screenshots.dart
```

地址 `?page=segmented&theme=light&chrome=0`。页点把 `page` 换成 `pages`。深色把 `theme` 换成 `dark`。
