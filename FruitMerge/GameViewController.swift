import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an SKView instance
        let skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        
        // Configure the SKView directly
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
//        skView.ignoresSiblingOrder = true
        
        // Create and present the LoadingScene.
        let loadingScene = LoadingScene(size: skView.bounds.size)
        loadingScene.scaleMode = .aspectFit
        skView.presentScene(loadingScene)
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
