import SpriteKit
import UIKit

final class GameScene: SKScene {
    weak var model: GameViewModel?

    private let cam = SKCameraNode()
    private var crane: Crane!
    private var base: SKSpriteNode!

    private var settled: [Block] = []     // banked tower
    private var active: Block?             // the block currently falling
    private var stillFrames = 0

    private enum Internal { case idle, swinging, falling, toppling, frozen }
    private var state: Internal = .idle

    private var lastUpdate: TimeInterval = 0
    private var snapshot: [(block: Block, pos: CGPoint, rot: CGFloat)] = []

    private var topY: CGFloat { (settled.map { $0.position.y + $0.size.height/2 }.max() ?? 0) }
    private var screenHalfWidth: CGFloat { size.width / 2 }

    // MARK: - Setup

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.906, green: 0.843, blue: 0.694, alpha: 1) // parchment
        physicsWorld.gravity = CGVector(dx: 0, dy: Tuning.gravity)
        physicsWorld.contactDelegate = self
        scaleMode = .resizeFill

        let bg = SKSpriteNode(imageNamed: Art.bg)
        bg.zPosition = -100
        bg.size = CGSize(width: size.width, height: size.height * 1.2)
        bg.position = CGPoint(x: 0, y: size.height * 0.2)
        addChild(bg)

        addChild(cam)
        camera = cam
        cam.position = CGPoint(x: 0, y: size.height * 0.35)

        base = SKSpriteNode(imageNamed: Art.btn)
        base.size = CGSize(width: Tuning.unit * 3.4, height: Tuning.unit * 0.7)
        base.position = CGPoint(x: 0, y: 0)
        base.zPosition = 5
        let bb = SKPhysicsBody(rectangleOf: base.size)
        bb.isDynamic = false
        bb.friction = Tuning.blockFriction
        bb.categoryBitMask = PhysicsCategory.ground
        base.physicsBody = bb
        addChild(base)

        crane = Crane(width: size.width)
        addChild(crane)
    }

    // MARK: - Run control (called from the view model)

    func startRun() {
        clearTower()
        state = .swinging
        spawnNext()
    }

    func freeze() { state = .frozen; crane.held?.removeFromParent() }

    /// Capture the current tower as an image for the share card.
    func snapshotTower() -> UIImage? {
        guard let view = self.view, let tex = view.texture(from: self) else { return nil }
        return UIImage(cgImage: tex.cgImage())
    }

    func reset() {
        clearTower()
        state = .idle
        cam.position = CGPoint(x: 0, y: size.height * 0.35)
    }

    func restoreLastStable() {
        for s in snapshot {
            s.block.physicsBody?.velocity = .zero
            s.block.physicsBody?.angularVelocity = 0
            s.block.position = s.pos
            s.block.zRotation = s.rot
        }
        physicsWorld.speed = 1
        state = .swinging
        spawnNext()
    }

    func completeTopple() {
        physicsWorld.speed = 1
        Effects.dust(at: CGPoint(x: 0, y: topY), in: self)
        // leave the wreck visible for a beat; the UI handles the game-over overlay
    }

    private func clearTower() {
        settled.forEach { $0.removeFromParent() }
        settled.removeAll()
        active?.removeFromParent(); active = nil
        crane.held?.removeFromParent()
        snapshot.removeAll()
        stillFrames = 0
        physicsWorld.speed = 1
    }

    // MARK: - Spawning & dropping

    private func spawnNext() {
        let floor = settled.count
        crane.configure(forFloor: floor)
        crane.position = CGPoint(x: 0, y: topY + Tuning.unit * 3.2)
        let kinds = Tuning.shapeMenu(forFloor: floor)
        let kind = kinds.randomElement() ?? .square
        let block = Block(kind: kind)
        crane.attach(block, screenHalfWidth: screenHalfWidth)
        state = .swinging
    }

    // MARK: - Touch = drop (the hero verb). Cash-out is a HUD button ("bank by not placing").

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .swinging { dropActiveBlock() }
    }

    private func dropActiveBlock() {
        guard state == .swinging, let drop = crane.takeHeld(into: self) else { return }
        let block = drop.block
        block.position = drop.position
        block.zRotation = drop.zRotation
        block.zPosition = 10
        addChild(block)
        block.makeBody()
        active = block
        stillFrames = 0
        state = .falling
        Effects.steam(at: CGPoint(x: drop.position.x, y: drop.position.y - block.size.height/2),
                      in: self)
    }

    // MARK: - Loop

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdate == 0 ? 1.0/60 : min(currentTime - lastUpdate, 1.0/30)
        lastUpdate = currentTime

        if state == .swinging { crane.step(dt: dt) }
        followCamera(dt: dt)

        if state == .falling, let a = active {
            if a.position.y < base.position.y - Tuning.missBelowBase {
                missActiveBlock(a)
            } else if a.isStill {
                stillFrames += 1
                if stillFrames >= Tuning.settleFrames { bankFloor(a) }
            } else {
                stillFrames = 0
            }
        }

        if state == .falling || state == .swinging { evaluateStability() }
    }

    /// Block missed the tower and fell off the world. Free respawn.
    private func missActiveBlock(_ block: Block) {
        Effects.dust(at: CGPoint(x: block.position.x, y: base.position.y), in: self)
        Haptics.light()
        block.removeFromParent()
        active = nil
        stillFrames = 0
        spawnNext()
    }

    private func bankFloor(_ block: Block) {
        settled.append(block)
        active = nil

        // perfect-placement check: how centred over the block below?
        let belowX = settled.dropLast().last?.position.x ?? 0
        let offset = abs(block.position.x - belowX)
        let perfect = offset <= Tuning.perfectTolerance
        if perfect {
            Effects.spark(at: CGPoint(x: block.position.x, y: block.position.y), in: self)
            // nudge upright slightly as the reward (sheds lean)
            block.physicsBody?.angularVelocity = 0
        }

        takeSnapshot()
        model?.sceneDidSettle(height: settled.count, perfect: perfect)
        spawnNext()
    }

    private func takeSnapshot() {
        snapshot = settled.map { ($0, $0.position, $0.zRotation) }
    }

    private func evaluateStability() {
        guard !settled.isEmpty, let bottom = settled.first else { return }
        let baseMinX = bottom.position.x - bottom.size.width/2
        let baseMaxX = bottom.position.x + bottom.size.width/2
        let (lean, fell) = StabilityMonitor.evaluate(blocks: settled,
                                                     baseMinX: baseMinX, baseMaxX: baseMaxX,
                                                     lowestY: bottom.position.y)
        var shown = lean
        if model?.lastWasPerfect == true { shown = max(0, shown - Tuning.perfectStabilityBonus) }
        model?.sceneDidUpdateLean(min(shown, 1))

        if (lean >= Tuning.toppleLean || fell), state != .toppling {
            beginToppling()
        }
    }

    private func beginToppling() {
        state = .toppling
        physicsWorld.speed = 0.25          // slow-mo: the teeter you can see and react to
        crane.held?.removeFromParent()
        model?.sceneDidBeginToppling()
    }

    private func followCamera(dt: Double) {
        let target = max(size.height * 0.35, topY + size.height * 0.18)
        cam.position.y += (target - cam.position.y) * CGFloat(min(1, dt * 4))
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) { /* hook for landing sfx/haptics */ }
}
