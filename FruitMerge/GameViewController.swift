import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Authenticate the local Game Center player.
        GameCenterManager.shared.authenticateLocalPlayer(presentingVC: self)
        
        // Create an SKView instance and add it to the view hierarchy.
        let skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        
        // Optionally configure the SKView for debugging.
        // skView.showsFPS = true
        // skView.showsNodeCount = true
        // skView.showsPhysics = true
        // skView.ignoresSiblingOrder = true
        
        // Create and present the LoadingScene.
        let loadingScene = LoadingScene(size: skView.bounds.size)
        loadingScene.scaleMode = .aspectFit
        skView.presentScene(loadingScene)
    }
    
    // Optional IBAction to display the Game Center view.
    @IBAction func showGameCenter(_ sender: UIButton) {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = GameCenterManager.shared
        present(gcViewController, animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
