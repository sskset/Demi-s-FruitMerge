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

    var warningLine: WarningLine!
    var warningLineHeight: CGFloat {
        return self.containerSize.height * 0.8
    }
    var deadLine: DeadLine!
    var deadLineHeight: CGFloat {
        return self.containerSize.height * 0.9
    }
    
    var checkTimer: Timer?
    
    func startMonitoring() {
        self.checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self]_ in
            self?.checkFruitsForGameOver()
        }
    }
    
    func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
    }
    
    func checkFruitsForGameOver() {
        let startTime = Date()
        for fruit in self.children.compactMap({ $0 as? Fruit })
            .filter({ $0.name == "containerFruit" && $0.isStable(currentTime: Date().timeIntervalSince1970) }) {
            let fruitTopY = fruit.position.y + (fruit.size.height / 2)
            
            // Get reference to the container's boundaries
            let deadLineHeight = self.deadLineHeight
            let warningHeight = self.warningLineHeight
            
            // Check against thresholds
            if fruitTopY >= deadLineHeight {
                NotificationCenter.default.post(name: .gameOver, object: nil)
            } else if fruitTopY >= deadLineHeight * 0.8 {
                self.deadLine.blink()
            } else if fruitTopY >= warningHeight * 0.8 {
                self.warningLine.blink()
            }
        }
        let endTime = Date()
        print("Node Count: \(self.children.count) Duration in seconds: \(endTime.timeIntervalSince(startTime))")
    }

    init(in scene: SKScene) {
        super.init()
        self.isUserInteractionEnabled = true

        self.containerSize = CGSize(
            width: scene.frame.width * 0.9, height: scene.frame.height * 0.6)
        self.droppingPoint = CGPoint(
            x: containerSize.width / 2, y: containerSize.height - 40)

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
        self.warningLine = WarningLine(in: self)
        self.deadLine = DeadLine(in: self)
        self.containerPhysicsBodyShpe = FruitContainerPhysicsBodyShape(in: self)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleCreateDroppingFruit),
            name: .createDroppingFruit, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFruitDropped),
            name: .fruitDropped,
            object: nil)
    }

    @objc func handleFruitDropped(_ notification: Notification) {
    }

    @objc func handleCreateDroppingFruit(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let fruitType = userInfo["droppingFruitType"] as? FruitType
        {
            if self.droppingFruit == nil {
                self.createDroppingFruit(fruitType)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getClampedX(location: CGPoint) -> CGFloat {
        // Calculate clamped position
        let fruitSize = droppingFruit.size
        let minX = fruitSize.width / 2
        let maxX = self.containerSize.width - fruitSize.width / 2
        
        // Clamp coordinates to container bounds
        return max(minX, min(location.x, maxX))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touch = touches.first
        else { return }
        let touchLocation = touch.location(in: self)
        droppingFruit.pickUp()
        
        let clampedX = self.getClampedX(location: touchLocation)
        droppingFruit.position.x = clampedX
        self.droppingFruitAimingLine.position.x = droppingFruit.position.x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let droppingFruit = self.droppingFruit,
            let droppingFruitAimingLine = self.droppingFruitAimingLine
        else { return }
        let touchLocation = touch.location(in: self)

        let clampedX = self.getClampedX(location: touchLocation)

        droppingFruit.drag(to: clampedX)
        droppingFruitAimingLine.position.x = droppingFruit.position.x

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
        else { return }
        let touchLocation = touch.location(in: self)
        let clampedX = self.getClampedX(location: touchLocation)
        self.droppingFruit.position.x = clampedX
        self.droppingFruit.release()
        self.droppingFruitAimingLine.isHidden = true
        self.droppingFruit = nil
        
        NotificationCenter.default.post(
            name: .fruitDropped, object: nil)
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent?
    ) {
    }

    private func createDroppingFruit(_ fruitType: FruitType? = nil) {
        self.droppingFruit = Fruit(fruitType ?? self.randomFruitType())
        droppingFruit.position = self.droppingPoint
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
        
        NotificationCenter.default.removeObserver(
            self,
            name: .gameOver,
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
