# Screenshots

Gallery captures (committed as PNGs in this folder):

- `materials_light.png` — Materials Ultrathin / Thin / Regular / Thick, light
- `materials_dark.png` — same page, dark
- `materials.png` — alias of the light materials capture
- `glass_button_light.png` — Liquid Glass page + GlassButton states and variants
- `glass_button_dark.png` — same page, dark
- `tab_bar_light.png` — Tab Bars: standard, floating pill (3, 4, and 5), tinted, light
- `tab_bar_dark.png` — same page, dark

The color around **Clear** on `glass_button_light.png` / `glass_button_dark.png` is the gallery rich-media plate behind `LiquidGlassStyle.clear`. It is not a selection or focus ring, and it is not the button rim. Sketch Clear keeps the shared ~0.5px hairline; the plate is only there so the translucent style stays visible. It is a muted wash, not a saturated rainbow stroke.

Regenerate the GlassButton captures from the example gallery (1280×800, Glass page, light then dark):

```bash
cd example
flutter run -d chrome
```

Open `http://localhost:<port>/?page=glass` and `?page=glass&theme=dark`, then save the viewport. The Pressed chip is pinned with `forcePressed`, so it shows without holding the pointer. Blur strength in the capture is an implementation approximation, not a kit token.
- `layout_duo_inner.png` — Duo-like regular width with hinge-safe margins
- `layout_duo_cover.png` — closed Duo wide-short, side-edge chrome
- `layout_phone.png` — compact iPhone-style column
- `layout_ipad.png` — iPad-width / expanded
- `layout_desktop.png` — macOS / large window
