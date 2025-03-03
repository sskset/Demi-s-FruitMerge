//
//  ScoreBoardScene.swift
//  FruitMerge
//
//  Created by Shan Ke on 24/2/2025.
//

import SpriteKit

class LeaderboardScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        
        let titleLabel = SKLabelNode(text: "Leaderboard")
        titleLabel.fontSize = 36
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 60)
        addChild(titleLabel)
    }
}
