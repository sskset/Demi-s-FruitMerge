//
//  Events.swift
//  FruitMerge
//
//  Created by Shan Ke on 22/2/2025.
//

import SpriteKit


extension Notification.Name {
    static let fruitDropped = Notification.Name(".fruitDropped")
    static let scored = Notification.Name(".scoreď")
    
    static let createDroppingFruit = Notification.Name(".createDroppingFruit")
    
    static let touchWarningLine = Notification.Name(".touchWarningLine")
    static let touchDeadLine = Notification.Name(".touchDeadLine")
    
    static let gameOver = Notification.Name(".gameOver")
    static let viewLeaderboard = Notification.Name(".viewLeaderboard")
}
