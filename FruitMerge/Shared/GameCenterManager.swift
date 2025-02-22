import GameKit
import UIKit

class GameCenterManager: NSObject, GKGameCenterControllerDelegate {
    
    // Leaderboard ID (replace with your actual leaderboard identifier)
    static let leaderboardID = "codedance.com.au.fruitmerge.scoreboard"
    
    // Shared instance
    static let shared = GameCenterManager()
    
    // Flag to track authentication status
    var isAuthenticated = false
    
    // MARK: - Authentication
    
    /// Authenticate the local player. Optionally provide a view controller to present the login if needed.
    func authenticateLocalPlayer(presentingVC: UIViewController?) {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Game Center authentication error: \(error.localizedDescription)")
                return
            }
            
            if let vc = viewController, let presentingVC = presentingVC {
                presentingVC.present(vc, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                print("Game Center: Player authenticated")
                self.isAuthenticated = true
            } else {
                print("Game Center: Player not authenticated")
                self.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Submit Score
    
    /// Submits the given score to the leaderboard.
    /// - Parameters:
    ///   - score: The score value to submit.
    ///   - completion: Optional completion closure with an Error? parameter.
    func submitScore(_ score: Int, completion: ((Error?) -> Void)? = nil) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated. Cannot submit score.")
            completion?(nil)
            return
        }
        
        // Use the new GKLeaderboard.submitScore API (available in iOS 14+).
        GKLeaderboard.submitScore(score,
                                  context: 0,
                                  player: GKLocalPlayer.local,
                                  leaderboardIDs: [GameCenterManager.leaderboardID]) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
                completion?(error)
            } else {
                print("Score \(score) submitted successfully to leaderboard \(GameCenterManager.leaderboardID)")
                completion?(nil)
            }
        }
    }
    
    // MARK: - Fetch Player Score
    
    /// Fetches the current player's score for the configured leaderboard.
    /// - Parameter completion: Completion closure providing the score as Int64? and an optional Error.
    func fetchPlayerHighestScore(completion: @escaping (Int?, Error?) -> Void) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated. Cannot fetch score.")
            completion(nil, nil)
            return
        }
        
        GKLeaderboard.loadLeaderboards(IDs: [GameCenterManager.leaderboardID]) { leaderboards, error in
            if let error = error {
                print("Error loading leaderboards: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let leaderboard = leaderboards?.first else {
                print("Leaderboard not found.")
                completion(nil, nil)
                return
            }
            
            // Instead of using the deprecated localPlayerScore property,
            // we use loadEntries to fetch the local player's entry.
            leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 1)) { localPlayerEntry, entries, totalPlayerCount, error in
                if let error = error {
                    print("Error loading leaderboard entries: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                if let localEntry = localPlayerEntry {
                    print("Local player's score is \(localEntry.score)")
                    completion(localEntry.score, nil)
                } else {
                    print("Local player's score not available.")
                    completion(nil, nil)
                }
            }
        }
    }

    
    // MARK: - GKGameCenterControllerDelegate
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
