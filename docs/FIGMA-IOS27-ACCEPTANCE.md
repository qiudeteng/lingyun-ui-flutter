# Figma iOS / iPadOS 27 验收简报（对照 Sketch SoT）

面向 **FlutterUI** / **Flutter 开发工程师**：用 Apple Community Figma 文件核对 Liquid Glass 命名与组件映射；**不得**用 Materials Thick 冒充按钮/Tab Bar 默认材质。

| 项 | 值 |
|----|-----|
| **fileKey** | `X2nwP1156zkZAscUSZGv9S` |
| **链接** | https://www.figma.com/design/X2nwP1156zkZAscUSZGv9S/iOS-and-iPadOS-27--Community- |
| **Community 入口** | https://www.figma.com/community/file/1651309003795292092/ios-and-ipados-27 |
| **Sketch SoT（既有基线）** | https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02 |
| **Sketch 基线文档** | `ACCEPTANCE-BASELINE.md` · `tokens/`（本仓库未收录；随设计代理人存档，不在 `docs/`） |
| **本轮截图** | `figma-screenshots/`（本仓库未收录；随设计代理人存档。库内画廊截图见 [`screenshots/`](./screenshots/)） |
| **读取方式** | Figma MCP `user-Figma`（已授权）；Starter 额度在本轮末耗尽，部分 `get_variable_defs` / 二次 `get_design_context` 未复读 |

**原则（与 Sketch 基线一致，Figma 未给出反证则不得改口）**

1. **Materials ≠ Liquid Glass**（同页分区、不同符号族）。  
2. **Button 默认 = Liquid Glass Regular Small**（组件 Style=`Glass`），**不是** Materials Thick。  
3. **Tab Bar chrome = Liquid Glass Dock**（Sketch Layer Style；Figma Tab Bar Default 挂 LG 变量，非 Materials Thick）。  
4. **玻璃上标签**：Liquid Glass Primary 浅 `#1A1A1A` / 深 `#EDEDED`（Sketch Colors；Figma Glass 文案变量回落 `#1a1a1a`）。  
5. **系统 blur / 饱和度**：文件变量未给出完整 BackdropFilter 配方时，仅作**近似**，标 **待核验**，禁止编造精确 σ。

---

## 1. 工程师用页面地图（nodeId）

| 页 | nodeId | 用途 |
|----|--------|------|
| Colors | `0:1746` | 系统色 / Labels / Fills（与 Sketch Color Variables 对照） |
| Materials | `215:105157` | **Materials 厚薄档** 与 **Liquid Glass** 并排；验收「别混用」的主页 |
| Buttons | `507:24673` | Content Area + **Button - Liquid Glass - Text/Symbol** |
| Tab Bars | `507:24689` | iPhone / iPhone Duo / iPad Tab Bar 与按钮零件 |
| Text Styles and Dynamic Type | `0:2194` | SF Pro / Dynamic Type（字号以稿为准） |
| Getting Started | `223:56234` | 入门与用法说明 |

### 1.1 Materials 页结构（摘要）

- **Materials 档位板**：`Thick` / `Regular (Default)` / `Thin` / `Ultrathin` × Light / Dark（另有 IC Light/Dark、Chrome 等 Mode Options）。  
- **Liquid Glass 样条（独立）**：  
  - `Liquid Glass - Regular - Small` `5584:32505`  
  - `Liquid Glass - Regular - Medium` `5584:32503`  
  - `Liquid Glass - Regular - Large` `5584:32504`  
  - `Liquid Glass - Clear` `5914:23547`  
- Light / Dark 演示条纹底 + Regular Large 实例；另有 Scroll Edge Soft/Hard。  
- **结论**：稿面把 **Materials** 与 **Liquid Glass** 分成两套视觉系统，验收时禁止「Thick 毛玻璃 ≈ Glass Button」。

### 1.2 Buttons 页结构（摘要）

- 传统 `Button`（Borderless / Filled 等 Content Area）与 **Liquid Glass** 分区并存。  
- 主组件集：**Button - Liquid Glass - Text** `5473:21667`、**Button - Liquid Glass - Symbol** `5522:11866`。  
- 变体轴（Text）：  
  - `Size` = Small \| Medium \| Large  
  - `Style` = **Glass** \| **Glass Prominent**  
  - `Is Enabled` = True \| False  
  - `Destructive` = True \| False  
- 代表节点：Glass Small Enabled `10456:14504`；Glass Prominent Large Enabled `5473:21905`。

### 1.3 Tab Bars 页结构（摘要）

- `Tab Bar - iPhone` `3:70967`：变体 `Minimized` × `Tabs=2…5` × `Type=Default | Search Role | Prominent Tab`。  
- 默认样例：`Minimized=False, Tabs=2, Type=Default` `3:72207`。  
- 另有 iPhone Duo、iPad 顶栏/侧栏零件（`_Tab Bar Button - iPad - *`）。正式侧栏是 Materials Thick（`LingyunSidebar`，见 `docs/SIDEBARS.md`）。`GlassTabBarStyle.sidebar` 仍是液态玻璃 Dock rail，两者不混材质。Tab↔Sidebar 的系统流体过渡在 UIKit，不在 Thick 列上。

---

## 2. Figma 与 Sketch：一致 / 差异

| 主题 | Sketch SoT | Figma Community | 是否一致 |
|------|------------|-----------------|----------|
| Materials ≠ Liquid Glass | Layer Styles 分 `Materials/*` 与 `Liquid Glass/*` | Materials 页两套画板/符号 | **一致** |
| Button 默认材质 | LG Regular Small，非 Materials Thick | 组件名 **Liquid Glass**；Style=`Glass` | **一致** |
| Glass Prominent | 蓝填充 + 白字；Destructive 红填白字 | `Accents/Blue` `#0088FF`（`#08f`）+ White Backing；Destructive `Accents/Red` `#FF383C` | **一致** |
| 玻璃标签 Primary | `#1A1A1A` / `#EDEDED` | Glass 文案 `--labels---vibrant---controls/primary` 回落 `#1a1a1a`；深色以 Sketch LG Labels 为准 | **一致**（命名路径略不同） |
| Tab Bar chrome | Liquid Glass **Dock** | Default Tab Bar 挂 LG 系变量；视觉为贴底玻璃胶囊，非 Thick Material 板 | **一致**（Figma 侧「Dock」多名出现在 Sketch 令牌；组件 Type 叫 Default/Search/Prominent） |
| Clear | `Liquid Glass/Clear` | 符号 `Liquid Glass - Clear` | **一致** |
| 圆角 18/26/34（板材 Regular S/M/L） | Sketch LG 板材档 | Button 导出为 **stadium** `rounded-[1000px]`（随高度半圆） | **部分分歧 → 待核验**（见 §6） |
| blur / 饱和度精确值 | JSON 多为 fills/shadows，无完整系统 blur | 部分 LG 参数变量（见下）；BackdropFilter σ 仍缺 | **均勿写死** |

### 2.1 本轮在 Figma 节点上读到的 Liquid Glass 参数变量（会话记录）

在 Materials / Tab Bar 相关节点的 `get_variable_defs` 中出现过（MCP 额度耗尽前；**复读被限流，数值以再授权后复核为准**）：

| 变量（语义） | 读数 | 用途提示 |
|--------------|------|----------|
| Frost | 6 | 霜化强度档（非直接 px blur） |
| Depth | 30 | 厚度/景深 |
| Refraction | 70 | 折射 |
| Dispersion | 20 | 色散 |
| Splay | 20 | 铺展 |
| Opacity | 25 | 材质不透明度档 |

> **明确**：上述为设计变量档位，**不是** Flutter `ImageFilter.blur(σ)` 的现成公式。实现仍对照 Sketch `tokens/layer-styles.md` 的 fills/shadows 栈做近似，σ/saturation **待核验 / 实机**。`tokens/` 随设计代理人存档，本仓库未收录。

---

## 3. Materials vs Liquid Glass（Figma 命名）

| 族 | Figma 可见名 | 用于 |
|----|--------------|------|
| **Materials** | Thick / Regular (Default) / Thin / Ultrathin（± Chrome、IC） | Sheet、导航栏传统材质、侧栏等**非** LG 控件默认 |
| **Liquid Glass** | Regular Small / Medium / Large；Clear；演示中的 Tinted Small UI BG | **按钮默认、Dock/Tab 玻璃、控件玻璃** |

**验收红线**

- ❌ `GlassButton` / `GlassTabBar` 默认填充走 Materials Thick。  
- ✅ 默认走 Liquid Glass（Button：Regular Small / Style Glass；Tab：Dock 配方）。

截图：`figma-screenshots/materials-lg-light.png` · `materials-lg-dark.png` · `materials-thick-light.png`（随设计代理人存档，不在本仓库）。

---

## 4. GlassButton ← Figma Button - Liquid Glass

### 4.1 变体映射（建议保持单一组件）

| Figma | 建议 API（现库） | 说明 |
|-------|------------------|------|
| Style=`Glass` | `prominence: GlassButtonProminence.glass` + `style: LiquidGlassStyle.regularSmall`（默认） | **默认路径** |
| Style=`Glass Prominent` | `prominence: GlassButtonProminence.prominent` | System Blue `#0088FF`（Light）填充 + 白字；可叠 Destructive |
| Destructive=`True` + Glass | `role: GlassButtonRole.destructive` | 红字（`#FF383C`），玻璃底 |
| Destructive + Prominent | `role: destructive` + `prominence: prominent` | 红填充 + 白字 |
| Is Enabled=`False` | `onPressed: null` / enabled=false | Prominent 禁用约 50% 不透明；Glass 禁用 Tertiary 灰字 |
| Size Small/Medium/Large | 尺寸档（高度约 **28 / 34 / 50**；导出 padding Small `10×5`、Medium `12×8`、Large `20×16`） | 默认 **Small** 对齐「Regular Small」话术 |
| Symbol 变体 | icon-only 构造 | 同 Style/Destructive/Enabled |
| Clear（Materials 页符号） | `LiquidGlassStyle.clear` | 富媒体底；非 Materials |

### 4.2 视觉栈（design_context 摘要 · Text 组件）

- 外形：**胶囊形** `border-radius: 1000px`（非固定 18pt 方圆角按钮）。  
- Glass：半透明叠层 + `Glass Effect` + 侧向细 rim 阴影 + 轻 drop `0 8 15 α0.02`。  
- Prominent：White Backing + Tint（Blue/Red）+ Glass Effect；白字 SF Pro Medium。  
- 标签（Glass）：Vibrant Controls Primary ≈ `#1A1A1A`；禁用 Tertiary ≈ `#BFBFBF`。

截图：`figma-screenshots/buttons-liquid-glass-text.png` · `buttons-liquid-glass-text-variants.png` · `buttons-light-examples.png`（随设计代理人存档，不在本仓库）。

### 4.3 与 PR #7 对齐结论

现有 `GlassButton`（Regular Small 默认、Clear、Destructive、Prominent、forcePressed）**方向正确**。终验对照 Figma Text 变体矩阵 + Sketch LG Labels；圆角若代码写死 18/26/34，需标明是**板材档**还是**按钮胶囊**（见 §6）。

---

## 5. GlassTabBar ← Figma Tab Bars

| Figma | 建议 API（现库） | 说明 |
|-------|------------------|------|
| Type=`Default` | `GlassTabBarStyle.standard` 或 `floatingPill`（视觉：贴底整条 vs 悬浮胶囊） | chrome = **Liquid Glass Dock**（Sketch 令牌名）；勿 Materials Thick |
| Type=`Prominent Tab` | 选中强调 / 与「大圆钮」类变体（按稿） | 勿与 Button Prominent 混名 |
| Type=`Search Role` | 搜索角色槽（若产品需要再暴露） | 可二期 |
| Minimized | 收起高度（约 88 vs 95） | 可选 |
| Tabs=2…5 | `items.length` | floating 3 更窄、4/5 更满 — 与现实现一致即可 |
| 选中色 | System Blue（Light `#0088FF` / Dark `#0091FF`） | 对齐 Sketch System Colors |
| 未选中标签 | LG Primary 降透（`#1A1A1A` / `#EDEDED`） | 禁止用普通 Label Primary 替代玻璃标签 |
| 整条着色 | `tintedBar: true` | 蓝底 + 白图标（已有） |
| iPad / sidebar | `LingyunSidebar`（Materials Thick）与 `GlassTabBarStyle.sidebar`（Dock rail）分开 | 正式侧栏不是 Dock stub。竖向系统条仍在 `ios/` |
| iPhone Duo | 另帧 | **待核验 / 非本轮必须** |

截图：`figma-screenshots/tabbars-iphone.png`（随设计代理人存档，不在本仓库）。

---

## 6. 缺口 / 待核验

| 项 | 状态 | 说明 |
|----|------|------|
| 按钮圆角 18 / 26 / 34 | **待核验** | Sketch LG Regular S/M/L 板材常用；Figma Button 导出为 **pill 1000**。实现需二选一写清：板材用档位半径，按钮用半高胶囊。 |
| BackdropFilter blur σ / 饱和度 | **待核验** | 仅近似；变量 Frost/Opacity 等是档位不是 σ。 |
| Frost/Depth/Refraction… 复读 | **待核验** | 本轮末 MCP Starter 限流；升额度后对 `5584:32505`、`3:72207` 再跑 `get_variable_defs`。 |
| Colors 全表 vs Sketch 107 | **部分** | 关键色已对齐；完整差分未在限流前扫完。 |
| Pressed 动效曲线 | **待核验** | 稿以静态变体为主；`forcePressed` 仅演示。 |
| iPhone Duo / iPad sidebar 交互 | **待核验** | 元数据有帧；非 Button/Tab 默认验收阻断项。 |
| design_system 搜索 | 空 | Community 副本未发布为 Library；以页内符号为准。 |

---

## 7. 给工程的落地检查清单（可勾选）

- [ ] `GlassButton` 默认 = LG Regular Small / Style Glass，**零** Materials Thick。  
- [ ] Prominent / Destructive / Clear / Disabled 与 Figma 变体矩阵一致（浅/深色截图）。  
- [ ] 标签色用 **Labels - Liquid Glass**（或等价 Token），Glass 默认浅字 `#1A1A1A`、深 `#EDEDED`。  
- [ ] `GlassTabBar` chrome = Dock；standard + floatingPill；选中 System Blue；`tintedBar` 蓝底白图标。  
- [ ] 文档写明：blur/sat **近似**；圆角板材档 vs 按钮胶囊。  
- [ ] 合入前对照：`ACCEPTANCE-BASELINE.md`（设计代理人存档）+ 本简报 + `figma-screenshots/`（设计代理人存档）。

---

## 8. 截图索引

下列 `figma-screenshots/` 路径相对于设计代理人工作区，未纳入本仓库。

| 文件 | 内容 |
|------|------|
| `figma-screenshots/materials-lg-light.png` | Materials 页 LG Light |
| `figma-screenshots/materials-lg-dark.png` | Materials 页 LG Dark |
| `figma-screenshots/materials-thick-light.png` | Materials Thick（对照「非按钮默认」） |
| `figma-screenshots/buttons-liquid-glass-text.png` | Button - Liquid Glass - Text |
| `figma-screenshots/buttons-liquid-glass-text-variants.png` | 同组件变体矩阵（design_context） |
| `figma-screenshots/buttons-light-examples.png` | Buttons 页浅色示例 |
| `figma-screenshots/tabbars-iphone.png` | Tab Bar - iPhone |

---

*生成：IOS27风格设计大师代理人 · Asia/Shanghai 2026-10-24 · 依据 Figma MCP 元数据/变量/截图 + Sketch tokens；限流后未再扩读。*
