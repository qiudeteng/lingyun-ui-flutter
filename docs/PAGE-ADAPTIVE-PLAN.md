# Page 自适应布局框架规划（Phone / iPhone Duo 六形态 / Pad / PC）

**角色**：IOS27风格设计大师（群总指挥 · 设计验收）  
**目标**：封装统一 `Page`（或平台等价物），按可用空间自动适应，**最终效果与设计稿像素级一致**。  
**基准**：Sketch SoT + Figma Apple iOS/iPadOS 27（`X2nwP1156zkZAscUSZGv9S`）+ Apple iOS 27.1 Duo HIG / Prepare。  
**日期**：2026-10-24（Asia/Shanghai）

---

## 0. 总原则

1. **按 Size Class / 可用 bounds 适配，不按设备型号硬编码**（禁止 `UIScreen.main`、固定分辨率、`userInterfaceIdiom`、orientation 驱动布局）。
2. **不要为 Duo 六形态各写一套 UI**；外屏走 Compact 宽，内屏走 Regular 宽；铰链/摄像头用 `ReservedRegion` + 位移（displacement），半开与全开的 Size Class 相同。
3. **iOS 27.1 SDK**：全屏铺满；Toolbar / Tab Bar **可变为竖向**（状态栏下方）；出货前必须验「条变竖」后内容不被挡。
4. **iOS 段优先系统原生容器**（SwiftUI / UIKit）；Flutter 难以 100% 对齐 Liquid Glass / 竖向 chrome / Arrangement 时，iOS 走原生壳。其他平台（Android / 桌面）用 Flutter `LingyunPage`；API 层尽量统一。
5. **验收门禁**：任何 Page 相关 PR → 设计验收（对稿截图）→ 用户终验；未过设计验收不得合 main。

---

## 1. 目标形态矩阵

| 场景 | 代表姿态 | H Size | V Size | 参考窗口（pt，Duo sim） | 布局骨架 |
|------|----------|--------|--------|-------------------------|----------|
| Phone 竖 | 常规 iPhone | Compact | Regular | ~390×844 等 | 单栏 + 底 Tab（Dock LG）+ 顶 Nav |
| Phone 横 | 常规横屏 | Compact | Compact | — | 单栏；chrome 可侧置（跟系统） |
| **Duo ①** 合上竖 | Folded Portrait | Compact | Regular | 466×678 | 同 Phone；外屏；**竖向**系统条在侧 |
| **Duo ②** 合上横 | Folded Landscape | Compact | Compact | 678×466 | 外屏横；竖向 chrome |
| **Duo ③** 半开竖 | Half-open Portrait | Regular | Regular | 669×951 | 内屏；可 Split / Sidebar；注意折叠区 |
| **Duo ④** 半开横 | Half-open Landscape | Regular | Regular | 951×669 | 内屏横；条保持侧置连续体验 |
| **Duo ⑤** 全开竖 | Open Portrait | Regular | Regular | 669×951 | 同③ Size Class；折叠区 inactive |
| **Duo ⑥** 全开横 | Open Landscape | Regular | Regular | 951×669 | 同④ |
| iPad | 竖/横 / Split View | Regular（可 Compact 分屏） | Regular/Compact | 稿面 Sidebars / Windows | 双栏/三栏 + Sidebar + Popover |
| PC / macOS 窗口 | 可任意缩放 | 连续宽度断点 | — | 设计稿大屏帧 | 多栏 + 可调侧栏；窗口铬跟平台 |

> Duo 六形态 = 上表 ①–⑥。半开≈全开的 Size Class；**铰链角度不能靠 Size Class 感知**，要用 `reservedRegions(kind: .division)`。

---

## 2. 设计稿对照（待 Figma 额度恢复后补 node）

| 平台骨架 | 设计稿线索（已知） | 验收时截图要点 |
|----------|-------------------|----------------|
| iPhone Page | Figma Tab Bars `507:24689` · iPhone 帧 | 底 Dock LG、安全区、内容边距 |
| iPhone Duo Page | 同页 **iPhone Duo** 帧（此前标待核验 → **本轮升为必须**） | 外屏竖向 Tab/Toolbar；内屏侧栏/分栏；铰链空隙 |
| iPad Page | Sidebars / Windows / Popovers；Tab iPad 零件 | Sidebar 宽、主从列、Popover 锚点 |
| PC | Sketch/Figma 大屏或 Windows 相关帧（若无则标「桌面扩展，非 iOS Kit 强制」） | 最小/理想/最大宽下的栏数与边距 |

**动作**：Figma MCP 额度恢复后，由设计侧补各形态 Page 画板 nodeId + 导出参考图到 `figma-screenshots/page-layouts/`。

---

## 3. iOS 27.1 Duo 硬性要求（摘自 Apple）

| 要求 | 做法 |
|------|------|
| 用 **iOS 27.1+ SDK** 构建 | 全屏；条可竖排 |
| 禁 `UIScreen.main` | `view.bounds` / `GeometryReader` / `onGeometryChange`；尺寸变化要重算 |
| 禁 orientation 决定布局 | 比较宽高 + Size Class |
| 禁 idiom / 固定机型尺寸 | Size Class + 可用空间 |
| 安全区不对称 | 独立处理 leading/trailing；控件在 safe area；全出血媒体可延展 |
| Reserved regions | 外摄常在；内摄激活时 occlusion；半开 hinge = division |
| 系统容器优先 | `NavigationSplitView` / `UISplitViewController`、`TabView` / `UITabBarController`、`ArrangementView` / `UIArrangementViewController` |
| Arrangement | Split（主从）或 Overlay（前景/背景）；勿把 Nav 塞进 Arrangement；勿把 Arrangement 塞进可滚动容器 |
| 位移原则 | 少动、保关系；连续滚动内容不位移；书本姿态偏 trailing；帐篷姿态上远看/下操作 |

官方入口：

- https://developer.apple.com/iphone-duo/prepare/
- https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo
- Tech Talks 111461 / 111463

---

## 4. `Page` 组件架构（推荐）

### 4.1 统一契约（跨平台 API 语义）

```
LingyunPage / LYPage
├── chrome: tab | sidebar | none
├── navigation: stack | split | arrangement(split|overlay)
├── body: primary (+ optional secondary)
├── adaptiveSlots: leading / trailing / top / bottom（跟系统安全区）
└── breakpoints: 由 Size Class + 宽度桶驱动，不暴露「Duo 姿态枚举」给业务
```

业务只声明 **内容角色**（list / detail / player / upNext），框架映射到骨架。

### 4.2 宽度桶（实现用，对业务透明）

| 桶 | 条件（示意） | 骨架 |
|----|--------------|------|
| `compact` | H=Compact | 单栏 + Tab（底或侧，跟系统） |
| `regular` | H=Regular 且非桌面超宽 | Split 或 Sidebar + 主栏 |
| `wide` | 桌面 / 大窗（如宽 ≥ 某稿面断点，**数值以设计稿为准**） | 可选第三栏 / 固定边距上限 |

折叠：在 `regular` 内监听 division region → 列宽 50/50、网格偶数列、控件避开中缝。

### 4.3 平台实现策略

| 平台 | 方案 | 负责人建议 |
|------|------|------------|
| **iOS / iPadOS / Duo** | **原生优先**：SwiftUI `LYPage` 包一层系统 `TabView` + `NavigationSplitView` + 必要时 `ArrangementView`；Liquid Glass chrome 跟系统 | 可新增 iOS 原生轨，或现有工程师用 Platform Channel / add-to-app；**不以 Flutter 强行复刻竖向系统条** |
| **Android / 其他** | Flutter `LingyunPage`：`LayoutBuilder` + 自定义断点 + 已有 `GlassTabBar` / 未来 Sidebar | FlutterUI |
| **PC（Windows/mac 桌面壳）** | Flutter 同一套 + 桌面窗口约束；mac 若要原生感可二期 | FlutterUI |
| **理想统一** | 业务 Dart API 一套；iOS 底层可 `PlatformView`/原生宿主实现同一契约 | 总指挥定接口，双端对齐 |

**结论（本规划拍板）**：

- **短期**：Flutter 库继续交付跨端 `LingyunPage`（Phone / Pad / 桌面 + Duo 的 Size Class 模拟）；**iOS 真机 Duo 竖向 chrome / Arrangement / ReservedRegion 走原生适配层**，设计验收以系统行为 + 稿面为准。  
- **中期**：评估 Flutter 是否能吃到足够的 27.1 API；不能则保持「Dart API + iOS native impl」。

---

## 5. 分工与节奏

| 阶段 | 谁 | 交付 |
|------|----|------|
| A. 设计出图 | 设计大师 | 补 Duo/Pad/PC Page 框架对照表 + 参考截图；更新本文件 nodeId |
| B. Flutter 骨架 | FlutterUI | `LingyunPage`：compact/regular/wide；接现有 Tab Bars；Pad sidebar stub 升级；桌面宽断点 |
| C. iOS 原生适配 | Flutter 开发工程师（或指定原生） | 27.1 SDK；禁 UIScreen；Tab/Toolbar 竖向；ReservedRegion；Arrangement 示例页 |
| D. Glass 控件 | 既定分工不变 | Button → 开发工程师；Tokens/Materials/Tab → FlutterUI；**须先过设计验收** |
| E. 验收 | 设计大师 → 用户 | 每形态浅/深色截图 vs 稿；像素级 |

**并行规则**：GlassButton / Tokens 改库继续；Page 骨架可并行，但 **不得用 Materials Thick 冒充 LG**；Duo/Page 合入前必须设计验收。

---

## 6. 验收清单（Page）

- [ ] Phone 竖/横：安全区、Dock LG、内容边距 = 稿  
- [ ] Duo ①–②：外屏竖向条、内容不进摄像头/条区  
- [ ] Duo ③–⑥：内屏 Regular 布局；半开时中缝无关键控件/文字压折；系统 Alert/Sheet 位移可接受  
- [ ] iPad：Sidebar / Split / Popover 对稿  
- [ ] PC：宽窗多栏、窄窗降级单栏，无横向溢出  
- [ ] 无 UIScreen/固定机型/orientation 分支（iOS 代码扫描）  
- [ ] 浅色 + 深色各一套截图  

---

## 7. 参考链接

- Prepare Duo: https://developer.apple.com/iphone-duo/prepare/  
- HIG Designing for iPhone Duo: https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo  
- Tech Talk 自适应姿态: https://developer.apple.com/videos/play/tech-talks/111463/  
- Tech Talk App 准备: https://developer.apple.com/videos/play/tech-talks/111461/  
- Size Class 六形态速查: https://sarunw.com/posts/size-classes-on-iphone-duo/  
- 既有简报: `FIGMA-IOS27-ACCEPTANCE.md` · PR #9  
