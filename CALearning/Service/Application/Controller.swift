//
//  Controller.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine

struct AlertContent {
    let title: String
    let message: String
}

class Controller: ObservableObject {
    // ViewからはReadonlyとして扱う
    @Published private(set) var currentView: Views = .splash
    @Published var isAlertPresented = false
    @Published var isLoginModalPresented = false
    
    // 二度押し防止でボタンなどを制御するため、ユースケース実行状態を管理
    private(set) var usecaseStatus: UsecaseStatus = .idle
    
    var alertContent = AlertContent(title: "お知らせ", message: "ほげほげ")
    
    private(set) var actor: UserActor = UserActor(udid: nil, user: nil, usecaseToResume: nil)
    
    private var _application: ApplicationBehavior?
    private var _login: LoginBehavior?
    private var _shopping: ShoppingBehavior?

    var applicationBehavior: ApplicationBehavior {
        if let b = self._application {
            return b
        } else {
            let b = ApplicationBehavior(with: self)
            self._application = b
            return b
        }
    }
    
    var loginBehavior: LoginBehavior {
        if let b = self._login {
            return b
        } else {
            let b = LoginBehavior(with: self)
            self._login = b
            return b
        }
    }
    
    var shoppingBehavior: ShoppingBehavior {
        if let b = self._shopping {
            return b
        } else {
            let b = ShoppingBehavior(with: self)
            self._shopping = b
            return b
        }
    }
}

// MARK: - setter
extension Controller {
    
    func routing(to view: Views) {
        DispatchQueue.main.async {
            self.currentView = view
        }
    }
    
    func change(actor: UserActor) {
        self.actor = actor
    }
    
    func resetUsecaseState(_ msg: String? = nil, file: String = #file, line: Int = #line, function: String = #function) {
        self.usecaseStatus.printElapsedTime(msg, efile: file, eline: line, efunction: function)
        self.usecaseStatus = .idle
    }
}
    
// MARK: - usecase dispatcher
extension Controller {
    
    func dispatch(_ from: Usecases, file: String = #file, line: Int = #line, function: String = #function) {
        self.usecaseStatus = .executing(usecase: from, file: file, line: line, function: function, startAt: Date())

        switch from {
        case let .booting(from):
            self.applicationBehavior.boot(from, with: self.actor)

        case let .completeTutorial(from):
            self.loginBehavior.completeTutorial(from, with: self.actor)
            
        case let .loggingIn(from):
            self.loginBehavior.login(from, with: self.actor)
            
        case let .trialUsing(from):
            self.loginBehavior.trial(from, with: self.actor)
            
        case let .purchase(from):
            self.shoppingBehavior.purchase(from, with: self.actor)
        }
        
    
        
    }
}
