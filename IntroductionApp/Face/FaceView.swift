//
//  FaceView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

struct FaceView: View {
    @Binding var index: Int
    @ObservedObject var globalViewModel: GlobalViewModel
    @StateObject var model = FaceViewModel()
    @State var showingCamera = true
    
    var body: some View {
        VideoViewControllerRepresentable(model: model)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(showingCamera ? 1 : 0)
            .overlay {
                Image("Classroom")
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .overlay {
                        if let image = globalViewModel.drawingImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 700, height: 700)
                                .position(model.center)
                        }
                    }
                    .opacity(showingCamera ? 0 : 1)
            }
            .overlay(alignment: .topLeading) {
                TopBarView(index: $index, globalViewModel: globalViewModel, showingCamera: $showingCamera)
            }
    }
}
struct TopBarView: View {
    @Binding var index: Int
    @ObservedObject var globalViewModel: GlobalViewModel
    @Binding var showingCamera: Bool
    
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
                            showingCamera.toggle()
                        }
                    } label: {
                        Text(showingCamera ? "Hide Camera" : "Show Camera")
                    }
                    
                    Button {
                        globalViewModel.updateImage?()
                    } label: {
                        Text("Refresh Image")
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
//VideoViewController
