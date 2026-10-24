# Alerts（Wave 2 探路）

iOS **包系统**，对照 Sketch **Alerts**，**非自绘 Liquid Glass**。

已迁独立包 **`cupertino_ui`**，未用 `flutter/cupertino` 或 `flutter/material` 内置设计库。未使用 `CupertinoUiCompatibilityBridge`。

## 对照

| 来源 | 说明 |
| --- | --- |
| Sketch SoT | [Apple iOS 27 UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02) · 页 **Alerts** |
| 验收基线 | `ACCEPTANCE-BASELINE` §3.3：单按钮 / 双按钮 / 破坏性确认 / 标题+消息 / 仅消息。常见偏差是按钮顺序反了，或遮罩过透、过实 |
| Wave 2 | 本组件走系统材质 / 稿面，**可包系统**。不做 Sheets、Action Sheets、Sidebars、Toolbars、Menus、Popovers |

`cupertino_ui` 1.x 的对话框 API 与 1.0 相同：`showCupertinoDialog`、`CupertinoAlertDialog`、`CupertinoDialogAction`。本库调用的就是这组 API（依赖 `cupertino_ui: ^1.1.4`）。

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
| `showLingyunAlert` | `showCupertinoDialog`。返回调用方列表里的下标；点遮罩关掉时为 `null`（默认不可点遮罩关闭） |
| `LingyunAlertDialog` | `CupertinoAlertDialog`。图库把五种状态铺在同一页 |
| `LingyunAlertAction.cancel` / `.confirm` / `.destructive` | 取消（常规字重）、确认（加粗）、破坏性（系统红、不加粗） |
| `LingyunAlert.arrangedIndices` | 两个按钮时取消在前（leading，LTR 为左）；三个及以上时取消在最后 |

遮罩颜色不传入。路由使用 `kCupertinoModalBarrierColor`：浅色 `0x33000000`，深色 `0x7A000000`。

宿主若已是 `cupertino_ui` 的 `CupertinoApp`，对话框沿用那棵树上的本地化。图库外壳仍是既有 Material 壳时，路由里补的是 `DefaultCupertinoLocalizations`，不是兼容桥。

## 图库与截图

示例页 **提示**（`?page=alerts`，`&theme=dark` 看深色）。页内标题、按钮、说明和占位都是简体中文，例如「短标题最好」「信息应简短完整。」「取消」「确认」「删除」。

- `docs/screenshots/alerts_light.png`
- `docs/screenshots/alerts_dark.png`

截图在 Flutter stable 的桌面字体下生成，不是真机 SF Pro。验收看按钮顺序、破坏性红色、遮罩浓淡和五种状态是否都在。

Windows / macOS / Linux 重新出图（在 `example` 目录）：

```bash
flutter test tool/capture_alert_screenshots.dart
```
