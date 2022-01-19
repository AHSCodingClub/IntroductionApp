//
//  BubbleView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

struct BubbleButton: View {
    let title: String
    let action: (() -> Void)
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.largeTitle.bold())
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(24)
        }
    }
}
struct BubbleView: View {
    var admin: Bool
    @Binding var index: Int
    @ObservedObject var globalViewModel: GlobalViewModel
    @StateObject var model = BubbleViewModel()
    
    var body: some View {
        BubbleARViewControllerRepresentable(globalViewModel: globalViewModel, model: model)
            .overlay {
                ForEach(model.handPositions, id: \.x.self) { point in
                    Circle()
                        .fill(.white)
                        .frame(width: 30, height: 30)
                        .position(point)
                }
            }
            .overlay {
                VStack {
                    Spacer()
                    
                    HStack {
                        BubbleButton(title: "Clear") {
                            model.clear?()
                        }
                        
                        BubbleButton(title: "Spawn") {
                            model.spawn?()
                        }
                        
                        BubbleButton(title: "...") {
                            model.go?()
                        }
                    }
                    .frame(height: 100)
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                }
            }
            .overlay(alignment: .topLeading) {
                BubbleTopBarView(index: $index, showRight: true)
            }
            .ignoresSafeArea()
    }
}

struct BubbleTopBarView: View {
    @Binding var index: Int
    let showRight: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Button {
                    withAnimation {
                        index -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                if showRight {
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
