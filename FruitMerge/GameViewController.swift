//
//  GameViewController.swift
//  FruitMerge
//
//  Created by Shan Ke on 15/2/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the view is an SKView
        guard let skView = self.view as? SKView else {
            print("View is not an SKView")
            return
        }
        
        // Load 'GameScene.sks' as an SKScene
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFit
            
            // Present the scene
            skView.presentScene(scene)
            
            skView.ignoresSiblingOrder = true
            
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
        } else {
            print("Failed to load GameScene.sks")
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
