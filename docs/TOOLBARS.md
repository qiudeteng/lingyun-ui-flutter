# Toolbars（Flutter）

不是 `ios/` 的竖向系统 Toolbar，不改 `ios/`。Sketch / Figma 只核对静态。动效对照：

1. WWDC25 **Meet Liquid Glass** — 玻璃分组小而完整，一块一个环境，不在同一块上切浅深。大面积玻璃不拿这条冒充。
2. **Adopting Liquid Glass** — 工具栏是悬浮玻璃分组，不是贴边的一整块材质，也不是 Tab Bar Dock。
3. HIG Toolbars — leading、标题、trailing。
4. Sketch / Figma 不提供弹簧数值。

## 材质

每组一块 `GlassSurface(style: LiquidGlassStyle.regularMedium)`。不传 `material`，不传 `tokens`。

- 不是 Materials Thick（那是工作表和正式侧栏）。
- 不是 `LiquidGlassStyle.dock`（那是 `GlassTabBar`）。传入 Dock 会在调试断言里失败。
- 标题在两组之间，不包进玻璃，所以不是通栏条。
- 外形是胶囊（`BorderRadius.circular(1000)`，与 `GlassButton` 相同），不是新圆角 token。工具栏圆角 **待核验**。
- `blurSigma` / 饱和度仍是目录里的近似，**待核验**。本组件不改配方。

## 动效

不新造弹簧 token。iOS 27.1 工具栏弹簧未公布，**对照官方观感 / 待核验**。

| 手势 | 用什么 |
| --- | --- |
| 按压 | 缩放到 0.97，加上 `GlassButton` 已有的 press veil。时长 `LiquidGlassMotion.quick`。不是再嵌一个玻璃按钮 |
| 显隐 | `visible`。`LiquidGlassMotion.standard`，滑动幅度 0.35（短，不是飞入） |
| 减少动态效果 | `LingyunAdaptivity.reduceMotion` 或 `MediaQuery.disableAnimations` → `Duration.zero`。按下的缩放仍然生效 |

## 和分栏、Duo 的关系

`placement` 只选顶边或底边的安全区，条始终是横的。

`avoidHinge: true` 时加上已有的 `LingyunLayout.chromeInsetsFor`。这是窗口中缝留白，不是竖向系统条，也没有 Duo 姿态枚举。regular / wide 分栏里，把条放在详情列，让它不要横跨正式侧栏。

画廊「侧栏」页的详情列里有一条，用来看两边共存。

## API

```dart
LingyunToolbar(
  placement: LingyunToolbarPlacement.top,
  visible: visible,
  title: const Text('浏览'),
  leading: LingyunToolbarActionButton(
    action: LingyunToolbarAction(
      icon: Icons.arrow_back_ios_new,
      label: '返回',
      onPressed: () {},
    ),
  ),
  actions: [
    LingyunToolbarAction(
      icon: Icons.share_outlined,
      label: '分享',
      onPressed: () {},
    ),
  ],
)
```

| 符号 | 作用 |
| --- | --- |
| `LingyunToolbar` | 横条。leading 一组，actions 一组 |
| `LingyunToolbarAction` | 图标、标签、按下 |
| `LingyunToolbarActionButton` | 按压反馈。leading 里请用它，不要再套一层玻璃 |
| `LingyunToolbarPlacement` | `top` / `bottom` |
| `LingyunToolbarMetrics` | 工作尺寸。不是 token 表 |

## 图库

`flutter run`（在 `example/`）后打开 `?page=toolbars`（`toolbar` 同样）。深色加 `&theme=dark`。导航名是「工具栏」。文案是简体中文。

- 浅色 / 深色各一块，玻璃盖在条纹上
- 点分享：次数加一。按住能看到缩小
- 「隐藏」把条收起
- 「改到底边」换安全区
- 「宽而扁」演示中缝留白

Windows / macOS / Linux（在仓库根或 `example`，命令相同）：

```bash
flutter test test/lingyun_toolbar_test.dart
```

```powershell
flutter test test/lingyun_toolbar_test.dart
```

```bat
flutter test test/lingyun_toolbar_test.dart
```
