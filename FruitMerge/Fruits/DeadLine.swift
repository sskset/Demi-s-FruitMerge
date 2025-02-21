//
//  WarningLine.swift
//  FruitMerge
//
//  Created by Shan Ke on 22/2/2025.
//

import SpriteKit

class DeadLine: SKShapeNode {
    
    init(in container: FruitContainerShape) {
        super.init()
        
        let startPoint = CGPoint(x: 0, y: container.containerSize.height * 0.9)
        let endPoint = CGPoint(
            x: container.containerSize.width,
            y: container.containerSize.height * 0.9)
        
        let linePath = CGMutablePath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        
        self.path = linePath
        
        self.strokeColor = .red
        self.lineWidth = 5.0
        self.zPosition = 100
        self.isHidden = true
        
        container.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func blink() {
        // Check if the blink action is already running; if so, return immediately.
        if self.action(forKey: "blinkDeadLine") != nil {
            return
        }
        
        // Ensure the node is visible before starting the animation.
        self.isHidden = false
        self.alpha = 1.0
        
        // Create the blink animation sequence.
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let blinkSequence = SKAction.sequence([fadeOut, fadeIn])
        let blinkFor5Seconds = SKAction.repeat(blinkSequence, count: 5)
        
        // Create an action to hide the node once the blink is complete.
        let hideAction = SKAction.run { [weak self] in
            self?.isHidden = true
        }
        
        // Combine the blink sequence with the hide action.
        let fullSequence = SKAction.sequence([blinkFor5Seconds, hideAction])
        
        // Run the full sequence with a unique key.
        self.run(fullSequence, withKey: "blinkDeadLine")
    }
}
