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
    
    init() {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    }
    
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
                self.dispatcher.dispatch(.signIn(usecase: .stopSigningIn(from: .basic(scene: .ユーザはキャンセルボタンを押下する))))
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
                            self.dispatcher.dispatch(.application(usecase: .closeDialog(from: .basic(scene: .ユーザはOKボタンを押下する))))
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
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    print("★★ applicationDidBecomeActive")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    print("★★ willResignActiveNotification")
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("★ didFinishLaunchingWithOptions")
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("★ applicationWillResignActive")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("★ applicationDidBecomeActive")
    }
}
