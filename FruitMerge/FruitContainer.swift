import SpriteKit

class FruitContainer: SKShapeNode {
    
    let containerMargin: CGFloat = 20.0
    
    init(in gameScene: SKScene) {
        super.init()
        
        // Define the size of the container
        let containerSize = CGSize(
            width: gameScene.size.width * 0.8,
            height: gameScene.size.height
        )
        
        // Set the position of the container
        self.position = CGPoint(
            x: gameScene.frame.minX + 75,
            y: gameScene.frame.minY + 300
        )
        
        // Create the path for the shape
        let containerRect = CGRect(origin: .zero, size: containerSize)
        self.path = UIBezierPath(rect: containerRect).cgPath
        self.strokeColor = .white
        self.lineWidth = 15
        self.fillColor = .clear
        
        // Create the physics body from the path
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: containerRect)
        
        // Configure physics body properties
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 0.2
        self.physicsBody?.categoryBitMask = PhysicsCategory.container
        self.physicsBody?.collisionBitMask = PhysicsCategory.container | PhysicsCategory.fruit
        
        // Add the container to the scene
        gameScene.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
