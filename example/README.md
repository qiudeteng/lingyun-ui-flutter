# lingyun-ui-flutter example

Gallery: **Materials** (Ultrathin / Thin / Regular / Thick), **Glass**
(Clear / Regular S·M·L / Dock / Widget Glass + GlassButton sizes
Small / Medium / Large, states Default / Pressed / Disabled, variants
Glass, Clear, Destructive, Glass Prominent, Symbol), **Tabs**
(`GlassTabBar` standard + floating pill + tinted bar), Themes,
Layout (`LingyunPage` compact / regular / wide bounds), Accessibility,
**Native** (iOS `LYPage` host: compact / regular / wide notes;
`?page=native`). The UIKit skeleton is iOS-only. See
[`docs/IOS-LYPAGE.md`](../docs/IOS-LYPAGE.md) and
[`docs/PAGE.md`](../docs/PAGE.md).
**Alerts** (`?page=alerts`): system `cupertino_ui` dialog, not Liquid Glass.
Demo titles, buttons, and messages on that page are Simplified Chinese.

Default backdrop is the design canvas (light `#D1D1D6`, dark `#000000`).
The **Canvas** chip on every page also selects muted wash, nature,
abstract color, and a busy UI pattern. Query: `?bg=canvas|wash|meadow|abstract|busy`
(with `page`, `theme`, `chrome=0`).

```bash
flutter run -d chrome
flutter run -d macos
flutter run -d ios
```

Web production build (GitHub Pages):

```bash
flutter build web --base-href /lingyun-ui-flutter/
```
