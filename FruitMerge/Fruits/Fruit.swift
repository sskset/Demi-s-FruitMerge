//
//  Fruit.swift
//  FruitMerge
//
//  Created by Shan Ke on 15/2/2025.
//

import SpriteKit

class Fruit: SKSpriteNode {
    static let DisplaySize: CGSize = CGSize(width: 30.0, height: 30.0)

    var isInDisplayMode = false

    let fruitType: FruitType
    var isMerging = false
    static let atlas = SKTextureAtlas(named: "FruitAtlas")

    init(_ fruitType: FruitType, isInDisplayMode: Bool = false) {
        self.fruitType = fruitType
        let texture = GlobalTextureStore.scaledTextures[fruitType]!
        super.init(
            texture: texture,
            color: .clear,
            size: isInDisplayMode ? Fruit.DisplaySize : texture.size())
        self.zPosition = 10

        self.name = "fruit"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func merge(_ pairFruit: Fruit) {
        guard let container = self.parent as? FruitContainerShape else {
            return
        }
        let nextFruitType = fruitType.next
        var floatPos = self.position

        if nextFruitType != nil {

            let newFruit = Fruit(nextFruitType!, isInDisplayMode: false)
            newFruit.pickUp()
            newFruit.release()

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

    func pickUp() {
        print("pickUp")
        guard let texture = self.texture else { return }
        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.collisionBitMask = PhysicsCategory.container
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.movingFruit

        print("pickUp name: \(String(describing: self.name))")
    }

    private var lastDragPosition: CGPoint = .zero
    func drag(to x: CGFloat) {
        self.position.x = x  // Immediate movement during drag
    }

    func release() {
        print("Release initiated")
        guard let physicsBody = self.physicsBody else { return }

        // 1. Enable physics interaction
        physicsBody.isDynamic = true

        // 4. Configure physics properties
        physicsBody.categoryBitMask = PhysicsCategory.fruit
        physicsBody.collisionBitMask =
            PhysicsCategory.fruit | PhysicsCategory.container
        physicsBody.contactTestBitMask =
            PhysicsCategory.fruit | PhysicsCategory.container
        physicsBody.linearDamping = 0.2  // Reduce air resistance
        physicsBody.angularDamping = 0.5

        physicsBody.applyForce(CGVector(dx: 0, dy: -4.9))

        self.makeAsContainerFruit()
        print("Fruit thrown")
    }

    // Time when the fruit first became stable, if any.
    private var stabilityStartTime: TimeInterval?

    // Define a threshold for velocity that you consider "stable"
    private let stableThreshold: CGFloat = 1.0

    // Call this method every frame (e.g., from your scene's update)
    func isStable(currentTime: TimeInterval) -> Bool {
        guard let physics = self.physicsBody else { return true }
        let velocity = physics.velocity
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)

        // Check if the fruit's speed is below the threshold.
        if speed < stableThreshold {
            // If it just became stable, record the time.
            if stabilityStartTime == nil {
                stabilityStartTime = currentTime
            }
            // If it's been stable for at least 1 second, return true.
            if let startTime = stabilityStartTime,
                currentTime - startTime >= 1.0
            {
                return true
            }
        } else {
            // If the fruit moves, reset the stability timer.
            stabilityStartTime = nil
        }
        return false
    }

    func makeAsContainerFruit() {
        if self.name != "containerFruit" {
            self.name = "containerFruit"
        }
    }
}
