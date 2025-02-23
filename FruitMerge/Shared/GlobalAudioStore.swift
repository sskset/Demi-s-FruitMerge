//
//  GlobalAudioStore.swift
//  FruitMerge
//
//  Created by Shan Ke on 23/2/2025.
//

import AVFoundation
import SpriteKit

struct GlobalAudioStore {
    static var players: [String: AVAudioPlayer] = [:]
}


extension SKNode {
    func playBackgroundMusic() {
        // For example, start background music using the "game_scene" audio player:
        if let bgMusicPlayer = GlobalAudioStore.players["game_scene"] {
            bgMusicPlayer.numberOfLoops = -1  // Loop indefinitely for background music
            bgMusicPlayer.currentTime = 0     // Restart if needed
            bgMusicPlayer.play()
        }
    }
    
    func stopBackgroundMusic() {
        if let bgMusicPlayer = GlobalAudioStore.players["game_scene"] {
            bgMusicPlayer.stop()
        }
    }
    
    func playMergeSound() {
        // To play a one-time sound effect like "merge"
        if let mergePlayer = GlobalAudioStore.players["merge"] {
            mergePlayer.currentTime = 0 // Reset playback to the beginning
            mergePlayer.play()
        } else {
            print("Merge audio not found!")
        }
    }
    
    func playBubbleSound() {
        // Similarly for the "bubble" sound effect:
        if let bubblePlayer = GlobalAudioStore.players["bubble"] {
            bubblePlayer.currentTime = 0
            bubblePlayer.play()
        } else {
            print("Bubble audio not found!")
        }
    }
}
