import SpriteKit

class FruitContainerShape: SKShapeNode {

    var containerPhysicsBodyShpe: FruitContainerPhysicsBodyShape!

    var containerSize: CGSize!
    var droppingFruit: Fruit! {
        didSet {
            self.droppingFruitAimingLine.position = self.droppingPoint
            self.droppingFruitAimingLine.isHidden = false
        }
    }
    
    private var droppingFruitAimingLine: DroppingFruitAimingLine! {
        didSet {
            self.createDroppingFruit()
        }
    }
    
    private var droppingPoint: CGPoint!

    var fruitPool: [FruitType] = [
        .blueBerry, .strawBerry, .lemon, .mango,
    ]

    func randomFruitType() -> FruitType {
        return self.fruitPool.randomElement()!
    }

    init(in scene: SKScene) {
        super.init()
        self.isUserInteractionEnabled = true

        self.containerSize = CGSize(
            width: scene.frame.width * 0.9, height: scene.frame.height * 0.6)
        self.droppingPoint = CGPoint(x: containerSize.width / 2, y: containerSize.height - 40)

        // Create a path for the rounded rectangle
        let cornerRadius: CGFloat = 10.0
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

        self.position = CGPoint(
            x: 0.05 * scene.size.width, y: 0.2 * scene.size.height)

        self.createDroppingFruitAimingLine()
        self.containerPhysicsBodyShpe = FruitContainerPhysicsBodyShape(in: self)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleCreateDroppingFruit),
            name: .createDroppingFruit, object: nil)
    }

    @objc func handleCreateDroppingFruit(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let fruitType = userInfo["droppingFruitType"] as? FruitType
        {
            self.createDroppingFruit(fruitType)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private var isProcessingTouch = false {
        didSet {
            if !isProcessingTouch {
                self.droppingFruit.setupPhysics()
                self.droppingFruitAimingLine.isHidden = true

                NotificationCenter.default.post(
                    name: .fruitDropped, object: nil)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isProcessingTouch,
            let touch = touches.first,
            let droppingFruit = self.droppingFruit
        else { return }
        isProcessingTouch = true
        let touchLocation = touch.location(in: self)
        droppingFruit.position.x = touchLocation.x
//        self.droppingFruitAimingLine.position.x = touchLocation.x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let droppingFruit = self.droppingFruit,
            let droppingFruitAimingLine = self.droppingFruitAimingLine
        else { return }
        let touchLocation = touch.location(in: self)

        // Calculate clamped position
        let fruitSize = droppingFruit.size
        let minX = fruitSize.width / 2
        let maxX = self.containerSize.width - fruitSize.width / 2

        // Clamp coordinates to container bounds
        let clampedX = max(minX, min(touchLocation.x, maxX))

        droppingFruit.position.x = clampedX
        droppingFruitAimingLine.position.x = clampedX

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isProcessingTouch = false
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent?
    ) {
        self.isProcessingTouch = false
    }

    private func createDroppingFruit(_ fruitType: FruitType? = nil) {
        self.droppingFruit = Fruit(fruitType ?? self.randomFruitType())
        let x = containerSize.width / 2
        let y = containerSize.height - 30
        droppingFruit.position = CGPoint(x: x, y: y)
        self.addChild(self.droppingFruit)
    }

    private func createDroppingFruitAimingLine() {
        self.droppingFruitAimingLine = DroppingFruitAimingLine(
            length: self.containerSize.height / 2)
        self.droppingFruitAimingLine.position = self.droppingPoint
        self.droppingFruitAimingLine.zPosition = 5
        self.addChild(self.droppingFruitAimingLine)
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .fruitDropped,
            object: nil)

        NotificationCenter.default.removeObserver(
            self,
            name: .createDroppingFruit,
            object: nil
        )
    }
}

extension SKScene {
    func setupFruitContainer() -> FruitContainerShape {
        let fruitContainer = FruitContainerShape(in: self)
        self.addChild(fruitContainer)
        return fruitContainer
    }
}
