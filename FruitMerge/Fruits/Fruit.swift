//
//  Fruit.swift
//  FruitMerge
//
//  Created by Shan Ke on 15/2/2025.
//

import SpriteKit

class Fruit: SKSpriteNode {
    static let DefaultSize: CGSize = CGSize(width: 30.0, height: 30.0)

    var isOriginalTextureSize = false

    let fruitType: FruitType
    var isMerging = false
    static let atlas = SKTextureAtlas(named: "FruitAtlas")

    init(_ fruitType: FruitType, isOriginalTextureSize: Bool = false) {
        self.fruitType = fruitType
        let texture = GlobalTextureStore.scaledTextures[fruitType]!
        super.init(
            texture: texture,
            color: .clear,
            size: isOriginalTextureSize ? texture.size() : Fruit.DefaultSize)
        self.zPosition = 10

        self.name = "fruit"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func merge(_ pairFruit: Fruit) {
        guard let container = self.parent as? FruitContainerShape else { return }
        let nextFruitType = fruitType.next
        var floatPos = self.position

        if nextFruitType != nil {

            let newFruit = Fruit(nextFruitType!, isOriginalTextureSize: true)
            newFruit.setupPhysics()

            // Calculate the center between self and pairFruit
            let factor: CGFloat = 0.45
            let centerX =
                self.position.x + (pairFruit.position.x - self.position.x)
                * factor
            let centerY =
                self.position.y + (pairFruit.position.y - self.position.y)
                * factor
            var newFruitPosition = CGPoint(x: centerX, y: centerY)

            // Calculate the container's boundaries using its path's bounding box.
            if let path = container.path {
                let containerBounds = path.boundingBox

                // Get the new fruit's size and calculate half dimensions.
                let halfWidth = newFruit.frame.size.width / 2
                let halfHeight = newFruit.frame.size.height / 2

                // Clamp the x coordinate within the container's horizontal boundaries.
                newFruitPosition.x = max(
                    containerBounds.minX + halfWidth,
                    min(newFruitPosition.x, containerBounds.maxX - halfWidth))

                // Clamp the y coordinate within the container's vertical boundaries.
                newFruitPosition.y = max(
                    containerBounds.minY + halfHeight,
                    min(newFruitPosition.y, containerBounds.maxY - halfHeight))
            }

            newFruit.position = newFruitPosition
            self.parent?.addChild(newFruit)
            floatPos = CGPoint(
                x: newFruitPosition.x,
                y: newFruitPosition.y + newFruit.frame.size.height / 2)
        }

        let score = self.fruitType.rawValue * 2
        // Create a floating score label at the merge center.
        let scoreLabel = SKLabelNode(text: "+\(score)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .orange
        // Optionally, offset the score slightly upward.
        scoreLabel.position = floatPos
        scoreLabel.zPosition = 100
        self.parent?.addChild(scoreLabel)

        // Animate the score: float upward and fade out.
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        scoreLabel.run(SKAction.sequence([group, remove]))

        // Remove the merging fruits from the scene.
        self.removeFromParent()
        pairFruit.removeFromParent()

        NotificationCenter.default.post(
            name: .scored, object: nil, userInfo: ["score": score])
    }

    func setupPhysics() {
        guard let texture = self.texture else { return }

        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.categoryBitMask = PhysicsCategory.fruit
        self.physicsBody?.contactTestBitMask =
            PhysicsCategory.fruit | PhysicsCategory.container
        self.physicsBody?.collisionBitMask =
            PhysicsCategory.fruit | PhysicsCategory.container

        self.physicsBody?.friction = 0.5
        self.physicsBody?.restitution = 0.2
        self.physicsBody?.density = 0.8
        self.physicsBody?.linearDamping = 0.5
        self.physicsBody?.angularDamping = 0.9
        self.physicsBody?.allowsRotation = true

        self.physicsBody?.applyForce(CGVector(dx: 0, dy: -4.9))
    }

    var isStable: Bool {
        guard let physics = physicsBody else { return true }
        let speed = sqrt(
            pow(physics.velocity.dx, 2) + pow(physics.velocity.dy, 2))
        return speed < 50
    }
    
    func restoreToOriginalTexture() {
        guard !self.isOriginalTextureSize else {return}
        
        let width = (GlobalTextureStore.scaledSizes[self.fruitType]?.width ?? 2.0) * self.size.width;
        let height = (GlobalTextureStore.scaledSizes[self.fruitType]?.height ?? 2.0) * self.size.height;
        self.isOriginalTextureSize = true
        
        // Animate scaling up to texture size and then back to the original size (1.0)
        let scaleUp = SKAction.scale(to: CGSize(width: width, height: height), duration: 0.05)
        
        self.run(scaleUp)
    }
}

extension Notification.Name {
    static let scored = Notification.Name(".scoreď")
}
