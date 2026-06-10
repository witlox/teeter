import SpriteKit

/// Turns the messy physics state into ONE legible number: leanFraction (0...1).
/// 0 = centre of mass sits over the middle of the base; 1 = it has drifted to the
/// edge of base support => topple. The HUD gauge renders this so every collapse is
/// something the player watched coming. Also catches "a block fell off".
struct StabilityMonitor {
    /// - Parameters:
    ///   - blocks: settled tower blocks
    ///   - baseMinX/baseMaxX: horizontal support span (bottom block footprint)
    ///   - lowestY: y of the ground/structure line; blocks far below have fallen
    /// - Returns: (leanFraction, hasFallenBlock)
    static func evaluate(blocks: [Block], baseMinX: CGFloat, baseMaxX: CGFloat,
                         lowestY: CGFloat) -> (lean: Double, fell: Bool) {
        guard !blocks.isEmpty, baseMaxX > baseMinX else { return (0, false) }

        var massSum: CGFloat = 0
        var weightedX: CGFloat = 0
        var fell = false
        for b in blocks {
            let area = b.size.width * b.size.height          // proxy for mass
            massSum += area
            weightedX += b.position.x * area
            if b.position.y < lowestY - Tuning.fallThreshold { fell = true }
        }
        guard massSum > 0 else { return (0, false) }
        let com = weightedX / massSum

        let baseCenter = (baseMinX + baseMaxX) / 2
        let halfSpan = (baseMaxX - baseMinX) / 2
        guard halfSpan > 0 else { return (0, fell) }

        let drift = abs(com - baseCenter) / halfSpan        // 0 at centre, 1 at edge
        return (Double(min(max(drift, 0), 1.2)), fell)
    }
}
