# iOS LYPage 宿主 / native page host

Dart 侧跨端 `LingyunPage` 由 FlutterUI 实现。本文件只描述 **iOS 原生宿主** 如何对上同一套角色，不另造 Duo 姿态枚举。

The cross-platform `LingyunPage` widget belongs to FlutterUI. This note is the iOS host that implements the same roles.

## 契约 / Contract

| Dart | Swift | 取值 |
| --- | --- | --- |
| `LingyunPageChrome` | `LYPageChrome` | `tab` / `sidebar` / `none` |
| `LingyunPageNavigation` | `LYPageNavigation` | `stack` / `split` / `arrangementSplit` / `arrangementOverlay` |
| `LingyunPageWidthBucket` | `LYPageWidthBucket` | `compact` / `regular` / `wide` |
| `LingyunPageSpec` | `LYPageSpec` | primary / secondary 标签 |
| `LingyunNativePage` | `LYPagePlatformView` | view type `lingyun_ui_flutter/ly_page` |

通道：`lingyun_ui_flutter/ly_page_<viewId>`。Dart 发送 `updateSpec`，原生回推 `metrics`。

`LingyunAdaptivity` 仍只管 Reduce Transparency / Motion / 高对比。`LingyunLayout` 仍用窗口宽度做 Flutter 桶。iOS 桶 **不** 读 `LingyunBreakpoints.regular`（600）。只有 `wide` 与 `LingyunBreakpoints.large`（1200）对齐，而且水平 Size Class 已经是 Regular（或尚未指定）。未指定时不会被当成 Compact。1200 不是 kit token。

## 容器 / Containers

`resolveLingyunPageContainer` 与 `LYPageContainer.resolve` 同一张表：

| 请求 | 系统容器 |
| --- | --- |
| `tab` + `stack` | `TabView`，每页一个 `NavigationStack` |
| `tab` + `split` | `TabView`，每页一个 `NavigationSplitView`（最多两列） |
| `sidebar`，或 `none` + `split` | `NavigationSplitView`。Compact 由系统收成一列。Wide 且 chrome 为 sidebar 时用三列 |
| `none` + `stack` | `NavigationStack` |
| `arrangementSplit` / `arrangementOverlay` | `ArrangementView` 包在 `NavigationStack` **里**。不放进 `TabView` 或 `NavigationSplitView`，chrome 请求不套进去 |

水平 Size Class 为 Compact（含 Duo 外屏）时，split 仍挂 `NavigationSplitView`，由系统折叠。不要为外屏再写一套 UI。

半开与全开都是 Regular。铰链是 `reservedRegions(kind: .division)`，摄像头是 `.occlusion`。`frame` 已含 margins。inactive division 表示全开，不因此改桶。

## Liquid Glass

系统 `TabView` / toolbar 的玻璃是系统的 Liquid Glass。这里不画 Materials Thick，也不复刻 `GlassTabBar`。Materials 与 Liquid Glass 仍然是两套名字。

## 安全区

宿主铺满可用 bounds（`edgesForExtendedLayout = .all`）。正文留在安全区内，leading / trailing 分开读。条变竖时，侧向 inset 变大；骨架不加固定底边距。验收看 pane 里的 Host safe 与 Content safe。

## 27.1 SDK 缺口

默认 **不** 引用 `ArrangementView`、`UIArrangementViewController`、`reservedRegions`。这些符号只在 `-D LY_IOS_27_1_SDK` 下编译。未设该标志时，arrangement 请求挂 `NavigationStack` 并写明未链接，不自绘铰链。

本仓库的 Linux 环境没有 iOS 27.1 SDK，不能证明这些符号能在该 SDK 上通过编译。

## 构建 / Build

Windows / Linux 可以跑 Dart 测试。iOS 构建必须在装有 Xcode 的 Mac 上。

```bash
flutter pub get
flutter analyze
flutter test
cd example && flutter test
```

Mac，iOS 27.1 SDK：

```bash
cd example
flutter pub get
cd ios
pod install
cd ..
flutter run -d ios
```

要链接 Arrangement / reserved regions（只有 27.1 SDK 能编过）：

```bash
cd example/ios
LY_IOS_27_1_SDK=1 pod install
cd ..
flutter build ios --simulator
```

不要在更老的 SDK 上打开这个标志。

验收：iPhone 模拟器看 Compact + `TabView`；iPad 或 Regular 宽度看 `NavigationSplitView`；Duo 上确认外屏仍是 Compact，半开时 division region 为 active，条竖置后正文仍在安全区内。
