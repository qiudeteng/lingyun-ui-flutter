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
| `LingyunAlert.reduceMotionOf` | `MediaQuery.disableAnimations` 或 `LingyunAdaptivity.reduceMotion` 时，同一条路由时长为 0，过渡改为直接显示 |

破坏性红色仍是 Cupertino `systemRed`（浅色 `#FF3B30`，深色 `#FF453A`），不是稿面系统红 `#FF383C` / `#FF4245`。`CupertinoDialogAction` 在 `isDestructiveAction` 时写死 `systemRed`，不读 `primaryColor`。不离开系统按钮去改这颗红。

遮罩颜色不传入。路由使用 `kCupertinoModalBarrierColor`：浅色 `0x33000000`，深色 `0x7A000000`。

宿主若已是 `cupertino_ui` 的 `CupertinoApp`，对话框沿用那棵树上的本地化。图库外壳仍是既有 Material 壳时，路由里补的是 `DefaultCupertinoLocalizations`，不是兼容桥。

## 桌面字体

系统对话框把标题、信息和按钮的 `fontFamily` 写成 `CupertinoSystemText`。在 Apple 上这是 SF Pro Text 的代理。本库**不捆绑 SF Pro**。

非 Apple 上这个名字不存在，引擎会落到平台回退字体，探路截图就是这样。正式件在**周围 `DefaultTextStyle` 已经写了真实字族**时（图库的 Material 主题在 Linux 上是 Roboto），让标题、信息和按钮改用该字族，保留系统对话框的字号、字重和字距。字族后面再挂 `LingyunAlert.desktopCjkFallback`（苹方、冬青黑、微软雅黑、思源 / Noto、文泉驿微米黑、Droid Sans Fallback），缺字时先找这些界面黑体。已经在环境字体回退列表里的名字不重复加。

纯 `CupertinoApp`、环境字族仍是 `CupertinoSystemText` 时不改写。没有可采纳的真实字族，就不编造 SF Pro。iOS / macOS 始终不改写。

画廊页标题和说明用 `LingyunTextStyles`（Title 1 强调、Footnote），`fontFamily` 留空，跟别的正式页一样走环境字体。不再用手写的 28 / w800。

## 动效自测

进入动画是 `CupertinoDialogRoute` 自己的：淡入，同时从 1.3 缩到 1.0，弹簧（`cupertino_ui` 里对照 iOS 的 `CASpringAnimation`，大约 0.4 秒落到静止）。`transitionDuration` 的名义值是 250ms，弹簧不按这条直线走。退出只淡出。这些都不是 kit token。

减少动态效果时不另写动画。`LingyunAlert.reduceMotionOf` 为真（`MediaQuery.disableAnimations`，或图库里的 `LingyunAdaptivity.reduceMotion`）时，同一条 `CupertinoDialogRoute` 的时长改为 `Duration.zero`，`transitionBuilder` 直接返回子节点。

自测在 `test/lingyun_alert_test.dart`，Flutter stable 3.47.8，Linux：

- 普通路由：点开后约 16ms，缩放大于 1，淡入透明度小于 1。`pumpAndSettle` 之后缩放和透明度都到 1，按钮可点。
- `disableAnimations: true`：第一帧对话框已在，祖先里没有 `ScaleTransition`。
- 只开 `LingyunAdaptivity.reduceMotion`（不改 `MediaQuery`）：同样没有缩放过渡。

遮罩仍是系统 `kCupertinoModalBarrierColor`。减少动态效果不改遮罩颜色。

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
