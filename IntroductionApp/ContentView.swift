//
//  ContentView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class GlobalViewModel: ObservableObject {
    @Published var drawingImage: UIImage?
    var updateImage: (() -> Void)?
}

struct ContentView: View {
    @AppStorage("isAdmin") var admin = false
    @StateObject var globalViewModel = GlobalViewModel()
    @State var index = 0

    var body: some View {
        if admin {
            ZStack {
                DrawingView(admin: $admin, index: $index, globalViewModel: globalViewModel)
                    .opacity(index == 2 ? 1 : 0)

                switch index {
                case 0:
                    IntroView(admin: $admin, index: $index)
                case 1:
                    SwiftView(index: $index)
                case 3:
                    FaceView(admin: admin, index: $index, globalViewModel: globalViewModel)
                case 4:
                    BubbleView(admin: admin, index: $index, globalViewModel: globalViewModel)
                case 5:
                    WrapUpView(index: $index)
                default:
                    Color.clear
                }
            }
        } else {
            DrawingView(admin: $admin, index: $index, globalViewModel: globalViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
