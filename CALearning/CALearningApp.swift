//
//  CALearningApp.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

let IS_TEST = ProcessInfo.processInfo.environment["IS_TEST"] == "true"

@main
struct CALearningApp: App {
    
    @StateObject var performer = Performer()
    
    var body: some Scene {
        WindowGroup {
            if !IS_TEST {
                ContentView()
                    .environmentObject(performer)
            } else {
                Text("Testing...")
            }
        }
    }
}
