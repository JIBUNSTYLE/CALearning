//
//  Dispatcher.swift
//  CALearning
//  
//  Created by e86_s-anzai on 2022/04/20
//

import Foundation

final class Dispatcher{

    static let shared = Dispatcher()
    private init() {}

    /// ユースケース【アプリを起動する】用のDispatch
    func dispatch(_ action: Boot) {
        SplashViewStore.shared.onDispatch(action)
    }
}
