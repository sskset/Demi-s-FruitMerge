//
//  FruitContainer1.swift
//  FruitMerge
//
//  Created by Shan Ke on 21/2/2025.
//

import SpriteKit



class FruitContainerPhysicsBodyShape: SKShapeNode {
    
    init(in container: FruitContainerShape!) {
        super.init()
        
        self.lineWidth = container.lineWidth
        self.zPosition = container.zPosition + 1
        
        let bottomEdge = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0),
                                       to: CGPoint(x: container.containerSize.width, y: 0))
        let leftEdge   = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0),
                                       to: CGPoint(x: 0, y: container.containerSize.height))
        let rightEdge  = SKPhysicsBody(edgeFrom: CGPoint(x: container.containerSize.width, y: 0),
                                       to: CGPoint(x: container.containerSize.width, y: container.containerSize.height))
        let compoundBody = SKPhysicsBody(bodies: [bottomEdge, leftEdge, rightEdge])
        compoundBody.isDynamic = false
        self.physicsBody = compoundBody
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.container
        self.physicsBody?.contactTestBitMask = PhysicsCategory.fruit
        self.physicsBody?.collisionBitMask = PhysicsCategory.fruit
        container.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
