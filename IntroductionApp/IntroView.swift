//
//  IntroView.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

struct IntroView: View {
    @Binding var admin: Bool
    @Binding var index: Int
    @State var showingSheet = false
    @State var adminPass = ""
    
    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 16) {
                Image("Logo")
                    .resizable()
                    .frame(width: 66, height: 66)
                
                Text("Coding Club Semester 2")
                    .font(.system(size: 60, weight: .medium))
                
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Meeting 1 • Wednesday, January 19, 2022")
                    .font(.system(size: 40, weight: .bold))
                
                Text("Intro to App Development")
                    .font(.system(size: 80, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            if admin {
                Button {
                    withAnimation {
                        index += 1
                    }
                } label: {
                    Text("Start")
                        .foregroundColor(.white)
                        .font(.system(size: 80, weight: .bold))
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                        .background(.white.opacity(0.25))
                        .cornerRadius(32)
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
        .overlay(alignment: .bottomTrailing) {
            Button {
                showingSheet = true
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(32)
                    .padding()
            }
        }
        .sheet(isPresented: $showingSheet) {
            TextField("Enter key to start", text: $adminPass)
        }
        .onChange(of: adminPass) { newValue in
            if adminPass.lowercased() == "admin" {
                admin = true
                showingSheet = false
            }
        }
    }
}
