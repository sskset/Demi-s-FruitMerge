import GameKit
import UIKit

class GameCenterManager: NSObject {

    struct LeaderboardEntry {
        let playerName: String
        let score: Int
        let rank: Int
    }

    // Leaderboard ID (replace with your actual leaderboard identifier)
    static let leaderboardID = "codedance.com.au.fruitmerge.scoreboard"

    // Shared instance
    static let shared = GameCenterManager()

    // Flag to track authentication status
    var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }

    func authenticateLocalPlayer(completion: ((Error?) -> Void)? = nil) {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let vc = viewController {
                // Present the Game Center login using the appropriate window scene for iOS 15+
                if let windowScene = UIApplication.shared.connectedScenes.first(
                    where: { $0.activationState == .foregroundActive })
                    as? UIWindowScene,
                    let keyWindow = windowScene.windows.first(where: {
                        $0.isKeyWindow
                    }),
                    let rootVC = keyWindow.rootViewController
                {
                    rootVC.present(vc, animated: true, completion: nil)
                } else {
                    print(
                        "Error: Unable to find a view controller to present the login."
                    )
                }
            } else if localPlayer.isAuthenticated {
                print("Player authenticated")
                // Delay slightly to ensure the state is fully updated.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion?(nil)
                }
            } else {
                // If not authenticated and no view controller, return an error.
                let authError =
                    error
                    ?? NSError(
                        domain: "GameCenter", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Unknown authentication error"
                        ])
                print(
                    "Player is not authenticated: \(authError.localizedDescription)"
                )
                completion?(authError)
            }
        }
    }

    func authenticateLocalPlayerAsync() async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            self.authenticateLocalPlayer { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func submitScore(_ score: Int, completion: ((Error?) -> Void)? = nil) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated. Cannot submit score.")
            completion?(nil)
            return
        }

        // Use the new GKLeaderboard.submitScore API (available in iOS 14+).
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [GameCenterManager.leaderboardID]
        ) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
                completion?(error)
            } else {
                print(
                    "Score \(score) submitted successfully to leaderboard \(GameCenterManager.leaderboardID)"
                )
                completion?(nil)
            }
        }
    }

    func fetchPlayerHighestScoreAsync() async throws -> Int? {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated. Cannot fetch score.")
            return nil
        }

        return try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Int?, Error>) in
            GKLeaderboard.loadLeaderboards(IDs: [
                GameCenterManager.leaderboardID
            ]) { leaderboards, error in
                if let error = error {
                    print(
                        "Error loading leaderboards: \(error.localizedDescription)"
                    )
                    continuation.resume(throwing: error)
                    return
                }

                guard let leaderboard = leaderboards?.first else {
                    print("Leaderboard not found.")
                    continuation.resume(returning: nil)
                    return
                }

                leaderboard.loadEntries(
                    for: .global, timeScope: .allTime,
                    range: NSRange(location: 1, length: 1)
                ) { localPlayerEntry, entries, totalPlayerCount, error in
                    if let error = error {
                        print(
                            "Error loading leaderboard entries: \(error.localizedDescription)"
                        )
                        continuation.resume(throwing: error)
                        return
                    }

                    if let localEntry = localPlayerEntry {
                        print("Local player's score is \(localEntry.score)")
                        continuation.resume(returning: localEntry.score)
                    } else {
                        print("Local player's score not available.")
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }

    func fetchGlobalLeaderboardScores(
        completion: @escaping ([LeaderboardEntry]?, Error?) -> Void
    ) {
        GKLeaderboard.loadLeaderboards(IDs: [GameCenterManager.leaderboardID]) {
            [weak self] (leaderboards, error) in
            guard self != nil else { return }

            if let error = error {
                // Error loading leaderboard
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            guard let leaderboard = leaderboards?.first else {
                // No leaderboard found for the given ID
                DispatchQueue.main.async { completion([], nil) }
                return
            }
            // Load global (all players) entries, e.g. top 10 scores, for all time
            leaderboard.loadEntries(
                for: .global, timeScope: .allTime,
                range: NSRange(location: 1, length: 10)
            ) { localEntry, entries, totalCount, error in
                if let error = error {
                    DispatchQueue.main.async { completion(nil, error) }
                } else if let entries = entries {
                    // Map to LeaderboardEntry (extract player name, score, rank)
                    let resultEntries: [LeaderboardEntry] = entries.map {
                        entry in
                        LeaderboardEntry(
                            playerName: entry.player.displayName,
                            score: entry.score,
                            rank: entry.rank)
                    }
                    // Ensure sorted by rank (ascending)
                    let sortedByRank = resultEntries.sorted(by: {
                        $0.rank < $1.rank
                    })
                    DispatchQueue.main.async {
                        completion(sortedByRank, nil)
                    }
                } else {
                    // No entries (e.g. no scores posted yet)
                    DispatchQueue.main.async {
                        completion([], nil)
                    }
                }
            }
        }
    }

    func fetchFriendsLeaderboardScores(
        completion: @escaping ([LeaderboardEntry]?, Error?) -> Void
    ) {
        // Ensure local player is authenticated to Game Center
        guard GKLocalPlayer.local.isAuthenticated else {
            let authError = NSError(
                domain: "GameCenterError", code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Game Center player not authenticated"
                ])
            DispatchQueue.main.async { completion(nil, authError) }
            return
        }  // same leaderboard ID as above
        GKLeaderboard.loadLeaderboards(IDs: [GameCenterManager.leaderboardID]) {
            [weak self] (leaderboards, error) in
            guard self != nil else { return }
            if let error = error {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            guard let leaderboard = leaderboards?.first else {
                DispatchQueue.main.async { completion([], nil) }
                return
            }
            // Load friends-only entries (scores from the user's Game Center friends)
            leaderboard.loadEntries(
                for: .friendsOnly, timeScope: .allTime,
                range: NSRange(location: 1, length: 10)
            ) { localEntry, entries, totalCount, error in
                if let error = error {
                    DispatchQueue.main.async { completion(nil, error) }
                } else if let entries = entries {
                    let resultEntries = entries.map { entry in
                        LeaderboardEntry(
                            playerName: entry.player.displayName,
                            score: entry.score,
                            rank: entry.rank)
                    }
                    let sortedByRank = resultEntries.sorted(by: {
                        $0.rank < $1.rank
                    })
                    DispatchQueue.main.async {
                        completion(sortedByRank, nil)
                    }
                } else {
                    // No friend scores available
                    DispatchQueue.main.async {
                        completion([], nil)
                    }
                }
            }
        }
    }
}
