//
//  Dispatcher.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine
import RobustiveSwift

struct AlertContent {
    let title: String
    let message: String
}

class Dispatcher : ObservableObject {
    // ViewからはReadonlyとして扱う
    @Published private(set) var currentView: Views = .splash
    @Published private(set) var isAlertPresented = false
    @Published private(set) var isSignInModalPresented = false

    // 二度押し防止でボタンなどを制御するため、ユースケース実行状態を管理
    private(set) var usecaseStatus: UsecaseStatus = .idle
    
    var alertContent = AlertContent(title: "お知らせ", message: "ほげほげ")
    
    private(set) var actor: UserActor = UserActor(udid: nil, user: nil, usecaseToResume: nil)
    
    var cancellables = [AnyCancellable]()
    
    private var _application: ApplicationPerformer?
    private var _signIn: SignInPerformer?
    private var _shopping: ShoppingPerformer?

    private var applicationPerformer: ApplicationPerformer {
        if let performer = self._application {
            return performer
        } else {
            let performer = ApplicationPerformer(with: self)
            self._application = performer
            return performer
        }
    }
    
    private var signInPerformer: SignInPerformer {
        if let performer = self._signIn {
            return performer
        } else {
            let performer = SignInPerformer(with: self)
            self._signIn = performer
            return performer
        }
    }
    
    private var shoppingPerformer: ShoppingPerformer {
        if let performer = self._shopping {
            return performer
        } else {
            let performer = ShoppingPerformer(with: self)
            self._shopping = performer
            return performer
        }
    }
    
    var signInStore: SignInStore {
        self.signInPerformer.store
    }
    
    var shoppingStore: ShoppingStore {
        self.shoppingPerformer.store
    }
}

// MARK: - setter
extension Dispatcher {
    
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
    
    func set(isAlertPresented: Bool) {
        self.isAlertPresented = isAlertPresented
    }
    
    func set(isSignInModalPresented: Bool) {
        self.isSignInModalPresented = isSignInModalPresented
    }
}
    
// MARK: - usecase dispatcher
extension Dispatcher {
    
    func commonCompletionProcess<T>(with completion: Subscribers.Completion<T>, for behavior: String? = #function) {
        self.resetUsecaseState()
    }
    
    func dispatch(_ usecase: Usecases, file: String = #file, line: Int = #line, function: String = #function) -> Void {
        self.usecaseStatus = .executing(usecase: usecase, file: file, line: line, function: function, startAt: Date())

        switch usecase {
        case let .booting(from: initialScene):
            self.applicationPerformer.boot(from: initialScene, with: self.actor)

        case let .completeTutorial(from: initialScene):
            self.signInPerformer.completeTutorial(from:initialScene, with: self.actor)
            
        case let .signingIn(from: initialScene):
            self.signInPerformer.signIn(from: initialScene, with: self.actor)
            
        case let .stopSigningIn(from: initialScene):
            self.signInPerformer.stopSigningIn(from: initialScene, with: self.actor)
            
        case let .trialUsing(from: initialScene):
            self.signInPerformer.trial(from: initialScene, with: self.actor)
            
        case let .purchase(from: initialScene):
            self.shoppingPerformer.purchase(from: initialScene, with: self.actor)
            
        case let .closeDialog(from: initialScene):
            self.applicationPerformer.closeDialog(from: initialScene, with: self.actor)
        }
    }
    
    func dispatchMainAsync(_ usecase: Usecases, file: String = #file, line: Int = #line, function: String = #function) -> Void {
        DispatchQueue.main.async {
            self.dispatch(usecase, file: file, line: line, function: function)
        }
    }
}
