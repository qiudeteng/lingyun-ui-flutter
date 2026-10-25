# Action Sheets（Wave 2）

iOS **系统操作表**，对照 Sketch **Action Sheets** 的静态状态，**动效对照 Apple 官方行为**。宿主是 `cupertino_ui` 1.1.4 的 `CupertinoActionSheet` + `showCupertinoModalPopup`。不是自绘 Liquid Glass，也没有本库弹簧 token。

已迁独立包 **`cupertino_ui`**。新文件不 import `flutter/cupertino` 或 `flutter/material`，不用 `CupertinoUiCompatibilityBridge`。

## 对照（按这个顺序）

| 顺序 | 来源 | 用在这里 |
| --- | --- | --- |
| 1 | [WWDC25 · Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)（219） | 透镜（lensing）进出场、按下即时 flex / 点亮、morph、Reduce Motion 关掉弹性。见下文「动效」：系统宿主没导出这些，本库不仿 |
| 2 | [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass) · [WWDC25 · Build a UIKit app with the new design](https://developer.apple.com/videos/play/wwdc2025/284/)（284） | 标准组件自己吃 Liquid Glass；操作表从触发控件长出，而不是从屏幕底边升起。`cupertino_ui` 1.1.4 没有 source anchor / morph，本库不另写 |
| 3 | [HIG · Action sheets](https://developer.apple.com/design/human-interface-guidelines/action-sheets) | 一组与当前动作相关的选择。破坏性用系统红。取消用来放弃。点外面可以关掉 |
| 4 | Sketch SoT · [Apple iOS 27 UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02) 页 **Action Sheets**；Figma 见 `docs/FIGMA-IOS27-ACCEPTANCE.md` | **只对静态**（几行、谁在上、取消是否分开、破坏性是不是红）。Figma 本轮 MCP 限流，没有复读操作表页 |

`LingyunSheet` 是 Sketch **Sheets** 的 Materials Thick 内容工作表。这一页不是它。Menus、Popovers 不在这里做。不改 `ios/` 的 Duo / Arrangement。

## 不是什么

- 不是 Liquid Glass 控件，不套 GlassButton、Dock、Materials Thick，不自绘 flex、liquid lens、morph。
- 不把 `cupertino_ui` 的私有弹簧抄成 token，也不用 `LiquidGlassMotion` 的 180 / 360 / 520 ms 或那三条曲线去替换弹出。
- 普通行不是系统蓝。包的默认 `primaryColor` 是 system blue；操作表子树把它改成 `CupertinoColors.label`，避免每一行都变成强调色。破坏性仍走 `systemRed`。
- 新文件 `lib/src/widgets/lingyun_action_sheet.dart` 与 `example/lib/pages/action_sheets_page.dart` 只 import `package:cupertino_ui/cupertino_ui.dart`（实现另外 import 本库动效辅助；示例页 import 本库）。

## 动效

有交互。弹出、收起、按压都走系统宿主；Reduce Motion 时不跑弹簧。

| 手势 | 现在怎么动 | 对照 |
| --- | --- | --- |
| 弹出 | 直接 push `CupertinoModalPopupRoute`（`showCupertinoModalPopup` 用的同一条）。子树从自身高度的正下方滑到贴底（`Offset(0, 1)` → `Offset.zero`）。时间由包内私有 `SpringSimulation` 驱动 | 包的注释写这组弹簧来自 Xcode 里的 `CASpringAnimation`。**不是本库 token**。WWDC 219 的透镜化入场、284 / Adopting Liquid Glass 的「从按钮 morph 出来」这条包没有，**不仿，待核验** |
| 收起 | 同一条路由的反向仿真，滑回底部后路由移除 | 同上 |
| 按压 | `CupertinoActionSheetAction` 按下立刻换底色，抬起立刻换回。没有时长，没有缩放，没有玻璃点亮 | 包的注释写按下色是对照 iOS 17 模拟器目测的。WWDC 219 的 flex / lensing **不仿，待核验** |
| 减少动态效果 | `LiquidGlassMotion.reduceMotionOf` 为真时（`MediaQuery.disableAnimations` 或 `LingyunAdaptivity.reduceMotion`）**不 push** 那条带弹簧的路由。改走时长为 `durationOf` → `Duration.zero`、曲线为 `curveOf` → `Curves.linear` 的底部平移。按压仍是那一下换色 | WWDC 219：Reduce Motion 降低部分效果强度并关掉弹性。Adopting Liquid Glass：标准组件应自动适配；这条 Flutter 路由不读该开关。中间强度没有官方数值，本库不另做一条更软的弹簧，直接关掉弹性。与本库其它组件的「时长归零」一致。实机是减弱还是归零，**待核验** |

包内私有读数（只说明宿主里有什么，**不要写进 token**）：

| 项 | `cupertino_ui` 1.1.4 源码 | 状态 |
| --- | --- | --- |
| 弹簧 | `CupertinoModalPopupRoute.createSimulation`。注释：质量 1，刚度 522.35，阻尼 45.7099552（临界阻尼），约 0.404 s 收到 0.999，速度容差 0.03 | 私有。本库不复制。**待核验** vs iOS 27.1 |
| 声明时长 | `transitionDuration` 335 ms。仿真驱动时控制器忽略这段时长 | 不是本库时长 |
| 按下底色 | 上组按下 `0xCAE0E0E0` / 深 `0xC1515151`；取消按下 `0xFFECECEC` / 深 `0xFF494949` | 包注释写 iOS 17 目测。**待核验** vs iOS 27.1 |
| 模糊 | `CupertinoPopupSurface.defaultBlurSigma`（1.1.4 为 30） | 包的常量，不是 Liquid Glass σ。**待核验** |

自测（`flutter test test/lingyun_action_sheet_test.dart`，桌面测试字体，不是真机）：

- 弹出：第一帧更低，80 ms 后上移，停稳后仍高于中途位置。
- 收起：点行之后 80 ms 位置更低，停稳后路由消失，返回调用方下标。
- 按压：按下上组底色变为包内按下色，抬起恢复；取消槽用另一块按下色。
- Reduce Motion：弹出后 400 ms 位置不变；按下仍换色；点行后一帧收起。`MediaQuery.disableAnimations` 同样一帧到位。

## API

```dart
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

final index = await showLingyunActionSheet(
  context,
  title: '删除照片',
  message: '此操作无法撤销。',
  actions: const [
    LingyunActionSheetAction.destructive(label: '删除'),
    LingyunActionSheetAction.cancel(label: '取消'),
  ],
);
```

| 符号 | 作用 |
| --- | --- |
| `showLingyunActionSheet` | 有动效时 push `CupertinoModalPopupRoute`（`showCupertinoModalPopup` 内部就是这条路由；那个函数没有 `barrierLabel`，所以这里直接 push，才能带上遮罩的无障碍文案）。返回调用方列表里的下标；点遮罩关掉时为 `null`（默认可以点遮罩关闭）。`null` **不会**去调取消行的 `onPressed`，也不是取消行的下标 |
| `LingyunActionSheet` | `CupertinoActionSheet`。图库把四种状态铺在同一页 |
| `LingyunActionSheetAction.regular` | 普通操作。常规字重，标签色，留在上组。对应 `UIAlertAction.Style.default`，不是加粗 |
| `.confirm` | 首选。加粗（`isDefaultAction`），仍是标签色，不是蓝色填充 |
| `.destructive` | 系统红，不加粗 |
| `.cancel` | 从主列表抽出，放进底部独立槽 |
| `LingyunActionSheet.arrange` | 第一个取消进独立槽；其余行（含第二个取消）按调用顺序留在上组 |

遮罩用 `kCupertinoModalBarrierColor`。`showCupertinoModalPopup` 会按当前亮度解析：浅色 `0x33000000`，深色 `0x7A000000`。不另传颜色。

宿主若已是 `cupertino_ui` 的 `CupertinoApp`，沿用那棵树上的本地化。图库外壳仍是 Material 壳时，路由里补 `DefaultCupertinoLocalizations`，不是兼容桥。

## 图库与截图

示例页 **操作表**（`?page=actions`，也认 `action-sheets`；`&theme=dark` 看深色）。页内标题、按钮、说明都是简体中文。

四块静态：标题和信息、破坏性、多项（取消写在调用列表最前，仍出现在最下）、仅操作。

- `docs/screenshots/action_sheets_light.png`
- `docs/screenshots/action_sheets_dark.png`

截图是 Flutter stable 桌面字体下的静态板，不是真机 SF Pro，也不是弹簧的中间帧。验收看行序、取消是否分开、破坏性红色、遮罩浓淡。动效看上面的测试，不看这两张静帧。

Windows / macOS / Linux 重新出图（在 `example` 目录，三条命令相同）：

```bash
flutter test tool/capture_action_sheet_screenshots.dart
```

```powershell
flutter test tool/capture_action_sheet_screenshots.dart
```

```bat
flutter test tool/capture_action_sheet_screenshots.dart
```

## 待核验

| 项 | 状态 |
| --- | --- |
| 从触发控件 morph / 透镜化入场（WWDC 219、284，Adopting Liquid Glass） | **待核验**。`cupertino_ui` 1.1.4 没有 source anchor。本库不自绘。现在仍从底部滑入 |
| 锚定后省略取消、点外面执行取消动作（WWDC 284） | **待核验**。现在仍画独立取消槽。点遮罩只返回 `null` |
| 操作表出现后仍能点后面的界面（Adopting Liquid Glass） | **待核验**。系统路由带模态遮罩，后面点不到 |
| 弹簧质量 / 刚度 / 阻尼、335 ms 声明时长 | **待核验** vs iOS 27.1。不是 token |
| 按下 flex、点亮、缩放 | **待核验**。现在是包内立即换色（注释来自 iOS 17） |
| Reduce Motion 是减弱还是时长归零 | **待核验**。本库归零，不另做半弹簧 |
| 普通行字色用标签色而不是系统蓝 | **待核验** vs Sketch。Figma 本轮未复读。不用玻璃标签 `#1A1A1A` |
| 取消是否应加粗 | **待核验**。包不加粗，本库不改 |
| 圆角、模糊 σ 30、按下色 | **待核验**。全是包内数值，不是本库 token |
| 语义标签 | 包内写的是 `Alert`。**待核验** |
