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
        for point in model.handPositions {
            let results = sceneView.hitTest(point, options: [SCNHitTestOption.searchMode : 1])
            if let hitResult = results.first {
                let scale = SCNAction.scale(to: 1.1, duration: 0.1)
                let opacity = SCNAction.fadeOpacity(to: 0, duration: 0.1)
                let group = SCNAction.group([scale, opacity])
                hitResult.node.runAction(group)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    self.nodes.removeAll(where: { $0.position.x == hitResult.node.position.x })
                    hitResult.node.removeFromParentNode()
                }
                
                
                let path = Bundle.main.path(forResource: "Pop.mp3", ofType: nil)!
                let url = URL(fileURLWithPath: path)

                do {
                    soundEffect = try AVAudioPlayer(contentsOf: url)
                    soundEffect?.play()
                } catch {
                    // couldn't load file :(
                }
            }
        }
    }
}
