//
//  GameOverScene.swift
//  FruitMerge
//
//  Created by Shan Ke on 16/2/2025.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Fruit Container
    var container: FruitContainerShape!
    
    var nextDroppingFruit: DroppingFruit!
    var banner: FruitBanner!
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            self.scoreLabel.text = "\(self.score)"
        }
    }
    
    private var lastUpdateTime: TimeInterval?
    private var touchInterval: TimeInterval = 0.5
    var isGameOver = false

    override func didMove(to view: SKView) {

        self.backgroundColor = .gray
        self.container = self.setupFruitContainer()
        self.banner = FruitBanner(in: self)
        self.addChild(banner)

//        self.physicsWorld.gravity = CGVector(dx:0, dy: -4.9)
        self.physicsWorld.contactDelegate = self
        
        self.setupNextDroppingFruit()
        
        
        self.scoreLabel = SKLabelNode(text: "\(score)")
        self.scoreLabel.fontName = "Helvetica-Bold"
        self.scoreLabel.fontSize = 36
        self.scoreLabel.fontColor = .orange
        // Optionally, offset the score slightly upward.
        self.scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.maxY - 80)
        self.scoreLabel.zPosition = 100
        self.addChild(self.scoreLabel)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDropped),
            name: .dropped, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScored),
            name: .scored, object: nil)
    }
    @objc func handleScored(_ notification: Notification) {
        if  let userInfo = notification.userInfo,
            let score = userInfo["score"] as? Int {
            self.score += score
        }
    }
    
    @objc func handleDropped(_ notification:Notification) {
        self.container.createDroppingFruit(self.nextDroppingFruit.fruitType)
        self.nextDroppingFruit.removeFromParent()
        self.setupNextDroppingFruit()
    }

    override func update(_ currentTime: TimeInterval) {
        // If lastUpdateTime is nil (first update), set it and return.
        guard let lastTime = lastUpdateTime else {
            lastUpdateTime = currentTime
            return
        }
        
        // If not enough time has passed since the last update, return.
        guard currentTime - lastTime > touchInterval else { return }
        
        // Update the lastUpdateTime.
        lastUpdateTime = currentTime
        
        if container.droppingFruit.canDrop() {
            container.createDroppingFruit(self.nextDroppingFruit.fruitType)
            container.droppingFruit.attachAimingLine(
                aimingLine: container.droppingFruitAimingLine)
        }
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

        fruitA.merge(fruitB)
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

        self.nextDroppingFruit = DroppingFruit(nextFruitType)
        self.nextDroppingFruit.position = CGPoint(x: posX, y: posY)
        self.addChild(nextDroppingFruit)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dropped, object: nil)
        NotificationCenter.default.removeObserver(self, name: .scored, object: nil)
    }
}
