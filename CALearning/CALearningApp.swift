//
//  CALearningApp.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

@main
struct CALearningApp: App {
    
    @StateObject var sharedPresenter = SharedPresenter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sharedPresenter)
        }
    }
}
