//
//  BubbleViewModel.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class BubbleViewModel: ObservableObject {
    
    var clear: (() -> Void)?
    var spawn: (() -> Void)?
    var go: (() -> Void)?
    
    @Published var handPositions = [CGPoint]()
    var handPositionsChanged: (() -> Void)?
}
