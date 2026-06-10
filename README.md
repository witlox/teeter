# Teeter

A steampunk press-your-luck block-stacker for iOS. A crane swings a block, you tap to drop
it, physics does the rest. Stack high, **bank** before it topples — or risk one more floor.

![sprites](Art/svg/) <!-- sprite sources live in Art/svg -->

## Quick start
```bash
brew install xcodegen     # one time
./scripts/bootstrap.sh    # generates Teeter.xcodeproj and opens it
```
Pick an iPhone simulator and Run. It plays end-to-end out of the box — no ads, no
third-party SDKs, no account setup. The single IAP uses StoreKit 2.

> Built as a one-shot scaffold without a Swift compiler in the loop. Treat the first
> `Run` as a compile-fix pass — see `CLAUDE.md` for the likely fix-up spots. Then iterate
> on feel.

## Layout
```
Sources/App        app entry, view model, root view
Sources/Scene      gameplay: GameScene, Crane, Block, StabilityMonitor, Tuning
Sources/Systems    StoreKit (Unlock 3 Revives), scores, haptics
Sources/UI         SwiftUI shell, HUD, overlays, share card, theme
Sources/Resources  Assets.xcassets (generated)
Art                procedural art generator + SVG sources
Configuration      Info.plist, StoreKit config
```

## Tuning
All balance numbers live in `Sources/Scene/Tuning.swift`. Start there.

## Monetization
IAP-only, no ads. One non-consumable **"Unlock 3 Revives" ($2.99)** raises the per-run save
cap from 1 to 3, with **Family Sharing** enabled (one purchase covers up to 6 family
members). Product id `io.witlox.teeter.unlock3` (`Sources/Systems/StoreManager.swift`).

## In-app purchase testing
Edit Scheme → Run → Options → StoreKit Configuration → `Configuration/Teeter.storekit`.

## Design
See `DESIGN.md` for why the mechanics are what they are, and `CLAUDE.md` for the invariants
not to break.

## License
MIT — see `LICENSE`.
