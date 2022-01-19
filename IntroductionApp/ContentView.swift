//
//  ContentView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

let admin = UIDevice.current.name == "iPad Pro"

class GlobalViewModel: ObservableObject {
    @Published var drawingImage: UIImage?
}
struct ContentView: View {
    @StateObject var globalViewModel = GlobalViewModel()
    @State var index = 0
    
    var body: some View {
        if admin {
            ZStack {
                DrawingView(index: $index, globalViewModel: globalViewModel)
                    .opacity(index == 1 ? 1 : 0)
                
                switch index {
                case 0:
                    IntroView(index: $index)
                case 2:
                    FaceView(index: $index, globalViewModel: globalViewModel)
                default:
                    Color.clear
                }
            }
        } else {
            DrawingView(index: $index, globalViewModel: globalViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
