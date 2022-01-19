//
//  DrawingView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import PencilKit
import SwiftUI

struct DrawingView: View {
    @Binding var index: Int
    @ObservedObject var globalViewModel: GlobalViewModel
    @StateObject var model = DrawingViewModel()
    @State var selectedColor: UInt = 0x00AEEF
    
    var body: some View {
        if model.unlocked || admin {
            HStack(spacing: 24) {
                Group {
                    CanvasView(model: model, canvasView: $model.canvasView, selectedColor: $selectedColor) {
                        model.update()
                    }
                    .overlay {
                        Image("PersonOutline")
                            .resizable()
                            .opacity(0.5)
                            .allowsHitTesting(false)
                    }
                    .overlay(alignment: .topLeading) {
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
                                    model.canvasView.drawing = PKDrawing()
                                    model.update()
                                } label: {
                                    Text("Clear Drawing")
                                        .foregroundColor(.red)
                                }
                                
                                Button {
                                    if model.unlocked {
                                        model.unlock(false)
                                    } else {
                                        model.unlock(true)
                                    }
                                } label: {
                                    Text(model.unlocked ? "Lock Drawing" : "Unlock Drawing")
                                }
                                
                                Button {
                                    let image = model.canvasView.drawing.image(from: model.canvasView.bounds, scale: 2)
                                    globalViewModel.drawingImage = image
                                    withAnimation {
                                        index += 1
                                    }
                                } label: {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            
                            Text(verbatim: "Connected to: \(model.connectedPeers.map { $0.displayName })")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 3)
                        .padding()
                    }
                    PaletteView(selectedColor: $selectedColor)
                }
                .cornerRadius(32)
                .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 3)
            }
            .padding(24)
            .onChange(of: selectedColor) { newValue in
                model.colorChanged?()
            }
            
            .onAppear {
                globalViewModel.updateImage = {
                    let image = model.canvasView.drawing.image(from: model.canvasView.bounds, scale: 2)
                    globalViewModel.drawingImage = image
                }
            }
        } else {
            IntroView(index: .constant(0))
        }
    }
}

struct PaletteView: View {
    @Binding var selectedColor: UInt
    var body: some View {
        HStack(spacing: 24) {
            VStack(spacing: 24) {
                ColorButton(hex: 0xFF0000, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0xFFB100, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0xFFE600, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0x39DD00, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0x00AEEF, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0x0036FF, selectedColor: $selectedColor) { selectedColor = $0 }
            }
            
            VStack(spacing: 24) {
                ColorButton(hex: 0xFF7700, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0xFFD200, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0xE4FF43, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0x00FF93, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0x7A00FF, selectedColor: $selectedColor) { selectedColor = $0 }
                ColorButton(hex: 0xFFFFFF, selectedColor: $selectedColor) { selectedColor = $0 }
            }
        }
        .padding(36)
        .background(Color(uiColor: .systemBackground))
        .frame(width: 340)
    }
}

struct ColorButton: View {
    let hex: UInt
    @Binding var selectedColor: UInt
    
    let action: (UInt) -> Void
    var body: some View {
        Button {
            action(hex)
        } label: {
            Color(uiColor: UIColor(hex: hex))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white, lineWidth: 10)
                )
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
                .overlay {
                    if selectedColor == hex {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.5), lineWidth: 2)
                            )
                            .padding(24)
                    }
                }
        }
    }
}

struct CanvasView: UIViewRepresentable {
    @ObservedObject var model: DrawingViewModel
    @Binding var canvasView: PKCanvasView
    @Binding var selectedColor: UInt
    let onSaved: () -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: UIColor(hex: 0x00AEEF), width: 10)
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        
        model.colorChanged = {
            if selectedColor == 0xFFFFFF {
                /// eraser
                canvasView.tool = PKInkingTool(.pen, color: UIColor(hex: selectedColor), width: 30)
            } else {
                canvasView.tool = PKInkingTool(.pen, color: UIColor(hex: selectedColor), width: 10)
            }
        }
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(canvasView: $canvasView, model: model, onSaved: onSaved)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var canvasView: PKCanvasView
        var model: DrawingViewModel
        let onSaved: () -> Void
        
        // MARK: - Initializers

        init(canvasView: Binding<PKCanvasView>, model: DrawingViewModel, onSaved: @escaping () -> Void) {
            self._canvasView = canvasView
            self.model = model
            self.onSaved = onSaved
        }

        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            model.isDrawing = true
        }

        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            model.isDrawing = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                var strokes = canvasView.drawing.strokes + self.model.receivedStrokes
                strokes = strokes.uniqued()
                canvasView.drawing.strokes = strokes
                
                if !canvasView.drawing.bounds.isEmpty {
                    self.onSaved()
                }
            }
        }
    }
}
