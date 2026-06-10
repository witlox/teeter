# Art generation

All sprites are procedural. Don't hand-edit the PNGs — edit the generator and re-run:

```bash
pip install cairosvg          # one time
python3 Art/generate_art.py   # writes SVG sources + Assets.xcassets
```

Output:
- `Art/svg/*.svg` — editable vector sources
- `Sources/Resources/Assets.xcassets/*.imageset` — @1x/@2x/@3x PNGs Xcode consumes
- `AppIcon.appiconset/icon_1024.png` — app icon

## Tuning the "sketch" look
The hand-drawn wobble is geometry-based (no SVG filters, so it rasterises reliably).
Knobs in `generate_art.py`:
- `j(v, amt=1.6)` — per-vertex jitter amount. Higher = rougher/sketchier.
- `sketch_outline(..., passes=2, jitter=1.6)` — number of overlapping strokes and their
  jitter. `passes=3` reads as scratchier ink.
- Palette constants at the top (INK, BRASS, COPPER, …) mirror `Theme.swift` — change both
  together so code and art never drift.

Determinism: `random.seed(1873)` makes output stable across runs. Change the seed for a
different-but-consistent hand.
