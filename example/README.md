# lingyun-ui-flutter example

Root chrome is `LingyunPage` with Dock tabs (Liquid Glass, not a Material
rail or bar, and not the sidebar rail) for four groups: **基础**, **控件**,
**浮层**, **导航壳**. A tab opens that group's workbench page
(**基础工作台**, **控件工作台**, **浮层工作台**, **导航壳工作台**).
Each workbench has several sections. Every section is an inset grouped
list (Materials Regular, not Liquid Glass) labeled with the workbench
name. The page sits on the system grouped background.
A row pushes the demo; **返回** goes back to the workbench. These tabs are
not the **标签栏** component demo (`?page=tabs`).

No `?page=` opens the 基础 workbench. `?home=` or `?tab=`
(`foundation`, `controls`, `overlays`, `chrome`) opens that workbench
without a demo; a known `tab` wins over `home`. A known `?page=` /
`GALLERY_PAGE` still opens that demo and wins over `home` / `tab`.
`theme=light|dark|system`, `chrome=0`, and `bg` still apply. The top-right cluster also sets them: 浅色 / 暗黑, 降低透明度 (`reduceTransparency=1|0` or `a11y=reduceTransparency`), and 画板尺寸 (`device=` or `frame=`). Boards: `window` (自适应窗口), `pro` (402×874), `pro-max` (440×956), `air` (420×912), `duo-outer` (466×678), `duo-inner-landscape` (951×669), `duo-inner-portrait` (669×951). A fixed board clips and centers the demo; the cluster and the backdrop outside the board follow the same settings. The same backdrop is painted inside the board so the Dock can frost it.

Gallery: **Materials** (Ultrathin / Thin / Regular / Thick), **Glass**
(Clear / Regular S·M·L / Dock / Widget Glass swatches), **Buttons**
(`GlassButton` sizes Small / Medium / Large, states Default / Pressed /
Disabled, variants Glass, Clear, Destructive, Glass Prominent, Symbol;
`?page=buttons`), **Tabs**
(`GlassTabBar` standard + floating pill + tinted bar), Themes,
Layout (`LingyunPage` compact / regular / wide bounds), Accessibility,
**Native** (iOS `LYPage` host: compact / regular / wide notes;
`?page=native`). The UIKit skeleton is iOS-only. Gallery chrome is
Simplified Chinese. See
[`docs/IOS-LYPAGE.md`](../docs/IOS-LYPAGE.md) and
[`docs/PAGE.md`](../docs/PAGE.md).
**Alerts** (`?page=alerts`): formal system `cupertino_ui` dialog, not Liquid Glass.
浅色 / 深色 is on the page. Demo titles, buttons, and messages are Simplified Chinese.
Confirm and cancel use the kit system blue. Desktop type follows the ambient
family; SF Pro is not bundled.
**Sheets** (`?page=sheets`): Materials Thick platter, grabber, medium / large
detents. 浅色 / 深色 is on the page. Demo copy is Simplified Chinese.
Run `flutter run` from this directory, then open that query (or the 浮层工作台 row).
**操作表** (`?page=actions`, also `action-sheets`): system `cupertino_ui` action
sheet, not Liquid Glass and not the Thick sheet. Demo copy is Simplified Chinese.
**侧栏** (`?page=sidebars`): formal Materials Thick sidebar, not the Layout
page's Dock rail. 浅色 / 深色 specimens. Copy is Simplified Chinese.
**工具栏** (`?page=toolbars`): floating Liquid Glass groups. Not Dock and
not the native vertical toolbar. Copy is Simplified Chinese.
**主题** (`?page=themes` or the nav item): color swatches by default, Large
text specimens with `?page=text` or the 文本 segment. Light / dark is
浅色 / 深色. Titles, buttons, group names, and samples are Simplified Chinese.
**旋钮与轨道** (`?page=knob`, also `track` / `controls`): Controls knob and track
layer styles, composed as a circular knob on a toggle or slider track.
浅色 / 深色. Titles and notes are Simplified Chinese.
**玻璃按钮** (`?page=buttons`, also `button`): `GlassButton` sizes and states.
It is a row on **基础工作台**. The **液态玻璃** page keeps style swatches only.
**开关** / **滑杆** / **步进器** are separate leaves (`?page=toggles`, `sliders`,
`steppers`; aliases `toggle`, `slider`, `stepper`). 浅色 / 深色. Copy is
Simplified Chinese. **分段与页控** still shares one page.

**列表**（`?page=lists`）内嵌分组是内容层常规材质（Materials Regular，不是液态玻璃）加系统内嵌分组；通栏没有分组块。**文本框** / **进度**（`?page=fields|progress`）的标题、按钮、标签、占位符和辅助说明是简体中文。代码标识保持英文。

Default backdrop is the design canvas (light `#D1D1D6`, dark `#000000`).
The top-right cluster is on every page (hidden when `chrome=0`): **浅色 / 暗黑**,
**降低透明度**, **画板**, and **画布**. 画布 selects muted wash, nature,
abstract color, and a busy UI pattern. Queries: `?bg=canvas|wash|meadow|abstract|busy`,
`theme=light|dark`, `reduceTransparency=1` or `a11y=1`,
`device=` / `frame=` (`window`, `pro`, `pro-max`, `air`, `duo-outer`,
`duo-inner-landscape`, `duo-inner-portrait`).

```bash
flutter run -d chrome
flutter run -d macos
flutter run -d ios
```

Web production build (GitHub Pages):

```bash
flutter build web --base-href /lingyun-ui-flutter/
```
