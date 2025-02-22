import SpriteKit

class GameOverScene: SKScene {
    private var score: Int = 0
    private var restartButton: SKSpriteNode!
    
    // MARK: - Initialization
    init(size: CGSize, score: Int) {
        self.score = score
        super.init(size: size)
        scaleMode = .aspectFill
        
        // Only proceed if the player is authenticated.
        if GameCenterManager.shared.isAuthenticated {
            // Submit the current score.
            GameCenterManager.shared.submitScore(score) { error in
                if let error = error {
                    print("Error submitting score: \(error.localizedDescription)")
                } else {
                    print("Score \(score) submitted successfully!")
                }
            }
            
            // Fetch the player's history score.
            GameCenterManager.shared.fetchPlayerHighestScore() { historyScore, error in
                if let error = error {
                    print("Error fetching player's history score: \(error.localizedDescription)")
                } else if let historyScore = historyScore {
                    print("Player's history score: \(historyScore)")
                } else {
                    print("Player's history score not available.")
                }
            }
        } else {
            print("Player is not authenticated. Score submission and history retrieval skipped.")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        createBackground()
        createScoreLabel()
        createGameOverText()
        createRestartButton()
        addParticleEffect()
    }
    
    private func createBackground() {
        let background = SKSpriteNode(color: UIColor(white: 0, alpha: 0.7), size: size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }
    
    private func createScoreLabel() {
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.name = "scoreLabel"
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        scoreLabel.zPosition = 1
        
        addChild(scoreLabel)
        scoreLabel.run(.sequence([
            .scale(to: 1.2, duration: 0.2),
            .scale(to: 1.0, duration: 0.2)
        ]))
    }
    
    private func createGameOverText() {
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 60
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 150)
        gameOverLabel.zPosition = 1
        
        addChild(gameOverLabel)
        gameOverLabel.run(.sequence([
            .scale(to: 0, duration: 0),
            .scale(to: 1.2, duration: 0.3),
            .scale(to: 1.0, duration: 0.2)
        ]))
    }
    
    private func createRestartButton() {
        restartButton = SKSpriteNode(color: .systemGreen, size: CGSize(width: 200, height: 60))
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        restartButton.zPosition = 1
        
        let buttonLabel = SKLabelNode(text: "Play Again")
        buttonLabel.fontName = "AvenirNext-Bold"
        buttonLabel.fontSize = 30
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        
        restartButton.addChild(buttonLabel)
        addChild(restartButton)
        
        // Add pulsing animation
        restartButton.run(.repeatForever(.sequence([
            .scale(to: 1.05, duration: 0.5),
            .scale(to: 0.95, duration: 0.5)
        ])))
    }
    
    private func addParticleEffect() {
        if let particles = SKEmitterNode(fileNamed: "GameOverParticles.sks") {
            particles.position = CGPoint(x: size.width/2, y: size.height)
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
            restartButton.run(.sequence([
                .scale(to: 0.9, duration: 0.1),
                .scale(to: 1.0, duration: 0.1),
                .run { [weak self] in
                    self?.restartGame()
                }
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
            guard let view = self.view else {return}
            let gameScene = GameScene(size: view.bounds.size)
            gameScene.scaleMode = .aspectFit
            view.presentScene(gameScene)
        }
    }
}
