//
//  ContentView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

let admin = UIDevice.current.name == "iPad Pro"

struct ContentView: View {
    @State var index = 0
    var body: some View {
        if admin {
            switch index {
            case 0:
                IntroView(index: $index)
            case 1:
                DrawingView()
            default:
                Color.clear
            }
        } else {
            DrawingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
