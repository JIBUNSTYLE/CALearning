//
//  CALearningApp.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

@main
struct CALearningApp: App {
    
    @StateObject var presenter = Presenter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presenter)
                .alert(
                    self.presenter.alertContent.title
                    , isPresented: self.$presenter.isAlertPresented
                    , actions: {
                        Button("OK") {
                        }
                    }
                    , message: {
                        Text(self.presenter.alertContent.message)
                    }
                )
        }
    }
}
