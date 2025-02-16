//
//  Fruit.swift
//  FruitMerge
//
//  Created by Shan Ke on 15/2/2025.
//

import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let fruit: UInt32 = 0b1
    static let container: UInt32 = 0b10
}

enum FruitType: Int, CaseIterable {
    case blueBerry = 1
    case strawBerry
    case lemon
    case mango
    case peach
    case coconut
    case grape
    case durian
    case pitaya
    case pineapple
    case watermelon
    
    var next: FruitType? {
        return FruitType(rawValue: self.rawValue + 1)
    }
    
    var scale: CGFloat {
        return self == .blueBerry
        ? 0.07 + 0.02 * CGFloat(rawValue)
        : 0.1 + 0.03 * CGFloat(rawValue)
    }
}


class Fruit: SKSpriteNode {

    let fruitType: FruitType
    var isMerging = false

    init(fruitType: FruitType) {
        self.fruitType = fruitType
        let texture = SKTexture(imageNamed: "fruit\(fruitType.rawValue)")

        super.init(texture: texture, color: .clear, size: texture.size())

        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.none

        self.setScale(self.fruitType.scale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func merge() -> Fruit? {
        guard let nextFruitType = fruitType.next else { return nil }
        return Fruit(fruitType: nextFruitType)
    }

    func setupPhysics() {
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.fruit
        self.physicsBody?.contactTestBitMask =
            PhysicsCategory.fruit | PhysicsCategory.container
        self.physicsBody?.collisionBitMask =
            PhysicsCategory.fruit | PhysicsCategory.container

        self.physicsBody?.friction = 0.5
        self.physicsBody?.restitution = 0.1
        self.physicsBody?.density = 0.8
        self.physicsBody?.linearDamping = 0.2
        self.physicsBody?.angularDamping = 0.2
        self.physicsBody?.allowsRotation = true
    }

    var isStable: Bool {
        guard let physics = physicsBody else { return true }
        let speed = sqrt(
            pow(physics.velocity.dx, 2) + pow(physics.velocity.dy, 2))
        return speed < 50
    }
}

