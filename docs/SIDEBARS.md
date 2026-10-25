# Sidebars（正式件）

Sketch / Figma 只核对静态。动效对照顺序：

1. WWDC25 **Meet Liquid Glass** — 大块表面整块跟随环境，不在同一块上切浅色和深色。
2. **Adopting Liquid Glass** 与 WWDC25 **Build a UIKit app** — Tab 与 Sidebar 的流体过渡在液态玻璃上。
3. HIG Sidebars。
4. [Sketch UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02) 与 [Figma Community](https://www.figma.com/design/X2nwP1156zkZAscUSZGv9S/iOS-and-iPadOS-27--Community-)（fileKey `X2nwP1156zkZAscUSZGv9S`）的侧栏零件。Materials Thick 用于侧栏这类非 Liquid Glass 控件。

## 三件不要混名

| 名字 | 是什么 | 材质 |
| --- | --- | --- |
| `LingyunSidebar` | 正式侧栏 | Materials Thick。`GlassSurface(material: MaterialTier.thick)`，不传 `style`，不传 `tokens` |
| `GlassTabBarStyle.sidebar` | `LingyunPage` 的玻璃 rail | Liquid Glass **Dock**。宽 96，**待核验** |
| 竖向系统 Toolbar / Tab | `ios/` | 本包不画。不改 `ios/` |

装配和工作表一样：同一个 `Stack` 里，条纹或内容在底，厚材质盘子直盖。中间没有不透明块。外层的裁切只用来做列宽动画，不插在条纹和盘子之间。

本轮不改 Materials 配方（`MaterialCatalog`、`blurSigma`、饱和度都不动）。

## 动效

不新造弹簧 token。iOS 27.1 的刚度、阻尼、回弹没有公开，**对照官方观感 / 待核验**。

| 手势 | 用什么 |
| --- | --- |
| 展开 / 收起 | 系统页面曲线 `Curves.fastEaseInToSlowEaseOut`（`CupertinoPageTransition` 的那条，不抄控制点）。时钟是已有的 `LiquidGlassMotion.emphasized`。整页滑入自带的边缘阴影不套到厚材质上，避免滤镜采到阴影而不是条纹 |
| 选中 | `LiquidGlassMotion.quick`，胶囊在行间移动。填充用系统 Fills Secondary，字用系统蓝。**待核验** |
| 按压 | `CupertinoListTile` 的系统按压（主色 10% 的一层，和列表同一近似） |
| 减少动态效果 | `LingyunAdaptivity.reduceMotion` 或 `MediaQuery.disableAnimations` → `Duration.zero` |

Tab ↔ 玻璃轨的示意在画廊里：底栏和前缘之间移动，`glassStyle` 始终是 Dock。那不是正式侧栏，也不会在动画途中变成 Thick。系统流体过渡在 UIKit，这里不重写。

## API

```dart
LingyunSidebarLayout(
  title: '资料库',
  expanded: expanded,
  selectedIndex: index,
  onSelected: (value) => setState(() => index = value),
  backdrop: stripes,
  sections: const [
    LingyunSidebarSection(
      header: '邮箱',
      items: [
        LingyunSidebarItem(label: '收件箱', icon: Icons.inbox_outlined),
      ],
    ),
  ],
  body: const Detail(),
)
```

`LingyunSidebar` 只画厚材质列，父级给高度。`LingyunSidebarLayout` 负责列宽和旁边的详情。

| 符号 | 作用 |
| --- | --- |
| `LingyunSidebar` | 标题、分区、选中。chrome = Thick |
| `LingyunSidebarLayout` | 条纹在下、盘子在上，列宽随展开收起 |
| `LingyunSidebarItem` / `LingyunSidebarSection` | 行和节。禁用行占着序号，不回调 |
| `LingyunSidebarMetrics` | 工作尺寸。不是 token 表 |

需要有界高度。不读设备型号，没有 Duo 姿态。

## 待核验

| 项 | 现在的工作值 |
| --- | --- |
| 列宽 | 320。不是 rail 的 96 |
| 圆角 | 贴边时只圆后缘，半径 `LiquidGlassRadii.large`（34） |
| 选中胶囊圆角 | `LiquidGlassRadii.small`（18） |
| 行高 | 44，引自 `CupertinoListTile` 最低高度 |
| 节头 / 节距 | 28 / 12 |
| 弹簧 | 不记录。用系统曲线 + 已有时长档 |

## 图库

`flutter run`（在 `example/`）后打开 `?page=sidebars`（`sidebar` 同样）。深色加 `&theme=dark`。页上有浅色 / 深色两块样张，不必先切主题。导航名是「侧栏」。

- 点行：选中胶囊移动
- 点详情列上的菜单：列收起，再点展开
- 「收到玻璃轨」：Dock 底栏移到前缘，材质仍是 Dock

Windows / macOS / Linux（在 `example` 目录，命令相同）：

```bash
flutter test
```

```powershell
flutter test
```

```bat
flutter test
```
