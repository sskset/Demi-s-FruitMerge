//
//  FruitType.swift
//  FruitMerge
//
//  Created by Shan Ke on 18/2/2025.
//


import SpriteKit

enum FruitType: Int, CaseIterable {
    case blueBerry = 1
    case strawBerry
    case lemon
    case mango
    case dragonfruit
    case peach
    case grape
    case pineapple
    case coconut
    case durian
    case watermelon
    
    var next: FruitType? {
        return FruitType(rawValue: self.rawValue + 1)
    }
    
    // Define the desired width (in points) for each fruit type.
    var desiredWidth: CGFloat {
        switch self {
        case .blueBerry:      return 20   // Adjust these values as needed
        case .strawBerry:     return 40
        case .lemon:          return 50
        case .mango:          return 60
        case .dragonfruit:    return 70
        case .peach:          return 80
        case .grape:          return 90
        case .pineapple:      return 100
        case .coconut:        return 110
        case .durian:         return 120
        case .watermelon:     return 130
        }
    }
    
    // The scale is the desired width divided by the original image width (512).
    var scale: CGFloat {
        return desiredWidth / 512.0
    }

}
