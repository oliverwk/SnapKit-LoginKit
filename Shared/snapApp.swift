//
//  snapApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 14/03/2021.
//

import SwiftUI
import SCSDKLoginKit

@main
struct snapApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL(perform: { url in
                    if SCSDKLoginClient.application(UIApplication.shared, open: url, options: nil) {
                      
                    }
                })
        }
    }
}
