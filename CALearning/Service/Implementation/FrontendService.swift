//
//  FrontendService.swift
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

class FrontendService : ObservableObject {
    // ViewからはReadonlyとして扱う
    @Published private(set) var currentView: Views = .splash
    @Published private(set) var isAlertPresented = false
    @Published private(set) var isSignInModalPresented = false

    // 二度押し防止でボタンなどを制御するため、ユースケース実行状態を管理
    private(set) var usecaseStatus: UsecaseStatuses = .idle
    
    var alertContent = AlertContent(title: "お知らせ", message: "ほげほげ")
    
    private(set) var actor: UserActor = UserActor(udid: nil, user: nil, usecaseToResume: nil)
    
    var cancellables = [AnyCancellable]()
    
    private var _application: ApplicationStore?
    private var _signIn: SignInStore?
    private var _shopping: ShoppingStore?

    private var applicationStore: ApplicationStore {
        if let store = self._application {
            return store
        } else {
            let store = ApplicationStore(with: self)
            self._application = store
            return store
        }
    }
    
    private var signInStore: SignInStore {
        if let store = self._signIn {
            return store
        } else {
            let store = SignInStore(with: self)
            self._signIn = store
            return store
        }
    }
    
    private var shoppingStore: ShoppingStore {
        if let store = self._shopping {
            return store
        } else {
            let store = ShoppingStore(with: self)
            self._shopping = store
            return store
        }
    }
    
    var signInState: SignInState {
        self.signInStore.state
    }
    
    var shoppingState: ShoppingState {
        self.shoppingStore.state
    }
    
    private var stores: [any Store] = []
    
    func add<T>(store: T) where T : Store {
        self.stores.append(store)
    }
}

// MARK: - setter
extension FrontendService {
    
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
    
// MARK: - usecase FrontendService
extension FrontendService {
    
    func commonCompletionProcess<T>(with completion: Subscribers.Completion<T>, for behavior: String? = #function) {
        self.resetUsecaseState()
    }
    
    func dispatch(_ usecase: Requirements, file: String = #file, line: Int = #line, function: String = #function) -> Void {
        
        self.usecaseStatus = .executing(usecase: usecase, file: file, line: line, function: function, startAt: Date())
        
        switch usecase {
        case let .application(usecase):
            self.applicationStore.dispatch(usecase, with: self.actor)
            
        case let .signIn(usecase):
            self.signInStore.dispatch(usecase, with: self.actor)
            
        case let .shopping(usecase):
            self.shoppingStore.dispatch(usecase, with: self.actor)
        }
    }
    
    func dispatchMainAsync(_ usecase: Requirements, file: String = #file, line: Int = #line, function: String = #function) -> Void {
        DispatchQueue.main.async {
            self.dispatch(usecase, file: file, line: line, function: function)
        }
    }
}
