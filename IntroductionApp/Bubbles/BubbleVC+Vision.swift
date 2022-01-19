//
//  BubbleVC+Vision.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit
import Vision
import AVFoundation

struct HandPose {
    var point: CGPoint
}
extension BubbleViewController {
    func run(pixelBuffer: CVPixelBuffer, completion: @escaping (([HandPose]) -> Void)) {
        let request = VNDetectHumanHandPoseRequest { request, _ in
            DispatchQueue.main.async {
                let poses = self.getPoses(from: request)
                completion(poses)
            }
        }
        
        if let image = UIImage(pixelBuffer: pixelBuffer) {
//            print(image)
            
            
            
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        startTime = Date()
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch {
                print("Error finding: \(error)")
            }
        }
    }
    
    func getPoses(from request: VNRequest) -> [HandPose] {
        startTime = nil
        guard
            let results = request.results
        else {
            return []
        }
        
        var poses = [HandPose]()
        for case let observation as VNHumanHandPoseObservation in results {
            
            
            do {
                let point = try observation.recognizedPoint(.indexTip)
                
                let convertedPoint = CGPoint(
                    x: point.x * view.bounds.width,
                    y: (1 - point.y) * view.bounds.height
                )
                print("p: \(convertedPoint)")
                let pose = HandPose(
                    point: convertedPoint
                )
                
                poses.append(pose)
            } catch {
                print("No index finger: \(error)")
            }
        }
        
        return poses
        //
        //        startTime = nil
        //        return observations
    }
}
