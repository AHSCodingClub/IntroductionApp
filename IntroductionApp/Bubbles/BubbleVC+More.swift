//
//  BubbleVC+More.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import UIKit
import ARKit

extension BubbleViewController {
    func setupListener() {
        model.handPositionsChanged = { [weak self] in
            guard let self = self else { return }
            self.hitTest()
        }
    }
    
    func hitTest() {
        
        let files = [
            "1Do.mp3",
            "2Re.mp3",
            "3Mi.mp3",
            "4Fa.mp3",
            "5So.mp3",
            "6La.mp3",
            "7Ti.mp3"
        ]
        
        for point in model.handPositions {
            let results = sceneView.hitTest(point, options: [SCNHitTestOption.searchMode : 1])
            if let hitResult = results.first {
                if hitResult.node.name == "Big Sphere" {
                    let scale = SCNAction.scale(to: 1.1, duration: 0.1)
                    hitResult.node.runAction(scale)
                    
                    let material = hitResult.node.geometry?.materials.first!
                    
                    /// Make that face's color animate to white and back
                    let colorAnimation = CABasicAnimation(keyPath: #keyPath(SCNMaterial.diffuse.contents))
                    colorAnimation.toValue = UIColor.white
                    colorAnimation.duration = 0.2
                    colorAnimation.autoreverses = true
                    colorAnimation.isRemovedOnCompletion = true
                    material?.addAnimation(colorAnimation, forKey: nil)
                    
                    if files.indices.contains(currentBigCircleIndex) {
                        let sound = files[currentBigCircleIndex]
                        GSAudio.sharedInstance.playSound(soundFileName: sound)
                    }
                    currentBigCircleIndex += 1
                    
                    if currentBigCircleIndex >= files.count {
                        let scale = SCNAction.scale(to: 1.4, duration: 0.5)
                        let opacity = SCNAction.fadeOpacity(to: 0, duration: 0.5)
                        let group = SCNAction.group([scale, opacity])
                        hitResult.node.runAction(group)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.ending(at: hitResult.node.position)
                            
                            self.nodes.removeAll(where: { $0.position.x == hitResult.node.position.x })
                            hitResult.node.removeFromParentNode()
                        }
                        
                    }
                } else {
                    let scale = SCNAction.scale(to: 1.1, duration: 0.1)
                    let opacity = SCNAction.fadeOpacity(to: 0, duration: 0.1)
                    let group = SCNAction.group([scale, opacity])
                    hitResult.node.runAction(group)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        self.nodes.removeAll(where: { $0.position.x == hitResult.node.position.x })
                        hitResult.node.removeFromParentNode()
                    }

                    let sound = files.randomElement()!
                    GSAudio.sharedInstance.playSound(soundFileName: sound)
                }
            }
        }
    }
    
    func ending(at position: SCNVector3) {
        if let image = globalViewModel.drawingImage {
            let node = SCNNode(geometry: SCNPlane(width: 1, height: 1))
            node.geometry?.firstMaterial?.diffuse.contents = image
            var adjustedPosition = position
            adjustedPosition.z += 0.05
            node.position = adjustedPosition
            node.eulerAngles.x = Float.pi / 2
            sceneView.scene.rootNode.addChildNode(node)
            
            let box = SCNBox(width: 1, height: 1, length: 0.1, chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIImage(named: "Texture1")!
            let boxNode = SCNNode(geometry: box)
            sceneView.scene.rootNode.addChildNode(boxNode)
            
            
            /// Make the audio source
            let audioSource = SCNAudioSource(fileNamed: "1Do.mp3")!
            
            /// As an environmental sound layer, audio should play indefinitely
            audioSource.loops = true
            audioSource.isPositional = true
            
            /// Decode the audio from disk ahead of time to prevent a delay in playback
            audioSource.load()
            
            /// Add the audio player now
            let player =  SCNAudioPlayer(source: audioSource)
            boxNode.addAudioPlayer(player)
        }
    }
}

class GSAudio: NSObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = GSAudio()
    
    private override init() { }
    
    var players: [URL: AVAudioPlayer] = [:]
    var duplicatePlayers: [AVAudioPlayer] = []
    
    func playSound(soundFileName: String) {
        
        guard let bundle = Bundle.main.path(forResource: soundFileName, ofType: "nil") else { return }
        let soundFileNameURL = URL(fileURLWithPath: bundle)
        
        if let player = players[soundFileNameURL] { //player for sound has been found
            
            if !player.isPlaying { //player is not in use, so use that one
                player.prepareToPlay()
                player.play()
            } else { // player is in use, create a new, duplicate, player and use that instead
                
                do {
                    let duplicatePlayer = try AVAudioPlayer(contentsOf: soundFileNameURL)
                    
                    duplicatePlayer.delegate = self
                    //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                    
                    duplicatePlayers.append(duplicatePlayer)
                    //add duplicate to array so it doesn't get removed from memory before finishing
                    
                    duplicatePlayer.prepareToPlay()
                    duplicatePlayer.play()
                } catch let error {
                    print(error.localizedDescription)
                }
                
            }
        } else { //player has not been found, create a new player with the URL if possible
            do {
                let player = try AVAudioPlayer(contentsOf: soundFileNameURL)
                players[soundFileNameURL] = player
                player.prepareToPlay()
                player.play()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func playSounds(soundFileNames: [String]) {
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func playSounds(soundFileNames: String...) {
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func playSounds(soundFileNames: [String], withDelay: Double) { //withDelay is in seconds
        for (index, soundFileName) in soundFileNames.enumerated() {
            let delay = withDelay * Double(index)
            let _ = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(playSoundNotification(_:)), userInfo: ["fileName": soundFileName], repeats: false)
        }
    }
    
    @objc func playSoundNotification(_ notification: NSNotification) {
        if let soundFileName = notification.userInfo?["fileName"] as? String {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = duplicatePlayers.index(of: player) {
            duplicatePlayers.remove(at: index)
        }
    }
    
}
