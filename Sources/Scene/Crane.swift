import SpriteKit

/// The crane sweeps a held block side-to-side. Amplitude and speed grow with the
/// tower height — the player can SEE and ANTICIPATE the swing, so rising difficulty
/// stays skill-legible (the "weird gravity" instinct, made fair).
///
/// Local coordinates: the crane node is positioned by the scene at the current drop
/// height; the held block lives at local (swingX, 0); the arm sits above it.
final class Crane: SKNode {
    private let arm = SKSpriteNode(imageNamed: Art.craneArm)
    private(set) var held: Block?

    private var amplitude: CGFloat = Tuning.craneBaseSwing
    private var period: Double = Tuning.craneBasePeriod
    private var phase: Double = 0
    private let armOffsetY: CGFloat = 76

    init(width: CGFloat) {
        super.init()
        arm.size = CGSize(width: width * 0.92, height: 34)
        arm.position = CGPoint(x: 0, y: armOffsetY)
        arm.zPosition = 20
        addChild(arm)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(forFloor f: Int) {
        amplitude = min(Tuning.craneMaxSwing,
                        Tuning.craneBaseSwing + CGFloat(f) * Tuning.craneSwingPerFloor)
        period = max(Tuning.craneMinPeriod,
                     Tuning.craneBasePeriod - Double(f) * Tuning.cranePeriodDecayPerFloor)
    }

    func attach(_ block: Block, screenHalfWidth: CGFloat) {
        held = block
        block.physicsBody = nil
        block.position = .zero
        block.zPosition = 15
        amplitude = min(amplitude, screenHalfWidth - block.size.width * 0.5 - 12)
        phase = 0
        addChild(block)
    }

    /// Hand the held block to the scene, preserving its world transform. The scene
    /// re-parents and gives it a physics body. Clears `held`.
    func takeHeld(into scene: SKScene) -> (block: Block, position: CGPoint, zRotation: CGFloat)? {
        guard let b = held else { return nil }
        let p = scene.convert(b.position, from: self)
        let r = b.zRotation
        b.removeFromParent()
        held = nil
        return (b, p, r)
    }

    func step(dt: Double) {
        guard let b = held else { return }
        phase += dt / period * 2 * Double.pi
        b.position.x = CGFloat(sin(phase)) * amplitude
        b.zRotation = CGFloat(cos(phase)) * 0.06   // momentum tilt = telegraph
    }
}
