//
//  ContentView.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 14/03/2021.
//

import SwiftUI


struct ContentView: View {
    @State private var isPresented: Bool = false
    @State private var done: Bool = false
    @State private var displayName: String = ""
    @State private var bitmojiAvatar: UIImage = UIImage()
    var body: some View {
        Image(uiImage: bitmojiAvatar)
            .padding(10)
        Text(displayName)
            .fontWeight(.heavy)
            .multilineTextAlignment(.center)
            .padding(10)
            .font(.largeTitle)
        Button("Snapchat Login Button") {
            self.isPresented = true
        }.disabled(done).opacity(done ? 0 : 1)
        .sheet(isPresented: $isPresented) {
            LoginCVWrapper(displayName: $displayName, isPresented: $isPresented, bitmojiAvatar: $bitmojiAvatar, done: $done)
        }
    }
}
