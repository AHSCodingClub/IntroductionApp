//
//  WrapUpView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

struct WrapUpView: View {
    @Binding var index: Int
    @State var secondaryIndex = 0
    
    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 16) {
                Image("Logo")
                    .resizable()
                    .frame(width: 36, height: 26)
                
                Text("Coding Club Semester 2")
                    .font(.system(size: 36, weight: .medium))
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text("Meeting 1 • Wednesday, January 19, 2022")
                    .font(.system(size: 20, weight: .bold))
                
                Text("Intro to App Development")
                    .font(.system(size: 40, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            VStack {
                VStack {
                    switch secondaryIndex {
                    case 0:
                        VStack {
                            Text("Wrap-up")
                                .font(.system(size: 60, weight: .bold))
                            
                            PointView(text: "All of that was made with Swift.")
                            
                            PointView(text: "We'll start coding next meeting.")
                            
                            PointView(text: "To get a head start, visit [swift.getfind.app](https://swift.getfind.app/)")
                                .tint(Color.white)
                        }
                    case 1:
                        VStack {
                            Text("Contact")
                                .font(.system(size: 60, weight: .bold))
                            
                            Text("Join the Discord!")
                                .font(.system(size: 40, weight: .bold))
                            
                            Text("getfind.app/d")
                                .font(.system(size: 100, weight: .bold))
                        }
                    case 2:
                        VStack {
                            Text("Goals")
                                .font(.system(size: 60, weight: .bold))
                            
                            PointView(text: "Learn Swift and basic app dev")
                            
                            PointView(text: "Launch an app to the App Store")
                            
                            PointView(text: "Enter the Swift Student Challenge")
                        }
                    case 3:
                        VStack {
                            Text("Have a good day!")
                                .font(.system(size: 80, weight: .bold))
                        }
                    default:
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(36)
                .background(Color.white.opacity(0.25))
                .cornerRadius(24)
                
                HStack {
                    Button {
                        if secondaryIndex >= 1 {
                            secondaryIndex -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(Color.black.opacity(0.25))
                            .cornerRadius(32)
                    }
                    
                    Button {
                        if secondaryIndex <= 2 {
                            secondaryIndex += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(Color.black.opacity(0.25))
                            .cornerRadius(32)
                    }
                }
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(100)
        .background(
            LinearGradient(
                colors: [
                    Color(uiColor: UIColor(hex: 0x00aeef)),
                    Color.green
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(64)
        .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 3)
        .padding(64)
        .overlay(alignment: .topLeading) {
            BubbleTopBarView(index: $index, showRight: false)
        }
    }
}

struct PointView: View {
    let text: LocalizedStringKey
    var body: some View {
        HStack {
            Circle()
                .frame(width: 10, height: 10)
            
            Text(text)
                .font(.system(size: 42, weight: .medium))
        }
    }
}
