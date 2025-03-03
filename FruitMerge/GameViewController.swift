import GameKit
import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    private var gameOverScene: GameOverScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleViewLeaderboard),
            name: .viewLeaderboard, object: nil)

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
        gcViewController.gameCenterDelegate = self
        present(gcViewController, animated: true, completion: nil)
    }

    @objc func handleViewLeaderboard(notification: Notification) {
        showLeaderboard()
        
        if let scene = notification.object as? GameOverScene {
            self.gameOverScene = scene
        }
    }

    func showLeaderboard() {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .leaderboards
        gcViewController.leaderboardIdentifier = GameCenterManager.leaderboardID

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

    func gameCenterViewControllerDidFinish(
        _ gameCenterViewController: GKGameCenterViewController
    ) {
        gameCenterViewController.dismiss(animated: true) { [weak self] in
            guard let self = self, let skView = self.view as? SKView else {
                return
            }
            // If gameOverScene exists, call resumeGame()

            self.gameOverScene?.resumeGame()
        }
    }

}
