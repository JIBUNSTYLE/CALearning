//
//  CALearningApp.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

@main
struct CALearningApp: App {
    
    @StateObject var presenter = SplashViewStore.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presenter)
        }
    }
}
