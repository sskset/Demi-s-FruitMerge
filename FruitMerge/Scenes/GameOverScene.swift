import SpriteKit

class GameOverScene: SKScene {
    private let uiAtlas = SKTextureAtlas(named: "UIAtlas")
    private var score: Int = 0 {
        didSet {
            UserDefaults.standard.set(score, forKey: "score")
        }
    }
    private var highestScore: Int = 0
    private var restartButton: SKSpriteNode!
    private var gameOverBanner: SKSpriteNode!
    private var leaderboardButton: SKSpriteNode!
    private var highestScoreValueLabel: SKLabelNode!

    // MARK: - Initialization
    init(size: CGSize, score: Int = 0) {
        if score == 0 {
            self.score = UserDefaults.standard.integer(forKey: "score")
        } else {
            self.score = score
        }
        super.init(size: size)
        scaleMode = .aspectFill

        // Only proceed if the player is authenticated.
        if GameCenterManager.shared.isAuthenticated {
            // Submit the current score.
            GameCenterManager.shared.submitScore(self.score) { error in
                if let error = error {
                    print(
                        "Error submitting score: \(error.localizedDescription)")
                } else {
                    print("Score \(self.score) submitted successfully!")
                }
            }

            // Fetch the player's history score.
            GameCenterManager.shared.fetchPlayerHighestScore {
                historyScore, error in
                if let error = error {
                    print(
                        "Error fetching player's history score: \(error.localizedDescription)"
                    )
                } else if let historyScore = historyScore {
                    self.highestScore = historyScore
                } else {
                    print("Player's history score not available.")
                }
            }
        } else {
            print(
                "Player is not authenticated. Score submission and history retrieval skipped."
            )
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        print("didMove: \(self.highestScore) and \(self.score)")
        createBackground()
        createGameOverText()
        createRestartButton()
        addParticleEffect()
        self.isPaused = false
    }

    private func createBackground() {
        let background = SKSpriteNode(
            color: UIColor(white: 0, alpha: 0.7), size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.color = GlobalTextureStore.backgroundColor
        addChild(background)
    }

    private func createGameOverText() {
        // Retrieve the texture for the game over banner
        let gameOverBoxTexture = self.uiAtlas.textureNamed(
            "Box_WhiteOutline_Square")  // Ensure "Box_Rounded" exists in the atlas
        let gameOverTextTexture = self.uiAtlas.textureNamed(
            "ButtonText_Small_Square")

        // Create the banner with the correct texture
        gameOverBanner = SKSpriteNode(
            texture: gameOverBoxTexture,
            size: CGSize(width: size.width * 0.8, height: size.width * 0.8))
        gameOverBanner.position = CGPoint(
            x: size.width / 2, y: size.height * 0.6)
        gameOverBanner.zPosition = 1

        let gameOverTextSquare = SKSpriteNode(
            texture: gameOverTextTexture,
            size: CGSize(
                width: size.width * 0.5,
                height: 80
            ))
        gameOverTextSquare.position = CGPoint(
            x: 0, y: gameOverBanner.size.height / 2)
        gameOverTextSquare.zPosition = 2
        gameOverBanner.addChild(gameOverTextSquare)

        // Create the "Game Over" label
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 30
        gameOverLabel.fontColor = .white
        gameOverLabel.verticalAlignmentMode = .center  // Ensures text is centered within the banner
        gameOverLabel.position = CGPoint(x: 0, y: 0)  // Center relative to the banner
        gameOverLabel.zPosition = 3

        // Add label to banner
        gameOverTextSquare.addChild(gameOverLabel)

        // Score Label (Title)
        let scoreTitleLabel = SKLabelNode(text: "Your Score")
        scoreTitleLabel.fontName = GlobalTextureStore.fontName
        scoreTitleLabel.fontSize = 24
        scoreTitleLabel.fontColor = .white
        scoreTitleLabel.zPosition = 3
        scoreTitleLabel.position = CGPoint(x: 0, y: -10)  // Adjust position for spacing

        // Score Value
        let scoreValueLabel = SKLabelNode(text: "\(self.score)")
        scoreValueLabel.fontName = GlobalTextureStore.fontName
        scoreValueLabel.fontSize = 24
        scoreValueLabel.fontColor = .white
        scoreValueLabel.zPosition = 3
        scoreValueLabel.position = CGPoint(x: 0, y: -50)  // Below title

        // Highest Score Label (Title)
        let highestScoreTitleLabel = SKLabelNode(text: "Highest Score")
        highestScoreTitleLabel.fontName = GlobalTextureStore.fontName
        highestScoreTitleLabel.fontSize = 24
        highestScoreTitleLabel.fontColor = .white
        highestScoreTitleLabel.zPosition = 3
        highestScoreTitleLabel.position = CGPoint(x: 0, y: 70)  // Position above

        // Highest Score Value
        highestScoreValueLabel = SKLabelNode(text: "\(self.highestScore)")
        highestScoreValueLabel.fontName = GlobalTextureStore.fontName
        highestScoreValueLabel.fontSize = 24
        highestScoreValueLabel.fontColor = .white
        highestScoreValueLabel.zPosition = 3
        highestScoreValueLabel.position = CGPoint(x: 0, y: 30)  // Below title

        // Add to gameOverBanner
        gameOverBanner.addChild(scoreTitleLabel)
        gameOverBanner.addChild(scoreValueLabel)
        gameOverBanner.addChild(highestScoreTitleLabel)
        gameOverBanner.addChild(highestScoreValueLabel)

        // Add banner to scene
        addChild(gameOverBanner)
    }

    private func createRestartButton() {

        let restartTexture = uiAtlas.textureNamed("Replay")
        restartButton = SKSpriteNode(
            texture: restartTexture, size: CGSize(width: 200, height: 60))
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(
            x: size.width / 2, y: size.height / 2 - 200)
        restartButton.zPosition = 1

        addChild(restartButton)

        // Add pulsing animation
        restartButton.run(
            .repeatForever(
                .sequence([
                    .scale(to: 1.01, duration: 0.5),
                    .scale(to: 0.99, duration: 0.5),
                ])))

        let leaderboardTexture = uiAtlas.textureNamed(
            "ButtonText_Large_Orange_Round")
        leaderboardButton = SKSpriteNode(
            texture: leaderboardTexture, size: CGSize(width: 200, height: 60))
        leaderboardButton.name = "leaderboardButton"
        leaderboardButton.position = CGPoint(
            x: restartButton.position.x, y: restartButton.position.y - 100)
        leaderboardButton.zPosition = 1

        let leaderboardButtonText = SKLabelNode(text: "Leaderboard")
        leaderboardButtonText.fontColor = .white
        leaderboardButtonText.fontName = GlobalTextureStore.fontName
        leaderboardButtonText.fontSize = 24
        leaderboardButtonText.position = CGPoint(x: 0, y: -10)
        leaderboardButtonText.zPosition = 3
        leaderboardButton.addChild(leaderboardButtonText)

        let leaderboardButtonTextShadow = SKLabelNode(text: "Leaderboard")
        leaderboardButtonTextShadow.fontColor = .gray
        leaderboardButtonTextShadow.fontName = GlobalTextureStore.fontName
        leaderboardButtonTextShadow.fontSize = 24
        leaderboardButtonTextShadow.position = CGPoint(x: 0, y: -8)
        leaderboardButtonTextShadow.zPosition = 2
        leaderboardButton.addChild(leaderboardButtonTextShadow)
        addChild(leaderboardButton)

        leaderboardButton.run(
            .repeatForever(
                .sequence([
                    .scale(to: 1.01, duration: 0.5),
                    .scale(to: 0.99, duration: 0.5),
                ])))

    }

    private func addParticleEffect() {
        if let particles = SKEmitterNode(fileNamed: "GameOverParticles.sks") {
            particles.position = CGPoint(x: size.width / 2, y: size.height)
            particles.zPosition = 0
            addChild(particles)
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if nodes(at: location).contains(restartButton) {
            // Animate button press
            restartButton.run(
                .sequence([
                    .scale(to: 0.9, duration: 0.1),
                    .scale(to: 1.0, duration: 0.1),
                    .run { [weak self] in
                        self?.restartGame()
                    },
                ]))
        } else if nodes(at: location).contains(leaderboardButton) {
            // Animate button press
            leaderboardButton.run(
                .sequence([
                    .scale(to: 0.9, duration: 0.1),
                    .scale(to: 1.0, duration: 0.1),
                    .run { [weak self] in
                        self?.viewLeaderboard()
                    },
                ]))
        }
    }

    private func restartGame() {
        print("Restart initiated")

        // 1. Clean up current scene
        self.removeAllActions()
        self.removeAllChildren()

        // Ensure we're on main thread for scene transition
        DispatchQueue.main.async {
            guard let view = self.view else { return }
            let gameScene = GameScene(size: view.bounds.size)
            gameScene.scaleMode = .aspectFit
            view.presentScene(gameScene)
        }
    }

    private func viewLeaderboard() {
        print("View Leaderboard")
        self.isPaused = true

        NotificationCenter.default.post(
            name: .viewLeaderboard,
            object: self
        )
    }

    func resumeGame() {
        #if DEBUG
            print("Resume GameOverScene")
        #endif
        self.isPaused = false
    }
}
