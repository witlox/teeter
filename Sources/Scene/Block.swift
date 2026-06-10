import SpriteKit

enum BlockKind: CaseIterable {
    case square, rect, bar, L, T, triangle, gear

    var asset: String {
        switch self {
        case .square: return "block_square"
        case .rect: return "block_rect"
        case .bar: return "block_bar"
        case .L: return "block_L"
        case .T: return "block_T"
        case .triangle: return "block_triangle"
        case .gear: return "block_gear"
        }
    }

    /// Footprint in cells (width, height) — matches the generated texture aspect.
    var cells: CGSize {
        switch self {
        case .square: return CGSize(width: 1, height: 1)
        case .rect: return CGSize(width: 2, height: 1)
        case .bar: return CGSize(width: 3, height: 0.72)
        case .L: return CGSize(width: 2, height: 2)
        case .T: return CGSize(width: 3, height: 2)
        case .triangle: return CGSize(width: 2, height: 1.4)
        case .gear: return CGSize(width: 1.5, height: 1.5)
        }
    }
}

final class Block: SKSpriteNode {
    let kind: BlockKind

    init(kind: BlockKind) {
        self.kind = kind
        let tex = SKTexture(imageNamed: kind.asset)
        let size = CGSize(width: kind.cells.width * Tuning.unit,
                          height: kind.cells.height * Tuning.unit)
        super.init(texture: tex, color: .clear, size: size)
        name = "block"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) unused") }

    /// Build the physics body. Irregular shapes use the texture's alpha outline so the
    /// collision shape matches what the player sees (fair physics = legible skill).
    func makeBody() {
        let body: SKPhysicsBody
        switch kind {
        case .square, .rect, .bar:
            body = SKPhysicsBody(rectangleOf: size)
        case .gear:
            body = SKPhysicsBody(circleOfRadius: size.width * 0.42)
        case .L, .T, .triangle:
            if let tex = texture {
                body = SKPhysicsBody(texture: tex, size: size)
            } else {
                body = SKPhysicsBody(rectangleOf: size)
            }
        }
        body.friction = Tuning.blockFriction
        body.restitution = Tuning.blockRestitution
        body.linearDamping = Tuning.blockLinearDamping
        body.angularDamping = Tuning.blockAngularDamping
        body.allowsRotation = true
        body.categoryBitMask = PhysicsCategory.block
        body.contactTestBitMask = PhysicsCategory.block | PhysicsCategory.ground
        body.collisionBitMask = PhysicsCategory.block | PhysicsCategory.ground
        physicsBody = body
    }

    var isStill: Bool {
        guard let b = physicsBody else { return false }
        return hypot(b.velocity.dx, b.velocity.dy) < Tuning.settleLinearEps
            && abs(b.angularVelocity) < Tuning.settleAngularEps
    }
}

enum PhysicsCategory {
    static let none: UInt32   = 0
    static let block: UInt32  = 1 << 0
    static let ground: UInt32 = 1 << 1
}
