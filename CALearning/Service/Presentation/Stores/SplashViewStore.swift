//
//  SplashViewStore.swift
//  CALearning
//  
//  Created by e86_s-anzai on 2022/04/20
//

import Foundation
import SwiftUI

class SplashViewStore: Store {
    static let shared = SplashViewStore(dispatcher: .shared)
    @Published var currentView: Views = .splash
    
    /// シングルトンにする
    private override init(dispatcher: Dispatcher) {
        super.init(dispatcher: dispatcher)
    }

    override func onDispatch(_ action: Action) {
        switch action {
        case .boot(let currentView):
            self.currentView = currentView
        }
    }
}
