//
//  SplashViewStore.swift
//  CALearning
//  
//  Created by e86_s-anzai on 2022/04/20
//

import Foundation
import SwiftUI

class SplashViewStore: ObservableObject {
    static let shared = SplashViewStore()
    @Published var currentView: Views = .splash
    
    /// シングルトンにする
    private init() {}

    func onDispatch(_ action: Boot) {
        switch action {
        case .goal(scene: .チュートリアル完了の記録がある場合_アプリはログイン画面を表示):
            currentView = .login
        case .goal(scene: .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示):
            currentView = .tutorial
        case .basic:
            break
        }
    }
}
