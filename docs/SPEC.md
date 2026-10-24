# 规格说明 — Materials ≠ Liquid Glass

权威来源：iOS 27 design lead / [Sketch UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02)。Figma 验收对照见 [`FIGMA-IOS27-ACCEPTANCE.md`](./FIGMA-IOS27-ACCEPTANCE.md)（fileKey `X2nwP1156zkZAscUSZGv9S`，Materials 页 `215:105157`，Liquid Glass Regular Small / Medium / Large `5584:32505` / `5584:32503` / `5584:32504`，Clear `5914:23547`，Tab Bars 页 `507:24689`，Tab Bar - iPhone `3:70967`，默认样例 `3:72207`）。Sketch 仍是 Layer Style 基线；Figma 没有给出反证的规则不改口。

两套系统**禁止混名**。旧的 `GlassMaterialTier` 把 Thin 当成 Clear、Thick 当成 Widget Glass，已经拆开并标为 deprecated。

Figma 变量 Frost / Depth / Refraction / Dispersion / Splay / Opacity 是**设计档位**，不是 Flutter `blurSigma` 或饱和度。本仓库不把它们写成官方 Design Token，也不从这些档位反推 σ。

## A. Materials（半透明填充）

官方名： **Ultrathin / Thin / Regular / Thick**，各有 Light + Dark。

| 官方名 | API | 用法 |
| --- | --- | --- |
| Ultrathin | `MaterialTier.ultrathin` | 最轻内容层填充 |
| Thin | `MaterialTier.thin` | 轻内容霜化 |
| Regular | `MaterialTier.regular` | 默认内容层分隔 |
| Thick | `MaterialTier.thick` | **仅** Sheet / Sidebar chrome，**不是**按钮默认 |

目录：`MaterialCatalog`（旧名 `LiquidGlassMaterials` 已 deprecated）。

## B. Liquid Glass（控件 / 浮层玻璃）

官方名： **Clear / Regular Small · Medium · Large / Dock / Widget Glass**，适用处有 Light + Dark。

| 官方名 | API | 用法 |
| --- | --- | --- |
| Clear | `LiquidGlassStyle.clear` | 丰富媒体上的玻璃；按钮备选 |
| Regular Small | `LiquidGlassStyle.regularSmall` | **按钮默认** |
| Regular Medium | `LiquidGlassStyle.regularMedium` | 中等玻璃面板 |
| Regular Large | `LiquidGlassStyle.regularLarge` | 大玻璃面板 |
| Dock | `LiquidGlassStyle.dock` | Dock / 浮动条 |
| Widget Glass | `LiquidGlassStyle.widgetGlass` | 小组件磁贴 |

目录：`LiquidGlassCatalog`。组件：`GlassButton`（默认 Regular Small）。

## GlassButton

只有这一个按钮组件，不要另起 `LiquidGlassButton` / `ProminentButton`。

对照：`docs/FIGMA-IOS27-ACCEPTANCE.md`（PR #9，Buttons 页 `507:24673`，组件 **Button - Liquid Glass - Text / Symbol**）。Figma 未复读的数字不要升成 token。

| 官方名 | API | 用法 |
| --- | --- | --- |
| Glass | 默认 `style: LiquidGlassStyle.regularSmall`，`size: GlassButtonSize.small` | 材质是 Regular Small。控件默认 **Small**。胶囊，不是 18/26/34 |
| Clear | `style: LiquidGlassStyle.clear` | 丰富媒体上的备选。外形仍是胶囊 |
| Destructive | `role: GlassButtonRole.destructive` | 红色标签（Light `#FF383C`）；与 Glass Prominent 叠加时为红色填充 + 白字 |
| Glass Prominent | `prominence: GlassButtonProminence.prominent` | White Backing + System Blue（Light `#0088FF`）+ 白字 |
| Symbol | `GlassButton.icon` | 同 Style / Destructive / Enabled。圆的直径等于该档文字按钮高度 |

尺寸（Figma Text 导出。padding 写成水平 × 垂直，因为 5×2+18=28、8×2+18=34、16×2+18=50）：

| Size | API | 高度（约） | padding |
| --- | --- | --- | --- |
| Small | `GlassButtonSize.small`（默认） | 28 | 10 × 5 |
| Medium | `GlassButtonSize.medium` | 34 | 12 × 8 |
| Large | `GlassButtonSize.large` | 50 | 20 × 16 |

「Regular Small」是**材质名**，默认控件尺寸是 Small，不是 48pt 高。字重对齐 SF Pro Medium（`FontWeight.w500`）；仓库不捆绑 SF Pro。字号 17 / 图标 18 是为了塞进上述 18pt 内容槽，Text Styles 页未复读，**不是** kit token。

颜色在 `GlassButtonPalette` / `LiquidGlassTheme.buttons`（Light / Dark），不要在示例里写死。

状态：

| 状态 | 行为 |
| --- | --- |
| Default | 玻璃 + 主标签色。Prominent 为不透明强调色，边缘仍是约 0.5px hairline + 多层 specular |
| Pressed | 缩放到 0.97，加一层 press veil（实现近似，**待核验**，不是 kit token）。稿的按钮轴没有 Pressed。画廊可用 `forcePressed` 钉住 |
| Disabled | `onPressed: null`。Glass：Tertiary 灰字，Light `#BFBFBF`，Dark `#404040`（Labels-LG Dark Tertiary）。Glass Prominent：填充保留，整体约 50% 不透明，不退回玻璃 |

**禁止**对按钮使用 Materials Thick。Rim 仍是约 0.5px hairline，不按档位加粗。Frost / Depth 不是 blur σ。

## Labels — Liquid Glass

| 官方名 | 值 |
| --- | --- |
| Light Primary | `#1A1A1A` |
| Dark Primary | `#EDEDED` |
| Light Tertiary | `#BFBFBF` |
| Dark Tertiary | `#404040` |

表单控件从 `LingyunTheme.colorsOf` 读取 `liquidGlassLabels`，不在控件里写死这些色值。`LiquidGlassLabels` 仍只保留 Primary 常量，供更早的按钮代码使用。三级色用于副标题、占位符、辅助说明、列表分隔线和进度轨道。它不是 Materials 档位。

## 表单控件（Wave 1a）

控件 chrome 用 **Liquid Glass**，不用 Materials Thick。新代码从 `package:cupertino_ui/cupertino_ui.dart` 取 Cupertino 控件，不从 `package:flutter/cupertino.dart` 或 `package:flutter/material.dart` 取。画廊这三页的可见文案是简体中文。

| 组件 | API | 说明 |
| --- | --- | --- |
| 内嵌列表 | `GlassList`（默认 `GlassListStyle.inset`） | 每一节一块 `GlassSurface`，样式 `LiquidGlassStyle.regularMedium`。行填充透明，玻璃透出来。行是 `CupertinoListTile` |
| 通栏列表 | `GlassListStyle.plain` | 无玻璃托盘，只有分隔线 |
| 文本框 | `GlassTextField` | `CupertinoTextField.borderless` 放进 `LiquidGlassStyle.regularSmall`。去掉 Cupertino 白/黑填充 |
| 进度 | `GlassProgressIndicator` | 内容层指示器，不是玻璃填充。`kind` 为 `linear` / `circular`。`value == null` 为不确定进度 |

颜色与字阶都走主题，不在控件里写死 `#1A1A1A` 或字号。标签色是 `LingyunTheme.colorsOf(context).liquidGlassLabels`（主色与三级色）。字阶是 `LingyunTextStyles` 的 Large：行标题与右侧数值为 Body，副标题为 Subheadline，节头和字段标签为强调 Footnote，节脚为 Footnote，辅助说明为 Caption 1，画廊页标题为强调 Large Title。系统蓝和系统红取同一 `LingyunColors.system`，不用另一套字面量。

列表行：leading / 标题 / 副标题 / `trailingText` / `trailing` / 可选 `CupertinoListTileChevron`。节有 header / footer。按下加一层主色 10% 的 veil（实现近似，不是 kit token）。

文本框层级：标签在字段上方；正文与占位符为 Body；`errorText` 替换辅助说明，颜色为主题系统红。聚焦与错误使用共用 `LiquidGlassTokens.hairlineWidth`（0.5）发丝描边，颜色为主题系统蓝或系统红。`forceFocused` 可钉住聚焦描边。清除按钮默认 `OverlayVisibilityMode.editing`。`obscureToggle` 提供眼睛按钮。禁用时标签改用液态玻璃三级色，并隐藏清除按钮。

进度：默认着色为主题系统蓝。线性确定进度用 `CupertinoLinearActivityIndicator`（轨道颜色由该组件绘制，没有轨道色参数）。线性不确定进度用三级色轨道加一段滑动高亮，周期 1400ms，是实现近似，不是 kit token；减少动态效果时停在静态片段。圆形确定进度用 `CupertinoActivityIndicator.partiallyRevealed`，不确定进度用 `CupertinoActivityIndicator`。减少动态效果时圆形停止旋转。`tint` 可覆盖系统蓝。

`blurSigma` / `saturation` 仍是 GlassSurface 的实现近似，不写进画廊当 kit 值。本轮不做 Toggle / Slider / Stepper / Segmented / Page Control。

完整四级（Primary / Secondary / Tertiary / Quaternary）在 `LingyunColors.liquidGlassLabels`。系统 Labels（黑 / 白 Primary）是另一组，不能拿来替代玻璃标签。

## D. Colors（系统色变量）

权威：Sketch UI Kit 色变量（公开分享 `04c24d8b-38fb-4afb-8836-36617e022f02`）。Figma Colors `0:1746` 本批 MCP 限流，没有复读。两边冲突时 Sketch 赢。

API：`LingyunColors.light` / `.dark`，`LingyunTheme`（Cupertino），`LingyunMaterialTheme.colorScheme`（仅 ColorScheme 桥）。

| 组 | 说明 |
| --- | --- |
| System Colors | Red…Brown × Light / Dark。Blue `#0088FF` / `#0091FF`，Red `#FF383C` / `#FF4245` |
| Labels | Primary 到 Quinary。浅色 Primary 是 `#000000`，不是玻璃上的 `#1A1A1A` |
| Labels - Vibrant | 到 Quaternary。浅色 Primary `#000000`，Tertiary `#BFBFBF` |
| Labels - Liquid Glass | 浅 `#1A1A1A` / 深 `#EDEDED`；Tertiary `#BFBFBF` / `#404040` |
| Backgrounds / Grouped | 各有 Primary / Secondary / Tertiary。只有深色有 Elevated |
| Fills | Primary 到 Quinary。浅色 Primary 是 `#787878` α `0x33` |
| Grays | Gray…Gray 6 |
| Separators | Opaque / Non-Opaque / Vibrant。深色 Non-Opaque 是 `#FFFFFF` α `0x1F` |

`x. Kit` 不进 API。不编造 blur / 圆角。

## E. Text Styles（Large）

权威：同一 Sketch 文档的文本样式。Figma Text `0:2194` 未复读。

API：`LingyunTextStyles`（角色名 Large Title…Caption 2），`LingyunLeading`（standard / loose / tight），`LingyunMaterialTheme.textTheme`。

| 角色 | 字号 / 行高 | 默认字重 | 强调字重 |
| --- | --- | --- | --- |
| Large Title | 34 / 41 | 400 | 700 |
| Title 1 | 28 / 34 | 400 | 700 |
| Title 2 | 22 / 28 | 400 | 700 |
| Title 3 | 20 / 25 | 400 | 600 |
| Headline | 17 / 22 | 600 | 600 |
| Body | 17 / 22 | 400 | 600 |
| Callout | 16 / 21 | 400 | 600 |
| Subheadline | 15 / 20 | 400 | 600 |
| Footnote | 13 / 18 | 400 | 600 |
| Caption 1 | 12 / 16 | 400 | 500 |
| Caption 2 | 11 / 13 | 400 | 600 |

不捆绑 SF Pro。字距导出为 0，Figma 字距 **待核验**。Dynamic Type 其它档 **待核验**。Cupertino 的 nav large title 用 Large Title 强调（700）；tab label / picker 没有对应样式，保持 Cupertino 默认。

TextTheme 桥：`headlineLarge` = Large Title，`bodyLarge` = Body，`titleMedium` = Headline，`labelMedium` = Caption 1，`labelSmall` = Caption 2。`display*` 没有 iOS 样式，不填。

画廊：`example/lib/foundation_app.dart`（`cupertino_ui`，不进旧 Material shell）。`?page=colors|text&theme=dark&chrome=0`。

## 实现备注（不是官方 Design Tokens）

以下数字是 **implementation approximation / not official Design Tokens**，不要当作 kit 值展示在 UI 上：

- `blurSigma` / `saturation`（Flutter `ImageFilter.blur` + 饱和矩阵）
- 阴影 blur 半径
- 圆角 18 / 26 / 34 — **待核验 (unverified vs Sketch)**，等在 Sketch 里量完再升级为 token

## Rim

- 约 **0.5px hairline** + Clear 同款多层 specular（灰环、侧发丝、inner-lip、顶侧高光、定向折射）
- **禁止**按档位线性加粗（不再有 0.55 → 0.85）
- `LiquidGlassTokens.hairlineWidth == 0.5`，Materials 与 Liquid Glass 共用

## 平台与 Web

同一套 API：iPhone / Duo / iPad / macOS / web。`ImageFilter.blur` **不**使用 `bounds` 命名参数（web 不兼容）。

Linux 与 web 上，`BackdropFilter` 会采样已经画进场景的内容。零模糊、不透明的 `BoxShadow` 其实是一整块实心圆角矩形。若把它垫在玻璃下面，滤镜采到的是这块底板而不是条纹，四档材质会糊成同一种乳白色。因此垫层只用带模糊的半透明投影；约 0.5px 灰环和侧向发丝改在前景描边，不进入背景采样。

## C. Tab Bars（Liquid Glass）

权威：Sketch UI Kit 页面「Tab Bars」（iPhone portrait 优先）。条的 chrome 是 **Liquid Glass**，默认 **Dock**（不确定时用 Dock，而不是 Regular Medium/Large）。**不是** Materials Thick，也不混用 Toolbar 材料。边缘是共用的约 **0.5px hairline** + 与 `GlassButton` 相同的多层 specular，不按档位加粗。

| 样式 | API | 说明 |
| --- | --- | --- |
| Standard | `GlassTabBarStyle.standard` | 通栏、贴底；图标 + Caption；内容让出 Home Indicator，玻璃铺到屏幕底边 |
| Floating pill | `GlassTabBarStyle.floatingPill` | 悬浮胶囊（优先视觉）。402pt 画板上内容组宽：3 → **266**，4 与 5 顶到同一上限 **352**（左右留白 25）。3 → 4/5 变宽；4 与 5 同宽，格子变窄 |
| Sidebar | `GlassTabBarStyle.sidebar` | Flutter 页壳在 regular / wide 用它做 **玻璃 rail**（仍是 Liquid Glass Dock，不是 Materials Thick）。**不是** iOS 27.1 竖向系统 Toolbar / Tab。竖向系统条、ReservedRegion、Arrangement 在本仓库 `ios/` 原生轨。见 [PAGE.md](PAGE.md) |

- 组件：`GlassTabBar`（别名 `LiquidGlassTabBar`）。参数：`items`、`currentIndex` / `onChanged`、`style`、`glassStyle`、`tint`、`brightness`、`tintedBar`。
- 未选中：Liquid Glass Primary（Light `#1A1A1A` / Dark `#EDEDED`）略降不透明度，近似 kit 的 LINEAR_BURN / LINEAR_DODGE，字形仍接近 Primary，而不是中灰。这个系数是实现近似，不是选中色，也不是公布的百分比。
- 选中：System Blue（kit Tint，Light `#0088FF` / Dark `#0091FF`）同时作用在图标和 Caption 上。不用灰或自定义色当选中。
- **Active / Tinted 整条**：`tintedBar: true`。整条仍是 Liquid Glass，填充为 System Blue（或 `tint`），图标与 Caption 为白色。
- 项：图标（约 18）+ Caption（10 / Semibold），不是 Body。点击区域高于字形。禁用项降低对比且不触发 `onChanged`。`badge` 可画数字或圆点。
- 选中反馈是短时 **selection lens**（胶囊，`LiquidGlassMotion.quick`），**不是** Material indicator 条。
- 浮动胶囊圆角是 stadium（`BorderRadius.circular(100)`，kit `cornerRadius: 100`）。**不是** 18 / 26 / 34。胶囊左右留白大于项间距（项间距 4，项内水平 padding 8；屏幕侧留白更大）。
- `blurSigma` / `saturation` 仍是 **implementation approximation / not official Design Tokens**，来自 Dock 配方，不要当成 kit 值。Figma 上的 Frost / Depth 同样不是这组数字。

## 待核验（给设计 QA）

对照 [`FIGMA-IOS27-ACCEPTANCE.md`](./FIGMA-IOS27-ACCEPTANCE.md) §6。下面这些仍然不是官方 token，或还没对着当前 Figma 文件复读：

| 项 | 状态 |
| --- | --- |
| 圆角 18 / 26 / 34 | **待核验**。板材工作档，不是按钮圆角。Figma Button 导出是 stadium `1000`；浮动 Tab 胶囊是 `cornerRadius: 100`。Dock 配方里的 28 只是占位，Tab Bar 会覆盖成胶囊。 |
| `blurSigma` / saturation | **待核验**。实现近似。Figma Frost=6、Depth=30、Refraction=70、Dispersion=20、Splay=20、Opacity=25 是档位，限流后未再对 `5584:32505` 与 `3:72207` 跑 `get_variable_defs`。 |
| 未选中字形不透明度 | **实现近似**（LINEAR_BURN / LINEAR_DODGE），不是 kit 百分比。 |
| Search Role、Prominent Tab 旁侧圆钮 | **非本轮**。`GlassTabBarStyle.sidebar` 已被 `LingyunPage` 用作玻璃 rail，不是 iOS 27.1 竖向系统条。 |
| Colors 页语义色（`0:1746`） | **本批已入 Sketch 变量**。Figma 页 MCP 限流，未复读。以 Sketch 色变量为准。 |
| Text Styles / Dynamic Type（`0:2194`） | **Large 字号已入 Sketch 文本样式**。Dynamic Type 其它档、Figma 字距未复读，**待核验**。Tab Caption 仍是 10 / Semibold，不在文本样式导出里。 |
| `GlassButton` 包装 | **其他工程师**。本轮不改按钮组件。 |
| `LingyunPage` wide 断点 1200、rail 宽 96 | **待核验**。见 [PAGE.md](PAGE.md)。 |
| Dynamic Type xSmall…AX5 | **待核验**。Sketch 文本样式导出只有 Large，另有 Loose / Tight leading。 |
| 字距（Figma tracking） | **待核验**。Sketch 导出为 0。不把旧稿 0.40 / −0.43 写进 token。 |
| Increased Contrast 色 | **待核验**。这次 Sketch 色变量导出没有 IC 模式。 |
| `x. Kit`（Canvas / Symbol BG） | **不进 Theme**。稿面辅助色，不是系统色。 |
| Material `secondary` / `tertiary` | **桥接，待核验**。没有单独的 Sketch 强调色，ColorScheme 里暂时重复 System Blue，避免把 Material 默认紫当成系统色。 |
| Tab Caption 10 / Semibold | **不在本批**。文本样式里没有 10pt。`GlassTabBar` 不改。 |
| Controls 旋钮 / 轨道圆角 | **未收录**。Sketch 层样式没有圆角字段。画廊示意是圆旋钮叠在轨道上（直径 24，开关轨道 64×28，滑杆轨道高 6），不是令牌。 |
| Controls 高斯半径 3 的 σ | **待核验**。检查器给的是 gaussian radius，不是 backdrop σ。渲染用了 Flutter 阴影的半径换算。 |
| Controls Plus Darker | **待核验**。令牌记下了混合模式。描边先按颜色画。 |
| Controls 按下层叠加顺序 | **待核验**。阴影在下、发光在上。 |
| Figma Controls 层样式 | **未复读**。本轮 MCP 限流。以 Sketch `Controls/*` 为准。 |
| 深色静止旋钮 | **稿面没有共享层样式**。不把开关画板上的白旋钮写成令牌。 |
| 步进器轨道 | **没有独立层样式名**。42 个层样式里没有 Stepper。 |

## D. Page 壳

Dart 契约是 `LingyunPageSpec` / `LingyunNativePage`（[IOS-LYPAGE.md](IOS-LYPAGE.md)）。Flutter 骨架是 `LingyunPage`（[PAGE.md](PAGE.md)）。规划见 [PAGE-ADAPTIVE-PLAN.md](PAGE-ADAPTIVE-PLAN.md)。

- 桶：`LingyunPageWidthBucket` = `compact` / `regular` / `wide`。wide 与 `LingyunBreakpoints.large`（**1200**）对齐，不是 kit token。没有 Duo 姿态枚举。
- 非 iOS：Compact 建议 `tab` + 底 Dock。Regular / wide 建议 `sidebar` + `GlassTabBarStyle.sidebar` 玻璃 rail（不是 Materials Thick，也不是 iOS 27.1 竖向系统条）。
- iOS：同一个 `LingyunPageSpec` 交给 `LingyunNativePage`。竖向系统 chrome、`ArrangementView`、真实 `reservedRegions` 只在 `LY_IOS_27_1_SDK=1` 时链接。

## E. Alerts（系统对话框，cupertino_ui）

权威：Sketch UI Kit 页面「Alerts」。这不是 Liquid Glass，也不是 Materials。

实现是 **iOS 包系统**：`showLingyunAlert` → `package:cupertino_ui` 的 `showCupertinoDialog` + `CupertinoAlertDialog`。不自绘一套假 Liquid Glass Alert，不套 GlassButton / Dock / Materials Thick。新代码不 import `package:flutter/cupertino.dart` 或 `package:flutter/material.dart`，也不使用 `CupertinoUiCompatibilityBridge`。

| 稿面状态 | API |
| --- | --- |
| 单按钮 | 一个 `LingyunAlertAction.confirm` |
| 双按钮 | 取消在 leading（LTR 在左）。`LingyunAlert.arrangedIndices` 会把 cancel 放到前面，即使调用方先写确认 |
| 破坏性确认 | `LingyunAlertAction.destructive` → `CupertinoDialogAction.isDestructiveAction`（系统红，不加粗） |
| 标题 + 消息 | `title` 与 `message` 都传 |
| 仅消息 | 只传 `message` |

遮罩不自定义，沿用 `kCupertinoModalBarrierColor`（浅色 `0x33000000`，深色 `0x7A000000`）。示例页与截图里的演示文案是简体中文。细节见 [`docs/ALERTS.md`](ALERTS.md)。

## F. Controls 旋钮与轨道

权威：Sketch UI Kit 层样式 `Controls/Light` 与 `Controls/Dark`（Knobs - Toggle、Tracks）。这不是 Materials 四档，也不是 Liquid Glass Clear / Regular / Dock / Widget Glass。不要把它们的填充写进 `LiquidGlassTokens.blurSigma`。

Figma 文件 `X2nwP1156zkZAscUSZGv9S` 的 Controls 层样式本轮没有复读（MCP Starter 额度用尽，`get_metadata` 失败）。冲突时仍以 Sketch 为准；Figma 没有读到，所以没有 Figma 数字可冲突。

| 稿面 | API |
| --- | --- |
| 着色轨道静止 / 按下 | `ControlLayerCatalog.track(ControlTrackFill.filled, idle \| clicked)` |
| 未着色轨道静止 / 按下 / 禁用 | `track(ControlTrackFill.unfilled, …)` |
| 着色轨道禁用 | 返回 null。稿没有这一层 |
| 浅色旋钮静止 | `knob(ControlKnobLayer.idle)`。白填充 + 阴影模糊 36、偏移 (0, 3)、黑色 5% |
| 深色旋钮静止 | 返回 null。稿没有 `Controls/Dark/Knobs - Toggle/01 - Idle` |
| 按下发光 / 按下阴影 | `clickedGlow` / `clickedShadow` |

渲染：`ControlLayerView`、`ControlKnobStack`。圆角由调用方传入；层样式里没有圆角，默认直角。叠层不裁剪，模糊 36 的阴影和外侧发光可以画出外形。按下阴影的高斯半径 3 用 Flutter 阴影的 radius→sigma 换算，标为待核验，不是 backdrop σ。Plus Darker 记在令牌上，描边先按颜色本身画。细节与 8-bit 透明度见 [`docs/CONTROLS.md`](CONTROLS.md)。

示例：导航「旋钮」，`?page=knob`（`track` / `controls` 同样打开）。浅色 / 深色可切。文案是简体中文。示意是圆旋钮叠在开关和滑杆轨道上，不是分开的扁条和 64×36 方块。
