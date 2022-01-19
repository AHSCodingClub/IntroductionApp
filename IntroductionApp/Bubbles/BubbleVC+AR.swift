//
//  BubbleVC+AR.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI
import ARKit
import Vision

extension BubbleViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard startTime == nil else { return }
        run(pixelBuffer: frame.capturedImage) { [weak self] poses in
            guard let self = self else { return }
            self.model.handPositions = poses.map { $0.point }
        }
    }
}

extension BubbleViewController {
    func setup() {
        model.clear = { [weak self] in
            guard let self = self else { return }
            for node in self.nodes {
                node.removeFromParentNode()
            }
        }
        
        model.spawn = { [weak self] in
            guard let self = self else { return }
            if let position = self.getPosition() {
                let basePosition = SCNVector3(
                    x: position.x,
                    y: position.y + 1.2,
                    z: position.z
                )
                
                for row in -5..<5 {
                    for column in -5..<5 {
//                        let position =
                        let rowOffset = Float(row) * 0.3
                        let columnOffset = Float(column) * 0.3
                        let position = SCNVector3(
                            x: position.x + rowOffset,
                            y: position.y,
                            z: position.z + columnOffset
                        )
                        self.spawnSphere(position: position)
                    }
                }
            }
        }
    }
    
    func spawnSphere(position: SCNVector3) {
        let sphereGeometry = SCNSphere(radius: CGFloat.random(in: 0.11...0.14))
        
        let material = SCNMaterial()
        material.lightingModel = .blinn
        material.transparencyMode = .dualLayer
        material.fresnelExponent = 1.5
        material.isDoubleSided = true
        material.specular.contents = UIColor(white: 0.6, alpha: 1.0)
        material.diffuse.contents = UIImage(named: "Texture")!
        material.shininess =  80
        material.reflective.contents = UIColor.gray.withAlphaComponent(0.7)
        sphereGeometry.materials = [material]
        
        let node = SCNNode(geometry: sphereGeometry)
        node.position = position
        let moveDown = SCNAction.move(by: SCNVector3(0, -CGFloat.random(in: 0.08...0.1), 0), duration: CGFloat.random(in: 0.5...2))
        let moveUp = SCNAction.move(by: SCNVector3(0, CGFloat.random(in: 0.08...0.1), 0), duration: CGFloat.random(in: 0.5...2))
        let waitAction = SCNAction.wait(duration: 0.25)
        let hoverSequence = SCNAction.sequence([moveUp, waitAction, moveDown])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
        node.runAction(loopSequence)
        
        
        self.nodes.append(node)
        self.sceneView.scene.rootNode.addChildNode(node)
    }

    func getPosition() -> simd_float4? {
        let touchLocation = CGPoint(x: view.frame.midX, y: view.frame.midY)
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if let hitResult = results.first {
            let position = hitResult.worldTransform.columns.3
            return position
        }
        return nil
    }
}
