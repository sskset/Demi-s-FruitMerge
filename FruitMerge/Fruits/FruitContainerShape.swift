import SpriteKit

class FruitContainerShape: SKShapeNode {

    var containerPhysicsBodyShpe: FruitContainerPhysicsBodyShape!
    
    var containerSize: CGSize!
    var droppingFruit: DroppingFruit!
    var droppingFruitAimingLine: DroppingFruitAimingLine!

    var fruitPool: [FruitType] = [
        .blueBerry, .strawBerry, .lemon, .mango,
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

        // Set the fill and stroke properties
        self.fillColor = SKColor(
            red: 247 / 255.0, green: 240 / 255.0, blue: 188 / 255.0, alpha: 1.0)
        self.strokeColor = .white
        self.lineWidth = 8.0
        
        self.path = path

        self.position = CGPoint(x: 0.05 * scene.size.width, y: 0.2 * scene.size.height)

        self.createDroppingFruit()

        self.droppingFruitAimingLine = DroppingFruitAimingLine(
            length: self.containerSize.height / 2)
        self.droppingFruitAimingLine.position = self.droppingFruit.position
        self.droppingFruit.attachAimingLine(
            aimingLine: self.droppingFruitAimingLine)

        self.addChild(droppingFruitAimingLine)
        
        self.containerPhysicsBodyShpe = FruitContainerPhysicsBodyShape(in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private var isProcessingTouch = false {
        didSet {
            print("isProcessingTouch: \(isProcessingTouch)")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isProcessingTouch,
            let touch = touches.first,
            let droppingFruit = self.droppingFruit
        else { return }

        droppingFruit.restoreToOriginalTexture()

        let touchLocation = touch.location(in: self)
        droppingFruit.move(to: touchLocation.x)
        isProcessingTouch = true
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
        self.isProcessingTouch = false
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent?
    ) {
        self.isProcessingTouch = false
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
    func setupFruitContainer() -> FruitContainerShape {
        let fruitContainer = FruitContainerShape(in: self)
        self.addChild(fruitContainer)
        return fruitContainer
    }
}
