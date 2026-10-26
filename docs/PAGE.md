# LingyunPage

Flutter 骨架笔记。契约以 [IOS-LYPAGE.md](IOS-LYPAGE.md) 的 `LingyunPageSpec` 为准，规划见 [PAGE-ADAPTIVE-PLAN.md](PAGE-ADAPTIVE-PLAN.md)。不另造一套 chrome / navigation / bucket 类型，也没有 Duo 姿态枚举。

## 分工

| 层 | 谁画 | 何时 |
| --- | --- | --- |
| `LingyunPage` 骨架 | Flutter | 非 iOS。iOS 上默认不画，除非 `embedNativeHost: false`（示例画廊壳） |
| `LingyunNativePage` / `LYPage` | `ios/` | iOS，且 `embedNativeHost` 为 true（默认）。布局页和原生页走这条。同一个 `LingyunPageSpec` |
| 竖向系统 Toolbar / Tab、`ArrangementView`、真实 `reservedRegions` | 原生 | 只在 `LY_IOS_27_1_SDK=1` 时链接。未设标志时不自绘铰链 |

`LingyunPage` 在 iOS 上默认把 spec 交给 `LingyunNativePage`，Flutter 子节点只作为非 iOS 的 placeholder。示例画廊壳传 `embedNativeHost: false`，在模拟器和真机上仍画四组 Flutter Dock 和工作台；否则 `LYPageScaffold` 只认 spec 的两个标签，会盖住整个壳。布局页保持默认，继续嵌入宿主。业务不要为外屏 / 半开 / 全开各写一套 UI。

## 桶

类型是 `LingyunPageWidthBucket`：`compact` / `regular` / `wide`。

| 传入的水平 Size Class | 结果 |
| --- | --- |
| `compact` | 永远 `compact`，即使宽度超过 600 |
| `regular` 或 `unspecified` | 宽 ≥ `LingyunBreakpoints.large`（**1200**）为 `wide`，否则 `regular`。`unspecified` **不是** compact。与 `LYPageWidthBucket.resolve` 一致 |
| 省略（Flutter 没有系统 Size Class） | 宽度代理：&lt; 600 为 `compact`，≥ 1200 为 `wide`，中间是 `regular`。**iOS 不用这道 600** |

垂直 Size Class 不移动 chrome。1200 不是 kit token。

`LingyunWidthClass`（compact / regular / expanded / large）仍只负责边距。expanded（840–1199）落在 page 桶的 **regular**。

## 建议 spec

`lingyunPageSpecForBucket`：

| 桶 | chrome | navigation | Flutter 骨架 |
| --- | --- | --- | --- |
| compact | `tab` | `stack` | 单栏 + 底 `GlassTabBar`（浮动 Dock） |
| regular | `sidebar` | `split` | 玻璃 rail + primary。Compact 宽度下 rail 收起，对齐系统 `NavigationSplitView` |
| wide | `sidebar` | `split` | rail + secondary + primary（三列） |

调用方可以传任意 `LingyunPageSpec`。`LingyunPage` **不会**改写 chrome。容器表与 `resolveLingyunPageContainer` / `LYPageContainer.resolve` 相同：

- `tab` + `stack` → `TabView`，一列
- `tab` + `split` → `TabView` + 分栏，最多两列
- `sidebar`，或 `none` + `split` → `NavigationSplitView`。Wide 且 chrome 为 sidebar 时三列
- `none` + `stack` → 一列，无 tab
- `arrangementSplit` / `arrangementOverlay` → 骨架只写一句说明（`LY_IOS_27_1_SDK=1`），不画铰链，也不套 Tab / Split

底 Tab 和 rail 都是 Liquid Glass **Dock**，不是 Materials Thick。rail 内容宽 **96**（不含 leading 安全区），**待核验 vs design**。它不是 iOS 27.1 竖向系统条。正式侧栏是另一件：`LingyunSidebar`（Materials Thick，与工作表同一装配），不替换这条玻璃 rail。见 [SIDEBARS.md](SIDEBARS.md)。Flutter 横条工具栏见 [TOOLBARS.md](TOOLBARS.md)，不是竖向系统 Toolbar。

## 模拟中缝

`lingyunPageDivisionStub(size)` 生成一个 `LingyunPageRegion`（`kind: 'division'`）。只有调用方放进 `LingyunPage.regions` 且 `isActive` 时，骨架才在内容列之间留一条不可点的缝。iOS 的真实 region 走 `LingyunPageSnapshot`，不走这个 helper。inactive 表示全开，不改桶。

## English summary

`LingyunPage` consumes `LingyunPageSpec` / `LingyunPageWidthBucket` / `LingyunNativePage`. Off iOS it paints a Dock tab or a glass sidebar rail from `resolveLingyunPageContainer`. On iOS the same spec is the native host unless `embedNativeHost` is false. The example gallery shell sets that so its four Dock tabs stay Flutter on device; the layout demo leaves the default. Compact recommends tab + stack. Regular and wide recommend sidebar + split. There is no Duo pose enum. Vertical system chrome, `ArrangementView`, and real reserved regions stay in `ios/` and link only when `LY_IOS_27_1_SDK=1`. The 96px rail and the 1200pt wide cut are drafts (1200 matches `LingyunBreakpoints.large`, not a kit token).
