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
