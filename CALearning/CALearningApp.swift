//
//  CALearningApp.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

@main
struct CALearningApp: App {
    
    @StateObject var controller = Controller()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
                .alert(
                    self.controller.alertContent.title
                    , isPresented: self.$controller.isAlertPresented
                    , actions: {
                        Button("OK") {
                        }
                    }
                    , message: {
                        Text(self.controller.alertContent.message)
                    }
                )
                .sheet(isPresented: self.$controller.isLoginModalPresented, onDismiss: {}) {
                    Login(loginBehavior: self.controller.loginBehavior)
                        .environmentObject(controller)
                }
        }
    }
}
