//
//  DroppingFruitAimingLine.swift
//  FruitMerge
//
//  Created by Shan Ke on 18/2/2025.
//


import SpriteKit

class DroppingFruitAimingLine: SKNode {
    private let lineNode = SKShapeNode()
    
    init(length: CGFloat) {
        super.init()
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -length))
        
        lineNode.path = path.copy(dashingWithPhase: 0,
                                  lengths: [4, 4]) // [dashLength, gapLength]
        lineNode.strokeColor = .white
        lineNode.lineWidth = 2
        lineNode.lineCap = .round
        self.zPosition = 5
        
        self.addChild(lineNode)
    }
    
    func updateLength(_ newLength: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -newLength))
        lineNode.path = path.copy(dashingWithPhase: 0, lengths: [4, 4])
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
