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
a shareable artifact. Goal set with eyes open: **fun side project, beer money is a bonus.**

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

## Monetization (IAP-only, no ads)
The model is deliberately ad-free, and the reasoning is specific to this game's situation:
- **iOS audience.** iOS users decline tracking en masse (ATT), which both signals
  ad-aversion and suppresses iOS ad eCPM, while iOS users pay far more readily per head.
  On iOS specifically, an ad-free IAP model roughly matches or beats an ad model on revenue
  once you account for retention — and wins decisively on simplicity and principle.
- **No third-party SDK.** No AdMob, no mediation, no ATT prompt, no data-sharing, nothing to
  maintain or get rejected in review. The game stays premium-feeling, which helps the one
  growth lever a zero-UA game has (word-of-mouth + the share card).
- **The product:** one non-consumable, **"Unlock 3 Revives" ($2.99), Family Sharing on.**
  Every run gives **1 free save**; the unlock raises the per-run cap to **3**, forever.
  It's a strict upgrade, never a penalty. Family Sharing is a free toggle (covers up to 6
  household members from one purchase) — there is deliberately no higher-priced "family" SKU,
  because Apple Family Sharing is not a tier you can sell.
- **Placement over nagging.** The offer surfaces at the highest-intent moment — toppling
  with no free save left ("I was that close"), where buying both unlocks and saves the
  current run. Soft repeats sit on the game-over and menu screens. If it ever reads as a
  nag, frequency-gate it; the per-run cap already self-limits how often it can appear.

A note on scale: at realistic zero-UA volume (hundreds to low-thousands of players) the
absolute revenue from any model is tiny, so this choice is made for fit, simplicity, and
sovereignty rather than for a revenue multiple. The real lever is distribution, not the
monetization model.

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
