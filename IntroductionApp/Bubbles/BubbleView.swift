//
//  BubbleView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct BubbleView: View {
    var admin: Bool
    @Binding var index: Int
    @ObservedObject var globalViewModel: GlobalViewModel
    @StateObject var model = BubbleViewModel()
    
    var body: some View {
        BubbleARViewControllerRepresentable(model: model)
            .overlay(alignment: .top) {
                BubbleTopBarView(admin: admin, index: $index, globalViewModel: globalViewModel)
            }
    }
}

struct BubbleTopBarView: View {
    var admin: Bool
    @Binding var index: Int
    @ObservedObject var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                if admin {
                    Button {
                        withAnimation {
                            index -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Button {
                        withAnimation {
                            index += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 3)
            .padding()
        }
    }
}
