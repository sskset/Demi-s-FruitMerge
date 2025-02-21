import SpriteKit

class LoadingScene: SKScene {

    let fruitAtlasName: String = "FruitAtlas"
    var scaledTextures: [String: SKTexture] = [:]

    override func didMove(to view: SKView) {
        // Preload textures using the correct closure signature
        let atlasNames = [fruitAtlasName]
        SKTextureAtlas.preloadTextureAtlasesNamed(atlasNames) { error, atlases in
            let fruitAtlas = SKTextureAtlas(named: self.fruitAtlasName)
            for ft in FruitType.allCases {
                let textureName = "fruit\(ft.rawValue)"
                let originalTexture = fruitAtlas.textureNamed(textureName)
//                print("Fruit Type: \(ft) Original: \(originalTexture.size())")
                let sprite = SKSpriteNode(texture: originalTexture)
                sprite.setScale(ft.scale)
                
                if let scaledTexture = view.texture(from: sprite) {
//                    print("Scaled Size: \(scaledTexture.size())")
                    GlobalTextureStore.scaledTextures[ft] = scaledTexture
                    GlobalTextureStore.scaledRetio[ft] = scaledTexture.size().width / 30
                }
            }
            
            
            
            // Ensure we're on main thread for scene transition
            DispatchQueue.main.async {
                // Create scene with view's actual size
                let testScene = TestScene(size: view.bounds.size)
                testScene.scaleMode = .aspectFit
                view.presentScene(testScene)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchee")
    }
}
