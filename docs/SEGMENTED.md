# 分段控件与页面控件

Wave 1c。静态外形跟 Sketch iOS 27 / Figma Liquid Glass。动效跟系统，不跟稿面里的静帧。

## 对照了什么

| 优先级 | 出处 | 用在哪 |
| --- | --- | --- |
| 1 | [WWDC25 Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/) | 选中件是液态玻璃透镜。切换时同一块透镜移动（morph），不是两块交叉淡出。按下有 flex。Reduce Motion 关掉弹性 |
| 2 | Adopting Liquid Glass，以及 WWDC25 Build a UIKit app with the new design | 能用系统控件就用。自绘要对齐系统手感，不另造一套弹簧数字 |
| 3 | HIG Segmented Controls / Page Controls | 分段是一组互斥选项。页面控件是一排等距点，当前页是实心点，表示有序翻页，不是层级导航 |
| 4 | Sketch / Figma | 只约束静态外形。本会话 Figma MCP 额度用尽，没有复读节点。尺寸标 **待核验** |

没有把 `CupertinoSlidingSegmentedControl` 包一层。它的滑块是不透明白 / 灰（`0xFFFFFFFF` / `0xFF636366`），圆角是 iOS 17 的 9，不是液态玻璃透镜。`cupertino_ui` 里也没有页面控件。

## 静态

| 项 | 取值 | 状态 |
| --- | --- | --- |
| 小分段 | 高 32，透镜高 28 | 稿面 370×32。370 是 402 画板上的样张宽，控件随父级伸展。**待核验** |
| 大分段 | 高 50，透镜高 46 | 稿面 370×50。46 = 50 − 2×2。**待核验** |
| 内边距 / 段间距 | 2 / 4 | **待核验**。不是动效令牌 |
| 轨道 | `LingyunColors.fills.tertiary` | 系统三级填充。不是液态玻璃，不是 Materials |
| 选中透镜 | `GlassSurface` + `LiquidGlassStyle.regularSmall` | 与玻璃按钮默认材质相同。胶囊圆角与 `GlassButton` 相同。不是 Materials Thick |
| 选中标签 | 液态玻璃主色 | 与玻璃按钮一致，不是标签栏那种默认系统蓝字形 |
| `tint` | 只改选中标签 | 透镜仍是玻璃 |
| 未选中 / 禁用 | 二级色 / 三级色 | 禁用时 `onChanged == null`，透镜保留 |
| 页点 | 直径 7，间距 9 | 经典指示器外形。**待核验** vs 稿面托盘。不是令牌 |
| 当前页 | 液态玻璃主色，或 `tint` | 其余为三级色；有 `tint` 时其余为着色的低对比 |
| 托盘 | 可选，`regularSmall` | 只在忙碌背景上垫一层玻璃。圆点本身仍是内容层，不是厚材质 |
| 可点 | 默认否 | `onChanged == null` 没有点击目标。HIG 把页点当位置指示 |

## 动效

Apple 没有公布选中透镜的刚度或回弹。这里**不新增令牌**，也不把 `cupertino_ui` 里 iOS 17 滑块的 `stiffness: 503.551` 抄进库。

| 行为 | 实现 |
| --- | --- |
| 透镜 / 页点高亮移动 | `SpringDescription.withDurationAndBounce`。Flutter 写明这与 SwiftUI `spring(duration:bounce:)` 同一公式。`bounce` 不传，保持该 API 的默认值 0（临界阻尼，没有自拟过冲）。时长用已有的 `LiquidGlassMotion.quick`（180ms，本来就不是 kit token） |
| 按下 | 缩放 0.97，加上 `GlassButtonPalette.pressedVeil`。时长和曲线用 `LiquidGlassMotion.quick` / `quickCurve`，与 `GlassButton` 相同。不用 iOS 17 不透明滑块的 0.95 |
| 点按分段 | 按下只进入按下态。抬手后改选中项，透镜再弹簧滑过去 |
| 减少动态效果 | `LiquidGlassMotion.reduceMotionOf`（含 `MediaQuery.disableAnimations`）跳过弹簧，直接落点。按下时长也变为 0 |

页点高亮走同一段弹簧，不另写一个 bounce。

## 画廊

导航「分段」。`?page=segmented` 或 `segments` 打开分段。`?page=pages`、`page-controls`、`pagecontrol` 打开页点。文案是简体中文。浅色 / 深色在页上切换。

截图：[`screenshots/segmented_controls_light.png`](screenshots/segmented_controls_light.png)、[`screenshots/segmented_controls_dark.png`](screenshots/segmented_controls_dark.png)、[`screenshots/page_controls_light.png`](screenshots/page_controls_light.png)、[`screenshots/page_controls_dark.png`](screenshots/page_controls_dark.png)。

在 `example/` 重拍：

```bash
flutter test tool/capture_wave1c_screenshots.dart
```

```powershell
flutter test tool/capture_wave1c_screenshots.dart
```

```bat
flutter test tool/capture_wave1c_screenshots.dart
```
