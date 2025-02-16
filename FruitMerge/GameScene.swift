//
//  GameScene.swift
//  FruitMerge
//
//  Created by Shan Ke on 15/2/2025.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    //    var container: FruitContainer!

    var safeArea: CGRect!
    let horizontalMargin: CGFloat = 10

    private var nextFruit: Fruit!
    private var currentFruit: Fruit!
    private var fruitPool: [FruitType: [Fruit]] = [.blueBerry: []]

    private var scoreLabel: SKLabelNode!
    private var shadowLabel: SKLabelNode!
    private var aimingLine: SKNode!

    var currentFruitLocation: CGPoint!
    var nextFruitLocation: CGPoint!

    // This is the flag to check if fruits is being merged
    // If so, we will need to wait until the merge finishs first
    var isTouchEnabled = true
    var isStable = true

    var isGameOver = false

    var score: Int = 0 {
        didSet {
            self.scoreLabel.text = "\(score)"
            self.shadowLabel.text = "\(score)"
        }
    }

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background_red")
        background.name = "background"
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        background.size = self.size

        addChild(background)

        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self

        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.5
        self.physicsBody?.restitution = 0.2

    }

    override func sceneDidLoad() {

        self.currentFruitLocation = CGPoint(x: 0, y: self.size.height / 2 - 300)
        self.nextFruitLocation = CGPoint(
            x: self.size.width / 4, y: self.frame.maxY - 150)

        currentFruit = Fruit(fruitType: FruitType.blueBerry)

        currentFruit.position = CGPoint(x: 0, y: self.size.height / 2 - 300)
        self.addChild(currentFruit)

        spawnNextFruit()

//        print(self.nextFruit.position)

        // Setup UI

        // Use a custom font (if available) for a unique look.
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white

        // Position the label at the top center with a little offset.
        scoreLabel.position = CGPoint(
            x: self.frame.midX, y: self.frame.maxY - 50)

        // Center the text both horizontally and vertically.
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center

        // Optionally, add a subtle drop shadow for better readability.
        shadowLabel = SKLabelNode(fontNamed: "Chalkduster")
        shadowLabel.text = scoreLabel.text
        shadowLabel.fontSize = scoreLabel.fontSize
        shadowLabel.fontColor = .black
        shadowLabel.position = CGPoint(
            x: scoreLabel.position.x + 2, y: scoreLabel.position.y - 2)
        shadowLabel.horizontalAlignmentMode = scoreLabel.horizontalAlignmentMode
        shadowLabel.verticalAlignmentMode = scoreLabel.verticalAlignmentMode

        // Add the shadow behind the main label.
        self.addChild(shadowLabel)
        self.addChild(scoreLabel)

        // Calculate the starting point at the bottom of the fruit.
        // Assuming the fruit's anchorPoint is in the center:
        let fruitBottomY =
            currentFruit.position.y - (currentFruit.frame.size.height / 2)
        let startPoint = CGPoint(
            x: currentFruit.position.x, y: fruitBottomY - 50)

        // Set the end point for the dashed line (e.g., 100 points downward)
        let endPoint = CGPoint(
            x: currentFruit.position.x, y: -self.size.height / 2)

        // Create a dashed line node with desired dash and gap lengths
        self.aimingLine = setupAimingLine(
            from: startPoint, to: endPoint, dashLength: 4, gapLength: 4)
        self.addChild(aimingLine)

        self.backgroundColor = .gray
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let droppingFruit = self.currentFruit else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        droppingFruit.position.x = location.x
        aimingLine.position.x = droppingFruit.position.x

        if self.aimingLine.isHidden { self.aimingLine.isHidden = false }

        //        print("Touched Location: \(location)")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let droppingFruit = self.currentFruit  else {return}
        self.run(SKAction.playSoundFileNamed("drop", waitForCompletion: false))
        droppingFruit.setupPhysics()
        self.aimingLine.isHidden = true

        // Next fruit animation
        let moveAction = SKAction.move(
            to: self.currentFruitLocation, duration: 1.2)
        let scaleAction = SKAction.scale(
            to: nextFruit.fruitType.scale, duration: 1.2)

        // Run both actions simultaneously
        let groupAction = SKAction.group([moveAction, scaleAction])

        nextFruit.run(groupAction) {
            self.currentFruit = self.nextFruit
            self.spawnNextFruit()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.isTouchEnabled else { return }
        guard let draggingFruit = self.currentFruit else { return }
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let halfWidth = draggingFruit.size.width / 2

        // Define the minimum and maximum x positions
        let leftMinX = frame.minX + halfWidth + 10
        let rightMaxX = frame.maxX - halfWidth

        // Clamp the x coordinate between leftMinX and rightMaxX
        let clampedX = min(max(location.x, leftMinX), rightMaxX)
        draggingFruit.position.x = clampedX

        // Update the aiming line position to match the fruit
        self.aimingLine.position.x = draggingFruit.position.x
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent?
    ) {
        guard let currentFruit = self.currentFruit else { return }

        // Get half the fruit's dimensions
        let halfWidth = currentFruit.size.width / 2
        let halfHeight = currentFruit.size.height / 2

        // Define the allowed boundaries (you can adjust these margins if needed)
        let minX = frame.minX + halfWidth
        let maxX = frame.maxX - halfWidth
        let minY = frame.minY + halfHeight
        let maxY = frame.maxY - halfHeight

        // Clamp the fruit's position within the screen boundaries
        var newPosition = currentFruit.position
        newPosition.x = min(max(newPosition.x, minX), maxX)
        newPosition.y = min(max(newPosition.y, minY), maxY)
        currentFruit.position = newPosition

        // Disable physics simulation so that the fruit doesn't drop automatically
        currentFruit.physicsBody?.isDynamic = false
    }

    override func update(_ currentTime: TimeInterval) {
        if !isGameOver {
            //            checkForGameOver()
        }
    }

    func setupAimingLine(
        from start: CGPoint, to end: CGPoint, dashLength: CGFloat,
        gapLength: CGFloat
    ) -> SKNode {
        let dashedLine = SKNode()

        // Calculate the total length and direction of the line
        let totalLength = hypot(end.x - start.x, end.y - start.y)
        let dashCount = Int(totalLength / (dashLength + gapLength))
        let dx = (end.x - start.x) / totalLength
        let dy = (end.y - start.y) / totalLength

        var currentPoint = start

        for _ in 0..<dashCount {
            // Determine the end point for this dash segment
            let dashEnd = CGPoint(
                x: currentPoint.x + dx * dashLength,
                y: currentPoint.y + dy * dashLength)

            // Create a path for the dash segment
            let dashPath = CGMutablePath()
            dashPath.move(to: currentPoint)
            dashPath.addLine(to: dashEnd)

            let dashNode = SKShapeNode(path: dashPath)
            dashNode.strokeColor = .white
            dashNode.lineWidth = 2

            dashedLine.addChild(dashNode)

            // Move currentPoint forward by the length of the dash and the gap
            currentPoint = CGPoint(
                x: dashEnd.x + dx * gapLength,
                y: dashEnd.y + dy * gapLength)
        }

        return dashedLine
    }

    func spawnNextFruit() {
        let nextFruitType =
            self.fruitPool.keys.randomElement() ?? FruitType.blueBerry
        let newFruit = Fruit(fruitType: nextFruitType)
        newFruit.position = self.nextFruitLocation
        newFruit.alpha = 0
        newFruit.setScale(0.1)

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        newFruit.run(fadeIn)

        self.nextFruit = newFruit
        self.addChild(nextFruit)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let collision =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        guard collision == PhysicsCategory.fruit | PhysicsCategory.fruit else {
            return
        }

        guard let fruitA = contact.bodyA.node as? Fruit,
            let fruitB = contact.bodyB.node as? Fruit,
            fruitA.fruitType == fruitB.fruitType,
            !fruitA.isMerging,
            !fruitB.isMerging
        else { return }

        // Mark fruits as being merged
        fruitA.isMerging = true
        fruitB.isMerging = true

        if fruitA.fruitType == FruitType.watermelon {
            self.score += FruitType.watermelon.rawValue * 2

            // Remove old fruits
            removeNodesWithBlinking([fruitA, fruitB]) {}
        } else {

            // Calculate merge position
            let mergePosition = CGPoint(
                x: (fruitA.position.x + fruitB.position.x) / 2,
                y: (fruitA.position.y + fruitB.position.y) / 2
            )

            // Remove old fruits
            removeNodesWithBlinking([fruitA, fruitB]) {

                if let newFruit = fruitA.merge() {
                    // Add new merged fruit
                    newFruit.position = mergePosition
                    newFruit.setupPhysics()

                    self.score += newFruit.fruitType.rawValue
                    self.scoreLabel.text = "\(self.score)"
                    self.shadowLabel.text = "\(self.score)"
                    if !self.fruitPool.keys.contains(newFruit.fruitType) {
                        self.fruitPool[newFruit.fruitType] = [newFruit]
                    } else {
                        self.fruitPool[newFruit.fruitType]?.append(newFruit)
                    }
                    self.addChild(newFruit)
                }
            }
        }

    }

    /// Checks if any fruit on the screen is stable and over the height threshold.
    func checkForGameOver() {
        // Define the threshold for "stable" (low velocity)
        let velocityThreshold: CGFloat = 5.0
        // Define the height threshold (e.g., 75% of the scene's height)
        let heightThreshold = self.size.height * 0.75

        // Iterate through all nodes; you might want to narrow this search to only fruit nodes.
        for node in self.children {
            if let fruit = node as? SKSpriteNode, fruit.name == "fruit" {
                if let physicsBody = fruit.physicsBody {
                    // Check if the fruit is stable (i.e., nearly zero velocity)
                    let dx = abs(physicsBody.velocity.dx)
                    let dy = abs(physicsBody.velocity.dy)
                    if dx < velocityThreshold && dy < velocityThreshold
                        && fruit.position.y > heightThreshold
                    {
                        endGame()
                        return
                    }
                }
            }
        }
    }

    /// Called when the game over condition is met.
    func endGame() {
        self.isGameOver = true
        //        print("Game Over!")

        // Optionally pause the scene
        self.isPaused = true

        // Or transition to a Game Over scene:
        //         let gameOverScene = GameOverScene(size: self.size)
        //         self.view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1.0))
    }

    // Remove old fruits with blinking animation, then perform merging
    func removeNodesWithBlinking(
        _ nodes: [SKSpriteNode], completion: @escaping () -> Void
    ) {
        // Define the blink action: fade out then fade in.
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.25)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let blink = SKAction.sequence([fadeOut, fadeIn])

        // Repeat the blink sequence twice (each cycle takes 0.5 sec, total 1 sec)
        let blinkForOneSecond = SKAction.repeat(blink, count: 2)

        // Action to remove the node from the scene
        let remove = SKAction.removeFromParent()

        // Sequence the blinking animation followed by removal
        let sequence = SKAction.sequence([blinkForOneSecond, remove])

        // Run the sequence on all nodes concurrently
        for node in nodes {
            node.physicsBody?.isDynamic = false
            node.run(sequence)
        }

        // Execute the completion closure after the sequence duration (1 second)
        self.run(
            SKAction.sequence([
                SKAction.wait(forDuration: 1.0), SKAction.run(completion),
            ]))
    }

}
