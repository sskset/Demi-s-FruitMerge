//
//  GlobalTextureStore.swift
//  FruitMerge
//
//  Created by Shan Ke on 20/2/2025.
//

import SpriteKit

struct GlobalTextureStore {
    static var scaledTextures: [FruitType: SKTexture] = [:]
    static var scaledSizes: [FruitType: CGSize] = [:]
    
    static let backgroundColor: SKColor = SKColor(red: 57/255.0, green: 36/255.0, blue: 69/255.0, alpha: 1.0)
}
