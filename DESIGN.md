# Teeter — design rationale

This records *why*, so future changes are arguments and not vandalism. The mechanics were
chosen against a blunt market reality, not vibes.

## The premise, stress-tested
"Simple + addictive + makes money" is mostly survivorship bias. The current top-grossing
mobile games are deep live-service products, not simple ones. The one genuine "simple"
breakout (Block Blast) only *looks* simple — it's tuned with thousands of A/B tests a year.
Hyper-casual economics collapsed after Apple's ATT (iOS CPI is multiples of Android), and
the genre moved to "hybrid-casual." Conclusion: with **no user-acquisition budget**, paid
installs are not the plan. So the product *is* the marketing — the design must manufacture
a shareable artifact. Goal set with eyes open: **fun side project, no revenue ambition,
shipped because it should exist.**

## Core loop: press-your-luck, not endless drift
Accumulate height, then choose when to bank. The tension is voluntary cash-out vs. one
more risky floor. This gives the loop a *decision* every few seconds, which is what makes
"one more go" work — not the stacking alone.

- **Die = 0.** Toppling banks nothing. This is the entire source of tension; softening it
  (consolation points) kills the loop.
- **Bank by not placing.** There's no hero "Bank" button. You stop by choosing to FINISH;
  the verb the player optimises is *drop well*, and stopping is the quiet alternative.

## Failure must be skill-attributed
Luck-deaths churn players. Every collapse is telegraphed by the **lean gauge**, driven by a
real centre-of-mass-vs-base calculation (`StabilityMonitor`). The needle is the signature
instrument and the fairness contract in one object: if the player loses, they watched the
needle climb into the red and chose to keep going.

## One complexity axis, one legible pressure
Difficulty rises on exactly two things the player can *see*:
1. **Shape awkwardness** — squares → rect/bar → L/T → triangle/gear (the gear rolls).
2. **Crane swing** — amplitude and speed grow with height. This is the "weird gravity"
   instinct from early brainstorming, redirected into something legible. Real gravity
   tricks were rejected because they break skill- and brag-legibility.

## Reward scales with risk, for free
Higher towers are both worth more (height) and more unstable (longer lever arm, faster
swing). The player buys risk with skill, not with money.

## The brag artifact
On cash-out we render the standing tower into a framed steampunk share card with the floor
count and a challenge line. A picture out-performs a number on social surfaces, and it's
the only "growth" lever a zero-budget game has.

## Free, no IAP, no ads, no SDKs
The game ships fully free. No in-app purchases, no ad networks, no analytics SDK, no
third-party libraries of any kind. The reasoning is concrete to this build:

- **The App Store paid pipeline isn't worth it at this scale.** Banking and tax forms,
  IAP review cycles, StoreKit testing, Family Sharing toggles, "restore purchases" edge
  cases — every one of those is real engineering and real ongoing maintenance for a
  hobby game whose realistic revenue is rounding-error tiny anyway. Cutting all of it
  means the game ships faster and never needs a re-review for monetization changes.
- **Ads are worse.** iOS users decline tracking en masse (ATT), which suppresses iOS ad
  eCPM. Ads add an SDK, a privacy nutrition label, an ATT prompt, and an ongoing
  dependency. None of that fits a premium-feeling steampunk press-your-luck game.
- **Saves stay generous.** 3 catches per run, every run, no upsell. The cap is the only
  friction; it preserves "die = 0" tension on the third save without ever needing a
  paid tier above it. Players who lose can't blame anything but themselves.
- **The share card is the entire growth lever.** A picture out-performs a number on
  social surfaces, and it's the only "growth" lever a zero-UA, zero-monetization game
  has — or needs.

## Steampunk, sketchy
A characterful skin makes the share card distinctive without extra mechanics. The art is
procedural (riveted brass/copper plates, gear blocks, a brass gauge), so the whole look is
re-tunable from one script. Boldness is spent in one place — the gauge — and everything
else stays quiet.

## Known honest gaps (for whoever builds next)
- Built without a compiler in the loop; expect small SpriteKit fix-ups.
- Background doesn't parallax with the climbing camera yet (it just sits on parchment).
- Audio is stubbed (sound toggle exists; no engine wired).
- "Perfect" placement gives a small stability bonus but no combo system yet.
- No analytics — you cannot A/B tune what you cannot measure; add an event pipe before
  taking balance seriously.
