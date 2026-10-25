# Menus（Wave 2）

Sketch **Menus**。静止盘子是 **Liquid Glass**，不是 Materials Thick，不是玻璃按钮的 Regular Small，也不是程序坞。

已迁独立包：交互和主题走 `cupertino_ui`，解析 `Theme` / `LiquidGlassTheme` 时用 `material_ui`。没有 `flutter/cupertino.dart`、`flutter/material.dart`，也没有 `CupertinoUiCompatibilityBridge`。

## 对照（动效优先于静止稿）

| 顺序 | 来源 | 用在菜单上的行为 |
| --- | --- | --- |
| 1 | WWDC25 [Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/) | 菜单是气泡，从控件里 **pop open**。玻璃随手指 **flex** 并被点亮。进出场靠 **lensing** 显现，而不是把玻璃淡出。Reduce Motion 降低效果并关掉弹性 |
| 2 | [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass) · WWDC25 [Build a UIKit app with the new design](https://developer.apple.com/videos/play/wwdc2025/284/) | 菜单采用 Liquid Glass。玻璃按钮 **morph** 成菜单或 popover。标准控件会跟着系统的减少动态效果走 |
| 3 | HIG Menus / Pull-down buttons / Context menus | 菜单贴着触发它的控件。选中一项或点外面就关掉。破坏性是红色，放在后面。子菜单最多一层。图标只在有助于辨认时出现 |
| 4 | Sketch SoT · Figma `X2nwP1156zkZAscUSZGv9S` | **只核静止画面**。Figma MCP 本轮 Starter 额度用尽，Menus 页没有复读。风格档是假设 |

`cupertino_ui` 的 `CupertinoContextMenu` 是 iOS 16 的长按预览加不透明底（约 13pt 圆角），不是这颗液态玻璃气泡，所以 **没有包它**。`showCupertinoModalPopup` 是动作表上滑，本 PR 不做动作表，也不借用它那条临界阻尼弹簧（刚度 522.35，注释写明给对话框和动作表）。

## 材质假设

按钮仍是 Regular Small。Meet Liquid Glass 说：工具栏按钮形变成菜单时，玻璃变得更厚，阴影更深，lensing 更明显。本库里对应「更大的一块玻璃」的现成样式是 **Regular Large**。菜单写 `GlassSurface(style: LiquidGlassStyle.regularLarge)`，不传 `material`，不传 `tokens`。

这不是 Materials Thick。blur / 饱和度仍是 Regular Large 上已有的实现近似，**不新写 σ，也不当 token 展示**。圆角沿用该样式的板材半径（34，本仓库已标 **待核验**）。Sketch 若把菜单标成另一档，改这一处即可。

## 动效（没有新的弹簧 token）

| 行为 | 现在怎么做 | 对照 |
| --- | --- | --- |
| 弹出 | 气泡矩形从按钮矩形 lerp 到静止位置。玻璃不透明度保持 1，文字不透明度跟着进度走，字在透镜里显出来 | Meet Liquid Glass：bubble pops open；不要把玻璃 fade 掉。Build a UIKit app：button morphs into the overlay |
| 收起 | 同一段进度倒放，缩回按钮 | 同上，lensing 进出场 |
| 时长 / 缓动 | `LiquidGlassMotion.standard`（360ms）和 `standardCurve`（`Cubic(0.22, 1.0, 0.36, 1.0)`） | 本库已有曲线。注释写明是减速、略带弹簧感。**没有**另写 stiffness / damping / bounce |
| 按压 | 行缩放到 **0.97**，veil 用 `GlassButtonPalette.pressedVeil`。时长是 `LiquidGlassMotion.quick`（180ms）和 `quickCurve` | 与 `GlassButton` 的按下相同。对应 Meet Liquid Glass 的 flex + 点亮。0.97 不是新 token |
| 子菜单 | 同一颗气泡里内容横滑一整宽，时长 `quick` | HIG 只允许一层。滑动距离 **待核验** |
| Reduce Motion | 气泡直接到位，行不再缩放。veil 仍会立刻出现 | Meet Liquid Glass：Reduce Motion 关掉弹性。走 `LingyunAdaptivity.reduceMotion` 和 `MediaQuery.disableAnimations` |

过冲（凝胶回弹的幅度）Apple 没有公布数字。这里故意不用一条新的 `SpringDescription`，避免把未核验的刚度写成对外 token。动作表那条弹簧也不套过来。

## 不是什么

- 不是 Dock，不是 Tab Bar，不是玻璃按钮本身。
- 不重做 Alerts，不做 Action Sheets，不做 Popovers。
- 不改 `ios/` 里的竖向 Toolbar、Arrangement、ReservedRegion。
- 破坏性一行是系统红。HIG 还要求确认时再弹动作表；动作表不在这个 PR，调用方拿到选中结果后自己确认。

## API

```dart
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

final result = await showLingyunMenu(
  context,
  anchor: lingyunMenuAnchorOf(buttonContext),
  backLabel: '返回',
  barrierLabel: '关闭菜单',
  sections: [
    LingyunMenuSection(
      actions: [
        LingyunMenuAction(label: '拷贝'),
        LingyunMenuAction(
          label: '更多',
          children: [LingyunMenuAction(label: '拷贝链接')],
        ),
      ],
    ),
    LingyunMenuSection(
      actions: [
        LingyunMenuAction.destructive(label: '删除'),
      ],
    ),
  ],
);
```

| 符号 | 作用 |
| --- | --- |
| `showLingyunMenu` | 从 anchor 把气泡形变打开。点外面返回 `null`。选中叶子返回 `LingyunMenuResult` |
| `LingyunMenu` | 静止盘子。图库样张用它，可 `forcePressedIndex` 钉住按下 |
| `LingyunMenuResult.path` | 每一层的扁平下标。第一节从 0 数，然后第二节接着数。子菜单是 `[父, 子]` |
| `lingyunMenuAnchorOf` | 按钮的全局矩形 |

`LingyunMenuLayout` 里的宽度 250、锚点间隙 20、屏幕边距 20 来自 Flutter `CupertinoContextMenu` 的私有目测值（iOS 16 上下文菜单，不是 iOS 27 下拉菜单）。行高 44 是 Cupertino 最小点击尺寸。行内边距 16×10 **待核验** vs Sketch。这些都不是动效 token。

## 待核验

| 项 | 说明 |
| --- | --- |
| Regular Large 是不是菜单档 | 假设。Figma Menus 页未复读。Sketch 若标了别的 Liquid Glass 档，改 `style` |
| 圆角 34、blur σ | 沿用 Regular Large 已有近似，不是新测量 |
| 形变过冲 | 未公布。没有写成弹簧 token |
| 宽度 250、间隙 20 | iOS 16 上下文菜单的目测，不是本页量到的 |
| 子菜单横滑 | 一整宽 + `quick`。系统是否同一条，待核验 |
| 整颗气泡跟着手指凝胶变形、高光跟着指尖走 | 本轮只做了行的 0.97 和 veil。`GlassSurface` 的高光仍是静止的 |
| 破坏性确认动作表 | 不做。红色标签只表示角色 |

## 图库

`flutter run`（在 `example/`）后打开 `?page=menus`。深色加 `&theme=dark`。页上有 **浅色 / 深色**。

导航名是「菜单」。页内标题、说明、样张、按钮都是简体中文。

- 分组与破坏性、选中、禁用、按下、子菜单、锚点：静止盘子，底下是条纹，玻璃才能采到
- 「打开菜单」走真实形变。点外面收起。点「更多」进入一层子菜单，点「返回」回来

减少动态效果用画廊 Access 页的开关（`LingyunAdaptivity.reduceMotion`）。打开之后再点「打开菜单」，气泡应直接出现，按住一行不再缩小。

字用 `LingyunTextStyles`，色用 `LingyunColors`。破坏性红是系统红。

## 自测手势

组件测试 `test/lingyun_menu_test.dart`（桌面 Flutter test，不是真机）：

| 手势 | 断言 |
| --- | --- |
| 弹出 | 气泡高度随进度变大，停稳后能看见「拷贝」 |
| 按压 | 按住一行，缩放 0.97，并出现按下标记；松手取消不选中 |
| 收起 | 点左上角遮罩，高度变小，然后气泡消失，结果是 `null` |
| Reduce Motion | 第一帧就是最终大小，再等 200ms 不变；按住时缩放保持 1 |
| 子菜单 | 「更多」→「拷贝链接」→「返回」→「删除」返回 `[4]` |

画廊测试 `example/test/widget_test.dart` 再走一遍：打开「菜单」页，点「打开菜单」，点「删除」，结果文案变成「删除」。

## 截图

- `docs/screenshots/menus_light.png`
- `docs/screenshots/menus_dark.png`

静止样张。形变要在运行的画廊里看。字体是桌面回退，不是真机 SF Pro。

Windows / macOS / Linux 重新出图（在 `example` 目录，三条命令相同）：

```bash
flutter test tool/capture_menu_screenshots.dart
```

```powershell
flutter test tool/capture_menu_screenshots.dart
```

```bat
flutter test tool/capture_menu_screenshots.dart
```
