//
//  ContentView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

struct ContentView: View {
    @State var index = 0
    var body: some View {
        switch index {
        case 0:
            IntroView(index: $index)
        default:
            Color.clear
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
