# Teeter

A steampunk press-your-luck block-stacker for iPhone and iPad. A crane swings a block,
you tap to drop it, physics does the rest. Stack high, **bank** before it topples — or
risk one more floor.

![sprites](Art/svg/) <!-- sprite sources live in Art/svg -->

## Quick start
```bash
brew install xcodegen     # one time
./scripts/bootstrap.sh    # generates Teeter.xcodeproj and opens it
```
Pick an iPhone or iPad simulator and Run. **Fully free** — no ads, no in-app purchases,
no third-party SDKs, no account setup. The whole loop plays end-to-end out of the box.

> Built as a one-shot scaffold without a Swift compiler in the loop. Treat the first
> `Run` as a compile-fix pass — see `CLAUDE.md` for the likely fix-up spots. Then iterate
> on feel.

## Layout
```
Sources/App        app entry, view model, root view
Sources/Scene      gameplay: GameScene, Crane, Block, StabilityMonitor, Tuning
Sources/Systems    scores, haptics
Sources/UI         SwiftUI shell, HUD, overlays, share card, theme
Sources/Resources  Assets.xcassets (generated)
Art                procedural art generator + SVG sources
Configuration      Info.plist
```

## Tuning
All balance numbers live in `Sources/Scene/Tuning.swift`. Start there.

## Saves
Every run gives **3 saves ("catches")** for free. Spend one to snap the tower back to its
last stable state. Run out and topple — bank zero.

## Leaderboard
Game Center leaderboard (`io.witlox.teeter.tower_height`) records your best banked tower
height. Game Center is Apple's own framework — no third-party SDK is involved. If you're
not signed in or decline, the game runs unchanged.

## Design
See `DESIGN.md` for why the mechanics are what they are, and `CLAUDE.md` for the invariants
not to break.

## License
MIT — see `LICENSE`.
