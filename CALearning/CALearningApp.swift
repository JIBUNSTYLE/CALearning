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
    
    private var isAlertPresented: Binding<Bool> {
        Binding {
            self.controller.isAlertPresented
        } set: { newValue in
           self.controller.dispatch(.closeDialog(from: .basic(scene: .ユーザはOKボタンを押下する)))
        }
    }
    
    private var isLoginModalPresented: Binding<Bool> {
        Binding {
            self.controller.isLoginModalPresented
        } set: { newValue in
            self.controller.dispatch(.stopLoggingIn(from: .basic(scene: .ユーザはキャンセルボタンを押下する)))
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
                .alert(
                    self.controller.alertContent.title
                    , isPresented: self.isAlertPresented
                    , actions: {
                        Button("OK") {
                        }
                    }
                    , message: {
                        Text(self.controller.alertContent.message)
                    }
                )
                .sheet(isPresented: self.isLoginModalPresented) {
                    Login(loginBehavior: self.controller.loginBehavior)
                        .alert(
                            self.controller.alertContent.title
                            , isPresented: self.isAlertPresented
                            , actions: {
                                Button("OK") {
                                }
                            }
                            , message: {
                                Text(self.controller.alertContent.message)
                            }
                        )
                        .environmentObject(controller)
                }
        }
    }
}
