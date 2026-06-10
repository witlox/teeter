import SpriteKit

enum Effects {
    static func spark(at p: CGPoint, in node: SKNode) {
        let s = SKSpriteNode(imageNamed: Art.spark)
        s.position = p
        s.setScale(0.4)
        s.zPosition = 50
        node.addChild(s)
        s.run(.sequence([
            .group([.scale(to: 1.2, duration: 0.25), .fadeOut(withDuration: 0.25)]),
            .removeFromParent()
        ]))
    }

    static func steam(at p: CGPoint, in node: SKNode) {
        let s = SKSpriteNode(imageNamed: Art.steam)
        s.position = p
        s.alpha = 0.9
        s.zPosition = 40
        node.addChild(s)
        s.run(.sequence([
            .group([.moveBy(x: 0, y: 60, duration: 0.8),
                    .scale(to: 1.4, duration: 0.8),
                    .fadeOut(withDuration: 0.8)]),
            .removeFromParent()
        ]))
    }

    static func dust(at p: CGPoint, in node: SKNode) {
        let d = SKSpriteNode(imageNamed: Art.dust)
        d.position = p
        d.zPosition = 45
        node.addChild(d)
        d.run(.sequence([
            .group([.scale(to: 1.6, duration: 0.6), .fadeOut(withDuration: 0.6)]),
            .removeFromParent()
        ]))
    }
}
