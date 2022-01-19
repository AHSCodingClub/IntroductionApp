//
//  DrawingView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import PencilKit
import SwiftUI

class DrawingViewModel: ObservableObject {
    var colorChanged: (() -> Void)?
}

struct DrawingView: View {
    @StateObject var model = DrawingViewModel()
    @State var canvasView = PKCanvasView()
    @State var selectedColor: UInt = 0x00AEEF
    
    var body: some View {
        HStack(spacing: 24) {
            Group {
                CanvasView(model: model, canvasView: $canvasView, selectedColor: $selectedColor) {
                    print("s: \(canvasView.drawing.strokes)")
                }
                .overlay {
                    Image("PersonOutline")
                        .resizable()
                        .opacity(0.5)
                        .allowsHitTesting(false)
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
        Coordinator(canvasView: $canvasView, onSaved: onSaved)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var canvasView: Binding<PKCanvasView>
        let onSaved: () -> Void
        
        // MARK: - Initializers

        init(canvasView: Binding<PKCanvasView>, onSaved: @escaping () -> Void) {
            self.canvasView = canvasView
            self.onSaved = onSaved
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if !canvasView.drawing.bounds.isEmpty {
                onSaved()
            }
        }
    }
}
