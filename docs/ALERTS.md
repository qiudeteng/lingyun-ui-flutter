# Alerts（正式件）

iOS **包系统**，对照 Sketch **Alerts**，**非自绘 Liquid Glass**。探路是已合入的 [#16](https://github.com/qiudeteng/lingyun-ui-flutter/pull/16)。正式件沿用同一条 `cupertino_ui` 路径，补动作蓝、桌面字体和减少动态效果。

已迁独立包 **`cupertino_ui`**，未用 `flutter/cupertino` 或 `flutter/material` 内置设计库。未使用 `CupertinoUiCompatibilityBridge`。

## 对照

| 来源 | 说明 |
| --- | --- |
| Sketch SoT | [Apple iOS 27 UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02) · 页 **Alerts** |
| 验收基线 | `ACCEPTANCE-BASELINE` §3.3：单按钮 / 双按钮 / 破坏性确认 / 标题+消息 / 仅消息。常见偏差是按钮顺序反了，或遮罩过透、过实 |
| Wave 2 | 本组件走系统材质 / 稿面，**包系统**。不做 Sheets、Action Sheets、Sidebars、Toolbars、Menus、Popovers |

`cupertino_ui` 1.x 的对话框 API 与 1.0 相同：`CupertinoDialogRoute`（`showCupertinoDialog` 用的同一条路由）、`CupertinoAlertDialog`、`CupertinoDialogAction`。本库调用的就是这组 API（依赖 `cupertino_ui: ^1.1.4`）。

## 不是什么

- 不是 Liquid Glass，不套 GlassButton、Dock、Materials Thick。
- 不自绘圆角、模糊、按钮配方去模仿稿面上的胶囊按钮。稿面用来对 **状态**（几个按钮、谁在左、破坏性是不是红色、有没有标题），视觉交给系统对话框。
- 新文件 `lib/src/widgets/lingyun_alert.dart` 与 `example/lib/pages/alerts_page.dart` 只 import `package:cupertino_ui/cupertino_ui.dart`（示例页另外 import 本库）。图库外壳沿用 `package:material_ui/material_ui.dart`。不使用兼容桥。

## API

```dart
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

final index = await showLingyunAlert(
  context,
  title: '删除照片',
  message: '此操作无法撤销。',
  actions: const [
    LingyunAlertAction.destructive(label: '删除'),
    LingyunAlertAction.cancel(label: '取消'),
  ],
);
```

| 符号 | 作用 |
| --- | --- |
| `showLingyunAlert` | `CupertinoDialogRoute`。返回调用方列表里的下标；点遮罩关掉时为 `null`（默认不可点遮罩关闭） |
| `LingyunAlertDialog` | `CupertinoAlertDialog`。图库把五种状态铺在同一页 |
| `LingyunAlertAction.cancel` / `.confirm` / `.destructive` | 取消（常规字重）、确认（加粗）、破坏性（系统红、不加粗） |
| `LingyunAlert.actionBlue` | 非破坏性按钮的稿面系统蓝。浅色 `#0088FF`，深色 `#0091FF`。经 `CupertinoThemeData.primaryColor` 交给 `CupertinoDialogAction` 绘制。不是 Cupertino `systemBlue`（`#007AFF` / `#0A84FF`） |
| `LingyunAlert.arrangedIndices` | 两个按钮时取消在前（leading，LTR 为左）；三个及以上时取消在最后 |
| `LingyunAlert.desktopTypeStyle` | 非 Apple，且周围已经有真实字族时，标题、信息和按钮改用该字族，并在后面加上常见中文界面黑体。Apple 返回 null，仍是 `CupertinoSystemText` |
| `LingyunAlert.reduceMotionOf` | `MediaQuery.disableAnimations` 或 `LingyunAdaptivity.reduceMotion` 时，同一条路由时长为 0，过渡改为直接显示。按压换色仍在 |
| `LingyunAlert.springMass` / `springStiffness` / `springDamping` | 对话框弹簧。质量 1，刚度 522.35，阻尼 45.7099552（`2 * sqrt(刚度)`，临界阻尼）。速度容差 0.03。约 404ms 位置到 0.999 |
| `LingyunAlert.cupertinoTransitionDuration` | 名义时长 250ms。弹簧模拟忽略这段时长，不按 250ms 缓动 |
| `LingyunAlert.enterScaleBegin` / `enterScaleEnd` | 进场缩放 1.3 → 1.0，跟弹簧位置走。出场不缩放 |
| `LingyunAlert.actionPressedFill` / `actionIdleFill` | 按钮底板。按下当帧换成浅色 `0xFFE1E1E1` / 深色 `0xFF404040`。静止是 `0xCCF2F2F2` / `0xCC2D2D2D` |

破坏性红色仍是 Cupertino `systemRed`（浅色 `#FF3B30`，深色 `#FF453A`），不是稿面系统红 `#FF383C` / `#FF4245`。`CupertinoDialogAction` 在 `isDestructiveAction` 时写死 `systemRed`，不读 `primaryColor`。不离开系统按钮去改这颗红。

遮罩颜色不传入。路由使用 `kCupertinoModalBarrierColor`：浅色 `0x33000000`，深色 `0x7A000000`。

宿主若已是 `cupertino_ui` 的 `CupertinoApp`，对话框沿用那棵树上的本地化。图库外壳仍是既有 Material 壳时，路由里补的是 `DefaultCupertinoLocalizations`，不是兼容桥。

## 桌面字体

系统对话框把标题、信息和按钮的 `fontFamily` 写成 `CupertinoSystemText`。在 Apple 上这是 SF Pro Text 的代理。本库**不捆绑 SF Pro**。

非 Apple 上这个名字不存在，引擎会落到平台回退字体，探路截图就是这样。正式件在**周围 `DefaultTextStyle` 已经写了真实字族**时（图库的 Material 主题在 Linux 上是 Roboto），让标题、信息和按钮改用该字族，保留系统对话框的字号、字重和字距。字族后面再挂 `LingyunAlert.desktopCjkFallback`（苹方、冬青黑、微软雅黑、思源 / Noto、文泉驿微米黑、Droid Sans Fallback），缺字时先找这些界面黑体。已经在环境字体回退列表里的名字不重复加。

纯 `CupertinoApp`、环境字族仍是 `CupertinoSystemText` 时不改写。没有可采纳的真实字族，就不编造 SF Pro。iOS / macOS 始终不改写。

画廊页标题和说明用 `LingyunTextStyles`（Title 1 强调、Footnote），`fontFamily` 留空，跟别的正式页一样走环境字体。不再用手写的 28 / w800。

## 动效

进出场和按压都是 `CupertinoDialogRoute` / `CupertinoAlertDialog` 自己的，不是第二套曲线，也不是 Liquid Glass 的运动。动效开启时 `transitionBuilder` 保持 null，路由才会跑这条弹簧；传入自定义 builder 会把弹簧跳过。

弹簧（`cupertino_ui` 对照 iOS `CASpringAnimation` 测得，临界阻尼）：

| 项 | 值 |
| --- | --- |
| 质量 | 1 |
| 刚度 | 522.35 |
| 阻尼 | 45.7099552（`2 * sqrt(522.35)`） |
| 速度容差 | 0.03。`snapToEnd` |
| 名义时长 | 250ms（`transitionDuration`）。模拟忽略它 |
| 静止 | 约 404ms，位置约 0.999。此时速度仍约 0.02，不等速度归零 |

进场：透明度 = 弹簧位置。缩放 = 弹簧从 1.3 映到 1.0。出场：同一条弹簧只驱动透明度，从进场停住的位置（约 0.997）回到 0，初速为 0；`AnimationStatus.reverse` 时去掉缩放。头 50ms 会走到大约 0.68，不是停在 1 附近。

按压：指针按下的下一帧，按钮底板从静止色换成按下色，不靠点击超时。浅色静止 `0xCCF2F2F2`、按下 `0xFFE1E1E1`；深色静止 `0xCC2D2D2D`、按下 `0xFF404040`。`cupertino_ui` 对按下色的注释是 iOS 13 模拟器目测。公开包里没有另一组 iOS 27.1 按压色，本库不另造。这不是稿面系统蓝。iOS / Android 上滑入按钮会有 `selectionClick`；指针刚按下、以及桌面平台，没有这下触觉。

减少动态效果时不另写动画。`LingyunAlert.reduceMotionOf` 为真（`MediaQuery.disableAnimations`，或图库里的 `LingyunAdaptivity.reduceMotion`）时，同一条 `CupertinoDialogRoute` 的时长改为 `Duration.zero`，`transitionBuilder` 直接返回子节点。按压换色仍在。

## 动效自测

自测在 `test/lingyun_alert_test.dart`，Flutter stable 3.47.8，Linux。采样和 `cupertino_ui` 的对话框测试同一组时间点（误差 0.001），并和上面的 `SpringSimulation` 对上。

进场，点开后先一帧，再每 50ms。缩放锁到 300ms，透明度再多一帧到 350ms（和 `cupertino_ui` 的两组测试对齐）：

| 时刻 | 缩放 | 透明度 |
| --- | --- | --- |
| 0ms | 1.3 | 弹簧起点 |
| 50ms | 1.205 | 0.316 |
| 100ms | 1.100 | 0.665 |
| 150ms | 1.043 | 0.856 |
| 200ms | 1.017 | 0.942 |
| 250ms | 1.006 | 0.977 |
| 300ms | 1.002 | 0.991 |
| 350ms | 缩放采样停在上一行 | 0.997 |

出场从这一帧点「删除」开始。下一帧时钟不前进：缩放已去掉，透明度仍是约 0.997。再每 50ms（弹簧从约 0.997 回到 0，初速 0）：0.681、0.333、0.143、0.057、0.022。全程没有 `ScaleTransition`。

按压：`pumpAndSettle` 后底板是静止色。`startGesture` 再 `pump` 一帧（不是 `pumpAndSettle`）变成按下色，再过 50ms 仍是按下色。浅色和深色各测一次。`disableAnimations` 时没有缩放，按下仍换成 `0xFFE1E1E1`。

另外两条只查过渡是否关掉：

- `disableAnimations: true`：第一帧对话框已在，祖先里没有 `ScaleTransition`。
- 只开 `LingyunAdaptivity.reduceMotion`（不改 `MediaQuery`）：同样没有缩放过渡。

遮罩仍是系统 `kCupertinoModalBarrierColor`。减少动态效果不改遮罩颜色。截图是静止画面，不代替上面的采样。

## 图库与截图

示例页 **提示**（`?page=alerts`，页上 **浅色 / 深色**，或 `&theme=dark`）。页内标题、按钮、说明和占位都是简体中文，例如「短标题最好」「信息应简短完整。」「取消」「确认」「删除」。

- `docs/screenshots/alerts_light.png`
- `docs/screenshots/alerts_dark.png`

截图宿主是 Material 主题（跟工作表出图一样），好让桌面字族走上面的环境字体，而不是缺失的 `CupertinoSystemText`。画面仍不是真机 SF Pro。验收看按钮顺序、确认/取消的稿面系统蓝、破坏性红色、遮罩浓淡和五种状态是否都在。

Windows / macOS / Linux 重新出图（在 `example` 目录，三条命令相同）：

```bash
flutter test tool/capture_alert_screenshots.dart
```

```powershell
flutter test tool/capture_alert_screenshots.dart
```

```bat
flutter test tool/capture_alert_screenshots.dart
```
