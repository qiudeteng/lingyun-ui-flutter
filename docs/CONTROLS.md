# Controls 旋钮与轨道

开关、滑杆、步进器以后共用的层样式。这一批只做令牌和绘制，不做完整控件。

## 对照了什么

Sketch 文档 [Apple iOS 27 UI Kit](https://www.sketch.com/s/04c24d8b-38fb-4afb-8836-36617e022f02)（share `04c24d8b-38fb-4afb-8836-36617e022f02`，已处理版本 `RkR0Zz`）。42 个层样式里，控件在 `Controls/Light` 和 `Controls/Dark`，不在 `Liquid Glass/*`，也不在 `Materials/*`。

读了两份同一版本的导出：

- DTCG 2025.10 层样式导出（颜色、描边、阴影）
- 每个控件层样式的检查器 JSON（混合模式、描边位置、高斯模糊）

Figma 文件 `X2nwP1156zkZAscUSZGv9S`（[iOS and iPadOS 27](https://www.figma.com/design/X2nwP1156zkZAscUSZGv9S/iOS-and-iPadOS-27--Community-)）本轮没有复读。`get_metadata` 因 Starter 额度失败。没有把 Figma 的 Frost / Depth / 圆角写进来。冲突规则仍是 Sketch 优先；这次没有读到可冲突的 Figma 数字。

这些样式**不是** Materials 四档，**不是** Liquid Glass Clear / Regular Small · Medium · Large / Dock / Widget Glass。没有改那两套配方，也没有把 GlassButton 或 Tab Bar 改成 Thick。

## 已写入令牌的 Sketch 值

透明度按 8-bit 收进 `Color`：0.45 → 115，0.2 → 51，0.19 → 48，0.1 → 26，0.08 → 20，0.05 → 13。这是存储，不是另一套设计值。

| Sketch 路径 | 令牌 |
| --- | --- |
| `Controls/Light/Tracks/Active, Filled, 01 - Idle` | 填充 `#0088FF`（System Colors / Light / Blue，与 `LingyunColors.light.system.blue` 相同） |
| `Controls/Light/Tracks/Active, Filled, 03 - Clicked` | 同上，再叠 `#000000` α 0.08 |
| `Controls/Light/Tracks/Active, Unfilled, 01 - Idle` | `#000000` α 0.1 |
| `Controls/Light/Tracks/Active, Unfilled, 03 - Clicked` | `#000000` α 0.19 |
| `Controls/Light/Tracks/Active, Unfilled, 04 - Disabled` | 与未着色静止相同 |
| `Controls/Dark/Tracks/Active, Filled, 01 - Idle` | `#0091FF` |
| `Controls/Dark/Tracks/Active, Filled, 03 - Clicked` | 同上，再叠 `#FFFFFF` α 0.08 |
| `Controls/Dark/Tracks/Active, Unfilled, 01 - Idle` | `#FFFFFF` α 0.1 |
| `Controls/Dark/Tracks/Active, Unfilled, 03 - Clicked` | `#FFFFFF` α 0.19 |
| `Controls/Dark/Tracks/Active, Unfilled, 04 - Disabled` | 与未着色静止相同 |
| `Controls/Light/Knobs - Toggle/01 - Idle` | 填充 `#FFFFFF`；阴影 `#000000` α 0.05，模糊 36，偏移 (0, 3)，扩展 0 |
| `Controls/Light/Knobs - Toggle/03 - Clicked - Glow` | 外侧描边 `#D9D9D9` × 1，混合 Plus Darker；外侧描边 `#FFFFFF` α 0.45 × 0.5，混合 normal |
| `Controls/Dark/Knobs - Toggle/03 - Clicked - Glow` | 外侧描边 `#000000` α 0.2 × 1，混合 Plus Darker |
| `Controls/Light/Knobs - Toggle/03 - Clicked - Shadow` | 内侧描边 `#000000` × 1；检查器高斯半径 3，饱和度字段 0 |
| `Controls/Dark/Knobs - Toggle/03 - Clicked - Shadow` | 与浅色按下阴影相同的数值，路径是深色 |

轨道样式的 `blurs` 是空的。静止旋钮也没有层模糊。没有一处给出 backdrop σ。

着色填充挂着色变量名 `System Colors/Light/8 Blue` 与 `System Colors/Dark/8 Blue`。未着色静止和禁用挂了色变量 id，检查器没有给出变量名，所以令牌只保留颜色。

## 没有写成令牌的东西

| 项 | 状态 |
| --- | --- |
| 圆角 | **未收录**。层样式没有圆角字段。`ControlLayerView.borderRadius` 由调用方传入，不传就是直角。画廊把旋钮画成直径 24 的圆（符号里旋钮的高度），叠在胶囊轨道上。开关轨道用画板 64×28，滑杆轨道条高 6。这不是新的令牌。 |
| 背景模糊 σ | **稿面没有**。不要从 Frost / Depth 反推。 |
| 高斯半径 3 的 σ | **待核验**。检查器写的是 gaussian `radius: 3`。DTCG 导出把这个效果漏掉了，数值仍来自同一层样式的检查器。绘制时用 Flutter `BoxShadow` 的半径换算（`radius * 0.57735 + 0.5`）。这不是稿里的 σ。 |
| 模糊饱和度 0 | **只存储**。不把它解释成去色。 |
| Plus Darker | **待核验**。令牌记下了混合模式。Flutter 没有这个模式。描边先按颜色用 source-over 画，避免用变暗把浅色描边吃掉。 |
| 发光描边上的渐变 | **不画**。检查器 `fillType` 是 `color`。浅色发光第一条描边的渐变停靠点是 `#EEEEEE` → `#D9D9D9`，但 DTCG 和 `fillType` 都是实色 `#D9D9D9`。 |
| 按下两层谁在上 | **待核验**。`ControlKnobStack` 先画阴影，再画发光。 |
| 深色静止旋钮 | **稿面没有** `Controls/Dark/Knobs - Toggle/01 - Idle`。`knob(idle)` 在深色返回 null。开关画板上的旋钮看起来是白的，不升成令牌。 |
| 着色轨道的禁用 | **稿面没有**。`track(filled, disabled)` 返回 null。 |
| 步进器 | **没有独立层样式**。42 个层样式里没有 Stepper。`LingyunStepper` 自己决定复用未着色轨道，不画旋钮，不新造颜色。 | |
| 符号外框 | **不是圆角，也不是旋钮的实心尺寸**。开关画板 64×28，滑杆画板 402×52，滑杆轨道符号 370×22（里面的轨道条约高 6，其余是刻度留白），滑杆旋钮符号静止 37×24，开关旋钮符号 59×37（含按下光晕，静止填充大约高 24）。步进器画板 92×32。外框不等于圆角。画廊不把 59×37 或 64×36 涂成一块。 |
| Figma Controls 层样式 | **未复读**。见上。 |

## API

- `ControlLayerCatalog.light` / `.dark` / `forBrightness`
- `track(ControlTrackFill, ControlTrackState)` → `ControlLayerStyle?`
- `knob(ControlKnobLayer)` → `ControlLayerStyle?`
- `ControlLayerView` 画一层。`ControlKnobStack` 按上面的顺序叠旋钮。
- `ControlMetrics`：画板尺寸，不是层样式。旋钮直径 24，开关轨道 64×28（内缩 2），滑杆轨道高 6，步进器 92×32。胶囊圆角由调用方传入。
- `LingyunToggle` / `LingyunSlider` / `LingyunStepper`：完整控件。色值只问 `ControlLayerCatalog`。

开关：关用未着色轨道，开用着色轨道。按下用对应的按下轨道，旋钮叠按下阴影和发光。禁用（`onChanged == null`）整条用未着色禁用，因为着色禁用是 null。旋钮仍停在数值那一侧。深色静止不画旋钮。

滑杆：着色段到旋钮中心，其余未着色。按下同理。禁用时不画着色段。轨道高 6，旋钮直径 24。

步进器：没有旋钮。板面是未着色轨道；按住的一侧换成未着色按下；整件禁用时用未着色禁用。分隔线是系统 Separators / Non-Opaque。加减号用 Labels Primary，停用的一侧用 Tertiary。

画廊：基础工作台的「材质封装」（`?page=materials-pack`）。控件层在液态玻璃和材质之前。`?page=knob`、`page=track`、`page=controls` 落到控件层锚点。浅色和深色的旋钮、轨道零件同页，不是开关或滑杆成品。页面不写模糊或饱和度数字。深色静止旋钮仍然不画。开关、滑杆、步进器仍是控件工作台里的独立页。

控件：控件工作台里的「开关」「滑杆」「步进器」。`?page=toggles`（`toggle`）、`?page=sliders`（`slider`）、`?page=steppers`（`stepper`）各自打开独立页。页上可切浅色 / 深色，也可以点按实时开关、拖动滑杆、点步进器。文案是简体中文。

截图：[`screenshots/controls_knob_track_light.png`](screenshots/controls_knob_track_light.png)、[`screenshots/controls_knob_track_dark.png`](screenshots/controls_knob_track_dark.png)。
