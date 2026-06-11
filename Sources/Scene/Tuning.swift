import CoreGraphics

/// Every load-bearing number lives here. The design invariants this file encodes:
///  - failure must be skill-legible (telegraphed wobble before topple)
///  - difficulty escalates on TWO legible axes only: shape awkwardness + crane swing
///  - reward (height) and risk (instability) rise together for free
///  - game is fully free: 3 saves/run, no IAP, no ads
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
    /// Active (falling) block this far below the base = a miss. Free respawn; no save spent.
    /// A miss is a swing-read mistake, not a structural failure — penalising it would
    /// punish bad reads instead of bad placements, which isn't the press-your-luck contract.
    static let missBelowBase: CGFloat = unit * 2

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

    // Saves ("catches") — free, every run. 3 is the only number; the cap is what creates
    // press-your-luck tension on the third save without needing a paid tier above it.
    static let catchesPerRun: Int = 3

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
