# Popovers（Wave 2）

锚定的小块 chrome。工作表是大块 **Materials Thick**。弹出框更小，挂在锚点上。

已核对：`cupertino_ui` 1.x **没有** popover 路由。公开的 `CupertinoPopupSurface` 是对话框 / 操作表的底，不是锚点弹出框。Alerts 能包系统，是因为有 `CupertinoAlertDialog`。这里不能包，所以自绘，并且不把操作表或菜单做进来。

## 对照顺序

动效先看官方行为，Sketch / Figma 只看静态。本轮 Figma MCP 在 `get_metadata` 上被 Starter 限额挡住，Sketch **Popovers** 页没有量到像素。静态选择都标 **非约束 / 待核验**。

| 顺序 | 来源 | 用到的行为 |
| --- | --- | --- |
| 1 | WWDC25 [Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/) | 透镜（lensing）：进出场靠调节折光，而不是淡出。按压时材料立刻 flex，并被光「点亮」。从工具栏按钮长成菜单时，材料变厚、阴影和透镜更明显。Reduce Motion 降低部分效果强度，并关掉弹性 |
| 2 | [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass) · WWDC25 [Build a UIKit app](https://developer.apple.com/videos/play/wwdc2025/284/) · [Build a SwiftUI app](https://developer.apple.com/videos/play/wwdc2025/323/) | 系统 popover 会自动换成 Liquid Glass。玻璃按钮可以 morph 成 popover（`popoverPresentationController.sourceItem` / `sourceView`）。SwiftUI 说菜单、提示、弹出框从液态玻璃控件里流出来 |
| 3 | HIG Popovers | 挂在打开它的控件上，箭头指向锚点，点外面收起。紧凑宽度上系统常改成工作表。本轮不改，避免换成 Materials Thick |
| 4 | Sketch SoT [Apple iOS 27 UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02) 页 **Popovers** · `docs/FIGMA-IOS27-ACCEPTANCE.md` | 只约束静态。本轮没量到。Materials 与 Liquid Glass 不能混名。模糊 σ 仍是近似 |

## 静态（非约束）

休息态用 `GlassSurface(style: LiquidGlassStyle.regularMedium)`，不传 `tokens`，不传 `material`。

这是对 WWDC「morph 变大以后材料变厚」的档位近似：比按钮的 Regular Small 厚一档，又不是工作表的 Materials Thick，也不是程序坞。官方描述的是连续变厚，不是一档名叫 Regular Medium 的弹出框。**不在进出场之间插值 blur σ**。待核验。

箭头用同一档的 `tintColor` 铺平，自己不再跑一遍 BackdropFilter。几何在 `LingyunPopoverLayout`，全是工作值，待核验。

| 项 | 工作值 | 依据 |
| --- | --- | --- |
| 玻璃 | Regular Medium，圆角跟这档 token（26，仓库里已标待核验） | 见上，不是新半径 |
| 最大宽 / 最小宽 | 320 / 240 | 自定，不是 kit |
| 边距 / 锚点间隙 | 16 / 8 | 自定 |
| 箭头 | 底 20，高 10 | 自定 |
| 内容内边距 | 16 | 自定 |
| 遮罩 | 全透明 | HIG 点外面收起。不是 Alert / Sheet 的 scrim。稿面没量 |
| 紧凑宽度 | 仍是锚点弹出框，不改成通栏，也不改成工作表 | 桶仍走 `resolveFlutterPageBucket`。UIKit 的 compact → sheet **没做** |

条纹和材质页一样，给滤镜采样。模态路由采不到底下那一页。静态样张把条纹铺在同一个 `Stack` 底；弹出的那条路由把条纹画在盘子自己的 `Stack` 里。

## 动效

不新写弹簧 token。Meet Liquid Glass 没有公布 popover 的 mass / stiffness / damping。`cupertino_ui` 里那组临界阻尼弹簧属于对话框和操作表，不是弹出框，这里不抄。

| 手势 | 实现 | 对照 |
| --- | --- | --- |
| 弹出 | 从箭头尖端把盘子从 0 缩放到 1。时长 `LiquidGlassMotion.standard`（360ms），曲线 `standardCurve`。不透明度保持 1，没有 `FadeTransition` | morph / lensing 的近似。真正的透镜调制和按钮形变没有公开参数，**不动画 σ**。待核验 |
| 收起 | 同一条曲线缩回箭头尖端，点外面或 `Navigator.pop` | 同上 |
| 按压 | 行缩放到 **0.97**，时长 `quick`（180ms），曲线 `quickCurve`，罩层用 `GlassButtonPalette.pressedVeil` | 与 `GlassButton` 同一套 flex 近似。WWDC 说「立刻 flex 并被光点亮」，没有给出比例。待核验 |
| 锚定 | 锚点 `RenderBox` 换到 overlay 坐标。空间不够就换边。箭头中心夹在已有的中号圆角内。底边安全区取 `max(padding.bottom, viewInsets.bottom)` | HIG 箭头指向来源。键盘只抬安全区，不改成工作表。待核验 |
| 减弱动态 | `LingyunAdaptivity.reduceMotion` 或 `MediaQuery.disableAnimations` 让上述时长变成 0，曲线变成 linear。按下外形仍是 0.97，但没有过程 | 官方还会减弱效果强度并关掉弹性。本库没有单独的强度旋钮；时长归零就是现成的降级。待核验 |

锚点按钮若用 `GlassButton`，按下它时走的就是按钮自己的 flex。图库的「打开弹出框」是这种按钮。

## 不是什么

- 不是菜单，不是操作表，不是 `CupertinoContextMenu`。
- 不是 Materials Thick，不是程序坞，不是玻璃按钮的胶囊。
- 不改 `ios/` 的 Arrangement / ReservedRegion。
- 不抬 `environment.sdk`。

## API

```dart
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

final value = await showLingyunPopover<String>(
  context,
  anchorContext: anchorContext,
  builder: (context) {
    return LingyunPopoverAction(
      label: '查看详情',
      onPressed: () => Navigator.pop(context, '查看详情'),
    );
  },
);
```

宿主需要 Material `Theme`（图库的 `MaterialApp` 已经有），`GlassSurface` 才能解析 Regular Medium。路由里会包一层 `LingyunTheme`。

| 符号 | 作用 |
| --- | --- |
| `showLingyunPopover` | 从 `anchorContext` 的盒子旁边打开。返回 `Navigator.pop` 的值；点外面关掉时为 `null` |
| `LingyunPopover` | 只画箭头和 Regular Medium 盘子。图库静态样张用它 |
| `LingyunPopoverAction` | 一行。按下走玻璃按钮那套 flex |
| `LingyunPopoverPlacement` | `below` / `above` / `after` / `before`。后两个跟文字方向走 |
| `LingyunPopoverMetrics` | 按 bounds、安全区、锚点、水平 Size Class 算边和原点 |
| `LingyunPopoverMotion` | 把进出场和按压转到 `LiquidGlassMotion`。没有弹簧字段 |
| `LingyunPopoverLayout` | 宽、边距、箭头。工作值，待核验 |

`horizontalSizeClass: 'compact'` 即使画布很宽也不改材质、也不铺满。不读设备型号。

## 图库

`flutter run`（在 `example/`）后打开 `?page=popovers`（`popover` 同样）。深色加 `&theme=dark`。页上有 **浅色 / 深色**。

导航名是「弹出框」。页内标题、说明、样张、按钮都是简体中文。

- 箭头朝上、箭头朝下、箭头朝后
- 按下：行被钉在按下外形，方便看 flex 罩层
- 「打开弹出框」用当前窗口的真实锚点。点「查看详情」或「关闭」会带回文字；点外面是「已关闭」

## 自测手势

库测试 `test/lingyun_popover_test.dart` 覆盖：

1. **弹出**：前 80ms 缩放小于 1 且在变大，结束后为 1。盘子是 Regular Medium，没有淡出。
2. **收起**：点外面时缩放回落，然后路由消失。
3. **按压**：指针按下缩到 0.97；移开不关闭；再点一行才返回文字。
4. **锚定**：箭头在锚点下方并对齐；锚点贴底时盘子翻到上面。
5. **减弱动态**：一帧内缩放就是 1，路由时长为 0；按下仍是 0.97，但时长为 0。

## 截图

- `docs/screenshots/popovers_light.png`
- `docs/screenshots/popovers_dark.png`

浅色画布 `#D1D1D6`，深色 `#000000`。静态样张。按下那一格是钉住的 flex，不是新的模糊公式。

Windows / macOS / Linux 重新出图（在 `example` 目录，三条命令相同）：

```bash
flutter test tool/capture_popover_screenshots.dart
```

```powershell
flutter test tool/capture_popover_screenshots.dart
```

```bat
flutter test tool/capture_popover_screenshots.dart
```
