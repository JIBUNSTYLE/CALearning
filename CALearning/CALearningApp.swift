//
//  CALearningApp.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

@main
struct CALearningApp: App {
    @StateObject var dispatcher = Dispatcher()
    
    private var isAlertPresented: Binding<Bool> {
        Binding {
            self.dispatcher.isAlertPresented
        } set: { _ in }
    }
    
    private var isSignInModalPresented: Binding<Bool> {
        Binding( get: {
            self.dispatcher.isSignInModalPresented
        }, set: { newValue in
            guard newValue == false else { return }
            if self.dispatcher.isSignInModalPresented {
                print("スワイプで閉じる")
                self.dispatcher.dispatch(.stopSigningIn(from: .basic(scene: .ユーザはキャンセルボタンを押下する)))
            } else {
                print("ユースケース完了で閉じる")
            }
        })
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dispatcher)
                .alert(
                    self.dispatcher.alertContent.title
                    , isPresented: self.isAlertPresented
                    , actions: {
                        Button("OK") {
                            self.dispatcher.dispatch(.closeDialog(from: .basic(scene: .ユーザはOKボタンを押下する)))
                        }
                    }
                    , message: {
                        Text(self.dispatcher.alertContent.message)
                    }
                )
                .sheet(isPresented: self.isSignInModalPresented) {
                    SignIn(signInStore: self.dispatcher.signInStore)
                        .alert(
                            self.dispatcher.alertContent.title
                            , isPresented: self.isAlertPresented
                            , actions: {
                                Button("OK") {
                                }
                            }
                            , message: {
                                Text(self.dispatcher.alertContent.message)
                            }
                        )
                        .environmentObject(dispatcher)
                }
        }
    }
}
