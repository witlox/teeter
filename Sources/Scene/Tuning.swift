import CoreGraphics

/// Every load-bearing number lives here. The design invariants this file encodes:
///  - failure must be skill-legible (telegraphed wobble before topple)
///  - difficulty escalates on TWO legible axes only: shape awkwardness + crane swing
///  - reward (height) and risk (instability) rise together for free
///  - monetisation is IAP-only (no ads): 1 free save/run, unlock raises it to 3
enum Tuning {
    // World / physics
    static let unit: CGFloat = 46          // points per shape cell
    static let gravity: CGFloat = -9.0
    static let blockFriction: CGFloat = 0.92
    static let blockRestitution: CGFloat = 0.02
    static let blockLinearDamping: CGFloat = 0.6
    static let blockAngularDamping: CGFloat = 0.7

    // Settle detection
    static let settleLinearEps: CGFloat = 6.0     // pts/s below which a block is "still"
    static let settleAngularEps: CGFloat = 0.05   // rad/s
    static let settleFrames: Int = 18             // consecutive still frames to bank a floor

    // Stability / topple (the legibility system)
    /// Lean fraction = COM horizontal drift past base support, normalised 0...1.
    /// Wobble visibly grows from `warnLean`; topple fires at 1.0.
    static let warnLean: Double = 0.45
    static let toppleLean: Double = 1.0
    /// Or a block physically falling below the structure by this many points = topple.
    static let fallThreshold: CGFloat = unit * 1.4

    // Crane / swing (legible difficulty axis #2)
    static let craneBaseSwing: CGFloat = 70       // px amplitude at floor 0
    static let craneSwingPerFloor: CGFloat = 6    // +amplitude per floor...
    static let craneMaxSwing: CGFloat = 320       // ...capped
    static let craneBasePeriod: Double = 2.4      // seconds per sweep at floor 0
    static let craneMinPeriod: Double = 0.9       // fastest sweep (cap)
    static let cranePeriodDecayPerFloor: Double = 0.035

    // Perfect placement
    static let perfectTolerance: CGFloat = unit * 0.16  // centre offset that counts as "perfect"
    static let perfectStabilityBonus: Double = 0.12     // perfect drops shed this much lean

    // Saves ("catches") economy — IAP-only, no ads
    static let defaultCatchesPerRun: Int = 1      // free save every run
    static let maxCatchesPerRun: Int = 3          // cap after the one-time "Unlock 3 Revives" IAP

    // Shape introduction schedule (floor thresholds). The single complexity axis.
    static func shapeMenu(forFloor f: Int) -> [BlockKind] {
        switch f {
        case ..<10:  return [.square, .rect]
        case ..<25:  return [.square, .rect, .bar, .L]
        case ..<45:  return [.rect, .bar, .L, .T]
        default:     return [.bar, .L, .T, .triangle, .gear]   // gear rolls: hardest
        }
    }
}
