# 规格说明 — Materials ≠ Liquid Glass

权威来源：iOS 27 design lead / [Sketch UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02)。

两套系统**禁止混名**。旧的 `GlassMaterialTier` 把 Thin 当成 Clear、Thick 当成 Widget Glass，已经拆开并标为 deprecated。

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

| 官方名 | API | 用法 |
| --- | --- | --- |
| Glass | 默认 `style: LiquidGlassStyle.regularSmall` | 按钮默认，胶囊 |
| Clear | `style: LiquidGlassStyle.clear` | 丰富媒体上的备选 |
| Destructive | `role: GlassButtonRole.destructive` | 红色标签；与 Glass Prominent 叠加时为红色填充 + 白字 |
| Glass Prominent | `prominence: GlassButtonProminence.prominent` | 填充 System Blue（tinted / filled），白字 |

颜色在 `GlassButtonPalette` / `LiquidGlassTheme.buttons`（Light / Dark），不要在示例里写死。

状态：

| 状态 | 行为 |
| --- | --- |
| Default | 玻璃 + 主标签色 |
| Pressed | 缩放到 0.97，加一层 press veil（实现近似，不是 kit token）。画廊可用 `forcePressed` 钉住 |
| Disabled | `onPressed: null`。灰色标签。Glass Prominent 的彩色填充退回玻璃 |

**禁止**对按钮使用 Materials Thick。Rim 仍是约 0.5px hairline，不按档位加粗。

## Labels — Liquid Glass

| 官方名 | 值 |
| --- | --- |
| Light Primary | `#1A1A1A` |
| Dark Primary | `#EDEDED` |

API：`LiquidGlassLabels.lightPrimary` / `darkPrimary` / `primaryOf(context)`。

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

## C. Tab Bars（Liquid Glass）

权威：Sketch UI Kit 页面「Tab Bars」（iPhone portrait 优先）。条的 chrome 是 **Liquid Glass**，默认 **Dock**（不确定时用 Dock，而不是 Regular Medium/Large）。**不是** Materials Thick，也不混用 Toolbar 材料。边缘是共用的约 **0.5px hairline** + 与 `GlassButton` 相同的多层 specular，不按档位加粗。

| 样式 | API | 说明 |
| --- | --- | --- |
| Standard | `GlassTabBarStyle.standard` | 通栏、贴底；图标 + Caption；内容让出 Home Indicator，玻璃铺到屏幕底边 |
| Floating pill | `GlassTabBarStyle.floatingPill` | 悬浮胶囊（优先视觉）。402pt 画板上内容组宽：3 → **266**，4 与 5 顶到同一上限 **352**（左右留白 25）。3 → 4/5 变宽；4 与 5 同宽，格子变窄 |
| Sidebar | `GlassTabBarStyle.sidebar` | **仅 API 预留**。iPad 竖向 / sidebar 下一轮再做；当前只是竖向 Dock 列，不是成品 |

- 组件：`GlassTabBar`（别名 `LiquidGlassTabBar`）。参数：`items`、`currentIndex` / `onChanged`、`style`、`glassStyle`、`tint`、`brightness`、`tintedBar`。
- 未选中：Liquid Glass Primary（Light `#1A1A1A` / Dark `#EDEDED`）降低不透明度，近似 kit 的 LINEAR_BURN / LINEAR_DODGE。这不是选中色。
- 选中：System Blue（kit Tint，Light `#0088FF` / Dark `#0091FF`）同时作用在图标和 Caption 上。不用灰或自定义色当选中。
- **Active / Tinted 整条**：`tintedBar: true`。整条仍是 Liquid Glass，填充为 System Blue（或 `tint`），图标与 Caption 为白色。
- 项：图标（约 18）+ Caption（10 / Semibold），不是 Body。点击区域高于字形。禁用项降低对比且不触发 `onChanged`。`badge` 可画数字或圆点。
- 选中反馈是短时 **selection lens**（胶囊，`LiquidGlassMotion.quick`），**不是** Material indicator 条。
- 浮动胶囊圆角是 stadium（`BorderRadius.circular(100)`，kit `cornerRadius: 100`）。**不是** 18 / 26 / 34。胶囊左右留白大于项间距（项间距 4，项内水平 padding 8；屏幕侧留白更大）。
- `blurSigma` / `saturation` 仍是 **implementation approximation / not official Design Tokens**，来自 Dock 配方，不要当成 kit 值。
