# Screenshots

Gallery captures (committed as PNGs in this folder):

- `materials_light.png` — Materials Ultrathin / Thin / Regular / Thick, light, design canvas `#D1D1D6`, 1280×1200. Gray bands behind each plate are the specimen field (Figma Materials page), not a token.
- `materials_dark.png` — same page, dark, design canvas `#000000`, 1280×1200
- `materials.png` — alias of the light materials capture
- `glass_button_light.png` — GlassButton gallery (sizes Small / Medium / Large, states, Clear, Destructive, Glass Prominent, Symbol) on design canvas `#D1D1D6`
- `glass_button_dark.png` — same button gallery, dark, design canvas `#000000`
- `tab_bar_light.png` — Tab Bars: standard, floating pill (3, 4, and 5), tinted, light, design canvas `#D1D1D6`
- `tab_bar_dark.png` — same page, dark, design canvas `#000000`

The color around **Clear** on `glass_button_light.png` / `glass_button_dark.png` is the gallery rich-media plate behind `LiquidGlassStyle.clear`. It is not a selection or focus ring, and it is not the button rim. Sketch Clear keeps the shared ~0.5px hairline; the plate is only there so the translucent style stays visible. It is a muted wash, not a saturated rainbow stroke. The page behind that plate is the design canvas.

Regenerate the GlassButton captures from the example gallery (1280×800, Glass page, chrome hidden, light then dark):

```bash
cd example
flutter run -d chrome
```

Open `http://localhost:<port>/?page=glass&chrome=0` and `?page=glass&theme=dark&chrome=0`, then save the viewport. The Pressed chips are pinned with `forcePressed`. Prominent Disabled is the accent fill at about 50% opacity. Blur strength in the capture is an implementation approximation, not a kit token. Control heights 28 / 34 / 50 are the Figma Text export; they are not blur sigmas.

- `page_compact_light.png` / `page_compact_dark.png` — `LingyunPage` compact bucket, bottom Dock tab, design canvas
- `page_regular_light.png` / `page_regular_dark.png` — regular bucket, glass sidebar rail + split
- `page_wide_light.png` / `page_wide_dark.png` — wide bucket (draft ≥ 1200), same rail

These are skeleton captures, not pixel sign-off against Duo / Pad / PC frames.

Regenerate from `example/` (bash, PowerShell, or cmd):

```bash
PAGE_CAPTURE=1 flutter test test/page_capture_test.dart
```

```powershell
$env:PAGE_CAPTURE='1'; flutter test test/page_capture_test.dart
```

```bat
set PAGE_CAPTURE=1&& flutter test test/page_capture_test.dart
```

Older hinge-helper captures (`layout_phone.png`, `layout_duo_cover.png`, `layout_duo_inner.png`, `layout_ipad.png`, `layout_desktop.png`) predate `LingyunPage`.
