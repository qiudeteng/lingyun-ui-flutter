# Sheets（Wave 2）

Sketch **Sheets**。面板 chrome 是 **Materials Thick**，不是液态玻璃，不是玻璃按钮，不是程序坞。

已迁独立包：实现以 `cupertino_ui` 为主，解析 `Theme` 时用 `material_ui`。没有 `flutter/cupertino.dart`、`flutter/material.dart`，也没有 `CupertinoUiCompatibilityBridge`。

## 对照

| 来源 | 说明 |
| --- | --- |
| Sketch SoT | [Apple iOS 27 UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02) · 页 **Sheets** |
| 验收基线 | §3.16：detent、抓手、滚动与内容联动、圆角与抓手区、与底层内容的关系、键盘顶起 |
| 配方 | `GlassSurface(material: MaterialTier.thick)`。不传 `tokens`，不传 `style` |

本轮**没有**改 Materials / `GlassSurface` 的厚薄配方。分支基线是 `d451503`（[#20](https://github.com/qiudeteng/lingyun-ui-flutter/pull/20)，本机条纹场已过）。工作表只写 `GlassSurface(material: MaterialTier.thick)`，不传 `tokens` / `style`，不缓存色值。浅色 / 深色截图就是这版 Thick。

## 不是什么

- 不是 Dock，不是 Tab Bar，不是玻璃按钮。
- 不重做 Alerts，不做 Menus、Popovers、Toolbars、Sidebars。
- 不改 `ios/` 里的竖向 Toolbar、Arrangement、ReservedRegion。
- 不抬 `environment.sdk`。

## API

```dart
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';
import 'package:material_ui/material_ui.dart';

final result = await showLingyunSheet<String>(
  context,
  builder: (context, controller) {
    return const Text('编辑项目');
  },
);
```

宿主需要 Material `Theme`（图库的 `MaterialApp` 已经有），`GlassSurface` 才能解析 Thick。路由里会包一层 `LingyunTheme`，内容可以用 Sketch 色和字阶。

| 符号 | 作用 |
| --- | --- |
| `showLingyunSheet` | 从底部升起。返回 `Navigator.pop` 的值；点外面关掉时为 `null` |
| `LingyunSheet` | 只画厚材质盘子和抓手。父级给尺寸。图库的静态样张用它 |
| `LingyunSheetDetent.medium` / `large` | 中档 / 高档 |
| `LingyunSheetController.animateTo` | 在中档和高档之间动画 |
| `LingyunSheetMetrics` | 按 bounds、安全区、键盘和水平 Size Class 算宽高。桶是 `resolveFlutterPageBucket` |

紧凑：通栏，底边贴屏幕或键盘，只圆上面两角。常规和宽：居中浮起，宽度有上限，四角都圆。`horizontalSizeClass: 'compact'` 时，即使 bounds 很宽也保持通栏，和 Page 契约一致。不读设备型号，也没有 Duo 姿态。铰链避让不在这个组件里。

抓手可以拖。内容在工作表自己的滚动视图里：没到高档时上拖先加高；在顶部下拉会降低。松手后的惯性**不会**再交给工作表（系统会不会把剩余速度传下来，**待核验**）。

键盘：底边等于 `MediaQuery.viewInsets.bottom`。中档不会自动变成高档（**待核验**）。桌面没有软键盘时，示例的「模拟键盘」只作用在紧凑框。

## 待核验（不是 token）

都写在 `LingyunSheetLayout`：

| 项 | 现在的工作值 | 依据 |
| --- | --- | --- |
| 中档比例 | 0.5 | 系统「大约一半」。Sketch 未量 |
| 高档顶隙 | 舞台高度的 0.08，且不小于顶安全区 | `cupertino_ui` 工作表注释，iOS 18 目测 |
| 圆角 | `LiquidGlassRadii.large`（34） | 本仓库已有的待核验板材圆角 |
| 抓手 | 36×5，距顶 5 | `cupertino_ui` 注释里的 Apple Figma / iOS 18.2 |
| 常规 / 宽宽度上限 | 704 | 自定，不是 kit |
| 遮罩 | 浅色 `0x33000000`，深色 `0x59000000` | 不是 Alert 的 barrier |

背后页面的缩小转场没有做，用遮罩代替。

## 图库

`flutter run`（在 `example/`）后打开 `?page=sheets`。深色加 `&theme=dark`。页上有 **浅色 / 深色**，不必先去主题页。

导航名是「工作表」。页内标题、说明、样张、按钮都是简体中文。

- 紧凑 · 中档、紧凑 · 高档：390 宽的示意框
- 宽或常规 · 高档：跟窗口走的浮起卡片
- 紧凑框里的「在紧凑框弹出」和「模拟键盘」
- 「在当前窗口弹出」用真实窗口的分档

字用 `LingyunTextStyles`，色用 `LingyunColors`（#18）。

截图：

- `docs/screenshots/sheets_light.png`
- `docs/screenshots/sheets_dark.png`

chrome = Materials Thick（`d451503` 的配方，本文件不改）。浅色 / 深色都是这版 Thick 的交验图。

Windows / macOS / Linux 重新出图（在 `example` 目录，三条命令相同）：

```bash
flutter test tool/capture_sheet_screenshots.dart
```

```powershell
flutter test tool/capture_sheet_screenshots.dart
```

```bat
flutter test tool/capture_sheet_screenshots.dart
```
