import AVFoundation
import SpriteKit

class LoadingScene: SKScene {
    
    let fruitAtlasName: String = "FruitAtlas"
    let uiAtlasName: String = "UIAtlas"
    
    override func didMove(to view: SKView) {
        preloadAssets(for: view)
    }
    
    func preloadAssets(for view: SKView) {
        let atlasNames = [fruitAtlasName, uiAtlasName]
        let dispatchGroup = DispatchGroup()
        
        // Preload texture atlases
        dispatchGroup.enter()
        SKTextureAtlas.preloadTextureAtlasesNamed(atlasNames) { error, atlases in
            if let error = error {
                print("Error preloading texture atlases: \(error)")
            }
            let fruitAtlas = SKTextureAtlas(named: self.fruitAtlasName)
            for ft in FruitType.allCases {
                let textureName = "fruit\(ft.rawValue)"
                let originalTexture = fruitAtlas.textureNamed(textureName)
                let sprite = SKSpriteNode(texture: originalTexture)
                sprite.setScale(ft.scale)
                
                if let scaledTexture = view.texture(from: sprite) {
                    GlobalTextureStore.scaledTextures[ft] = scaledTexture
                    GlobalTextureStore.scaledSizes[ft] = CGSize(
                        width: scaledTexture.size().width / 30,
                        height: scaledTexture.size().height / 30)
                }
            }
            dispatchGroup.leave()
        }
        
        // Preload audio files
        dispatchGroup.enter()
        preloadAudioFiles {
            dispatchGroup.leave()
        }
        
        // When both tasks are finished, configure audio session and present GameScene
        dispatchGroup.notify(queue: .main) {
            self.configureAudioSession()
            let gameScene = GameOverScene(size: view.bounds.size, score:1928)
//            let gameScene = GameScene(size: view.bounds.size)
            gameScene.scaleMode = .aspectFit
            view.presentScene(gameScene)
        }
    }
    
    func preloadAudioFiles(completion: @escaping () -> Void) {
        // List of audio files to preload (without extension)
        let audioFilenames = ["game_scene", "bubble", "merge"]
        
        for file in audioFilenames {
            // Adjust subdirectory if your audio files are stored in a folder (e.g., "Sounds")
            guard let url = Bundle.main.url(forResource: file, withExtension: "mp3") else {
                print("Error: Audio file \(file).mp3 not found")
                continue
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                // Preload the audio buffer
                player.prepareToPlay()
                GlobalAudioStore.players[file] = player
            } catch {
                print("Error loading audio file \(file): \(error.localizedDescription)")
            }
        }
        completion()
    }
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setPreferredIOBufferDuration(0.01)  // Example for low latency
            try audioSession.setActive(true)
            print("Audio session configured with IOBufferDuration: \(audioSession.ioBufferDuration)")
        } catch {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
    }
}
