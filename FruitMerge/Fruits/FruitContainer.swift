import SpriteKit

class FruitContainer: SKShapeNode {

    var containerSize: CGSize!
    var droppingFruit: DroppingFruit!
    var droppingFruitAimingLine: DroppingFruitAimingLine!

    var fruitPool: [FruitType] = [
        .blueBerry, .strawBerry, .lemon, .mango
    ]

    func randomFruitType() -> FruitType {
        return self.fruitPool.randomElement()!
    }

    init(in scene: SKScene) {
        super.init()
        self.isUserInteractionEnabled = true

        let cornerRadius: CGFloat = 10.0
        containerSize = CGSize(
            width: scene.frame.width * 0.9, height: scene.frame.height * 0.6)

        // Create a path for the rounded rectangle
        let rect = CGRect(origin: .zero, size: containerSize)
        let path = CGPath(
            roundedRect: rect, cornerWidth: cornerRadius,
            cornerHeight: cornerRadius, transform: nil)

        self.path = path

        // Set the fill and stroke properties
        self.fillColor = SKColor(
            red: 247 / 255.0, green: 240 / 255.0, blue: 188 / 255.0, alpha: 1.0)
        self.strokeColor = .white
        self.lineWidth = 8.0

        self.position = CGPoint(
            x: 0.05 * scene.size.width, y: 0.2 * scene.size.height)

        print("Container Position: \(self.position)")

        // Setup Physics
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.2
        physicsBody?.friction = 0.9
        physicsBody?.categoryBitMask = PhysicsCategory.container
        physicsBody?.collisionBitMask = PhysicsCategory.fruit
        physicsBody?.contactTestBitMask = PhysicsCategory.fruit

        self.createDroppingFruit()

        self.droppingFruitAimingLine = DroppingFruitAimingLine(
            length: self.containerSize.height / 2)
        self.droppingFruitAimingLine.position = self.droppingFruit.position
        self.droppingFruit.attachAimingLine(
            aimingLine: self.droppingFruitAimingLine)

        self.addChild(droppingFruitAimingLine)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDropped), name: .dropped,
            object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func handleDropped(_ notifiation: Notification) {

        print("dropped handled in FruitContainer")
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let droppingFruit = self.droppingFruit,
            let texture = droppingFruit.texture
        else { return }

        let touchLocation = touch.location(in: self)

        // Animate scaling up to texture size and then back to the original size (1.0)
        let scaleUp = SKAction.scale(to: GlobalTextureStore.scaledRetio[droppingFruit.fruitType]!, duration: 0.05)

        droppingFruit.run(
            SKAction.sequence([scaleUp]), withKey: "scaleUpAction")
        droppingFruit.move(to: touchLocation.x)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        // Calculate clamped position
        let fruitSize = self.droppingFruit.size
        let minX = fruitSize.width / 2
        let maxX = self.containerSize.width - fruitSize.width / 2

        // Clamp coordinates to container bounds
        let clampedX = max(minX, min(touchLocation.x, maxX))

        self.droppingFruit.move(to: clampedX)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.droppingFruit.drop()
    }

    func createDroppingFruit(_ fruitType: FruitType? = nil) {
        self.droppingFruit = DroppingFruit(fruitType ?? self.randomFruitType())
        let x = containerSize.width / 2
        let y = containerSize.height - 30
        droppingFruit.position = CGPoint(x: x, y: y)
        droppingFruit.attachAimingLine(aimingLine: self.droppingFruitAimingLine)
        self.addChild(self.droppingFruit)
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self, name: .dropped, object: nil)
    }
}

extension SKScene {
    func setupFruitContainer() -> FruitContainer {
        let fruitContainer = FruitContainer(in: self)
        self.addChild(fruitContainer)
        return fruitContainer
    }
}
