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
    private(set) var usecaseStatus: UsecaseStatuses = .idle
    
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
        case let .application(usecase):
            self.applicationPerformer.dispatch(usecase, with: self.actor)
            
        case let .signIn(usecase):
            self.signInPerformer.dispatch(usecase, with: self.actor)
            
        case let .shopping(usecase):
            self.shoppingPerformer.dispatch(usecase, with: self.actor)
        }
    }
    
    func dispatchMainAsync(_ usecase: Usecases, file: String = #file, line: Int = #line, function: String = #function) -> Void {
        DispatchQueue.main.async {
            self.dispatch(usecase, file: file, line: line, function: function)
        }
    }
}
