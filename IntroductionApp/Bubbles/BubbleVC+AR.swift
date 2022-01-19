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
