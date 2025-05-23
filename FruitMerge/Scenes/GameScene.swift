//
//  GameOverScene.swift
//  FruitMerge
//
//  Created by Shan Ke on 16/2/2025.
//

import AVFoundation
import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Fruit Container
    var container: FruitContainerShape!
    // Next Fruit
    var nextDroppingFruit: Fruit!
    // Fruit Banner (at bottom)
    var banner: FruitBanner!
    // Score Label (at top)
    var scoreLabel: SKLabelNode!

    // Current Score
    private var score: Int = 0 {
        didSet {
            self.scoreLabel.text = "\(self.score)"
        }
    }

    override func didMove(to view: SKView) {

        self.isUserInteractionEnabled = false
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = GlobalTextureStore.backgroundColor
        self.container = self.setupFruitContainer()
        self.container.startMonitoring()
        self.banner = FruitBanner(in: self)
        self.addChild(banner)

        self.setupNextDroppingFruit()

        self.scoreLabel = SKLabelNode(text: "\(score)")
        self.scoreLabel.fontName = "Helvetica-Bold"
        self.scoreLabel.fontSize = 36
        self.scoreLabel.fontColor = .orange
        // Optionally, offset the score slightly upward.
        self.scoreLabel.position = CGPoint(
            x: self.frame.width / 2, y: self.frame.maxY - 80)
        self.scoreLabel.zPosition = 100
        self.addChild(self.scoreLabel)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDropped),
            name: .fruitDropped,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScored),
            name: .scored,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleGameOver),
            name: .gameOver,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)

        self.playBackgroundMusic()
    }

    @objc func appDidEnterBackground() {
        stopBackgroundMusic()
    }

    @objc func appDidBecomeActive() {
        self.playBackgroundMusic()
    }

    @objc func handleGameOver(_ notification: Notification) {
        stopBackgroundMusic()
        self.container.stopMonitoring()
        self.isPaused = true
        self.physicsWorld.speed = 0

        // Ensure we're on main thread and have a valid view reference
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                let view = self.view
            else { return }

            print("Game Over - Presenting GameOverScene")

            // Create scene using view's bounds (not scene's bounds)
            let gameOverScene = GameOverScene(
                size: view.bounds.size,
                score: self.score
            )
            gameOverScene.scaleMode = .aspectFill

            // 4. Configure transition properly
            view.presentScene(
                gameOverScene
            )

            // 6. Clean up previous scene
            self.removeAllActions()
            self.removeAllChildren()
        }
    }

    @objc func handleScored(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let score = userInfo["score"] as? Int
        {
            self.score += score
        }
    }

    private var dropSound: SKAudioNode!

    @objc func handleDropped(_ notification: Notification) {
        playBubbleSound()
        NotificationCenter.default.post(
            name: .createDroppingFruit,
            object: nil,
            userInfo: ["droppingFruitType": self.nextDroppingFruit.fruitType])
        self.nextDroppingFruit.removeFromParent()
        self.setupNextDroppingFruit()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let collision =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.fruit | PhysicsCategory.fruit {

            guard let fruitA = contact.bodyA.node as? Fruit,
                let fruitB = contact.bodyB.node as? Fruit,
                fruitA.fruitType == fruitB.fruitType,
                !fruitA.isMerging,
                !fruitB.isMerging
            else { return }

            // Mark fruits as being merged
            fruitA.isMerging = true
            fruitB.isMerging = true

            fruitA.merge(fruitB)
        }
    }

    private func setupNextDroppingFruit() {
        guard
            let nextFruitType = self.container.fruitPool.randomElement()
        else { return }
        let posX =
            self.container.position.x
            + self.container.containerSize.width - 20
        let posY =
            self.container.position.y
            + self.container.containerSize.height + 30

        self.nextDroppingFruit = Fruit(nextFruitType, isInDisplayMode: true)
        self.nextDroppingFruit.position = CGPoint(x: posX, y: posY)
        self.addChild(nextDroppingFruit)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
