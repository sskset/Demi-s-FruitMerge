//
//  SKNodeExtensions.swift
//  FruitMerge
//
//  Created by Shan Ke on 16/3/2025.
//
import SpriteKit

extension SKNode {
    func animatePress(action: @escaping () -> Void) {
        let pressSequence = SKAction.sequence([
            .scale(to: 0.9, duration: 0.1),
            .scale(to: 1.0, duration: 0.1),
            .run(action)
        ])
        self.run(pressSequence)
    }
}
