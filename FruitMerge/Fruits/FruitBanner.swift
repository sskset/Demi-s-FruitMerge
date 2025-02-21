//
//  FruitBanner.swift
//  FruitMerge
//
//  Created by Shan Ke on 16/2/2025.
//

import SpriteKit

class FruitBanner: SKShapeNode {

    var size: CGSize!

    init(in scene: SKScene!) {
        super.init()
        self.position = CGPoint(
            x: 0.05 * scene.size.width, y: scene.size.height * 0.05 + 10)
        self.size = CGSize(
            width: scene.size.width * 0.9, height: scene.size.height * 0.1)
        self.fillColor = .white

        var fruitPos = self.position
        for x in FruitType.allCases {
            let f = Fruit(x, isInDisplayMode: true)
            f.position = fruitPos
            self.addChild(f)

            fruitPos = CGPoint(x: fruitPos.x + 32, y: fruitPos.y)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
