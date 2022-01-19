//
//  SwiftView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct SwiftView: View {
    @Binding var index: Int
    var body: some View {
        Text("Swift")
            .gradientForeground([.blue, .green])
            .font(.system(size: 340, weight: .medium))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                BubbleTopBarView(index: $index, showRight: true)
            }
    }
}

extension View {
    public func gradientForeground(_ colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
            .mask(self)
    }
}
