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
    
    // 二度押し防止でボタンなどを制御するため、ユースケース実行状態を管理
    private(set) var usecaseStatus: UsecaseStatus = .idle
    
    var alertContent = AlertContent(title: "お知らせ", message: "ほげほげ")
    
    private(set) var udid: String?
    private(set) var actor: UserActor = UserActor()
    
    
    private var _login: LoginStore?
    
    var loginStore: LoginStore {
        if let p = self._login {
            return p
            
        } else {
            let p = LoginStore(with: self)
            self._login = p
            return p
        }
    }
    
    private var cancellables = [AnyCancellable]()
    
}

// MARK: - setter
extension Controller {
    
    func routing(to view: Views) {
        DispatchQueue.main.async {
            self.currentView = view
        }
    }
    
    func changeActor(to actor: UserActor) {
        self.actor = actor
    }
    
    func resetUsecaseState() {
        self.usecaseStatus = .idle
    }
}
    
// MARK: - usecase dispatcher
extension Controller {
    
    func dispatch(_ from: Usecases) {
        self.usecaseStatus = .executing(usecase: from)

        switch from {
        case let .booting(from):
            self.boot(from)

        case let .completeTutorial(from):
            self.completeTutorial(from)
            
        case let .loggingIn(from):
            self.loginStore.login(from)

        default:
            fatalError("未実装")
        }
    }
    
    
    private func boot(_ from: Usecases.Booting) {
        
//        let apiClient = MockApiClient<Apis.Udid>(
//            stub: .success(entity: Apis.Udid.Entity(udid: "hoge"))
//            , afterCall: { result in
//                print("● afterCall: \(result)")
//            })

//        let apiClient = MockApiClient<Apis.Udid>(
//            stub: .failure(by: ErrorWrapper<Apis.Udid>.service(error: .client(.ネットワーク接続不可), args: Apis.Udid(), causedBy: nil))
//            , afterCall: { result in
//                print("● afterCall: \(result)")
//            })
//        let backend = ApiBackend(apiClient: apiClient)
//        Dependencies.shared.set(backend: backend)
//
//        Application().discardUdid()
//
        from
            .interacted(by: self.actor)
            .sink { completion in
                self.resetUsecaseState()
                
                if case .finished = completion {
                    print("\(#function) は正常終了")
                } else if case let .failure(error) = completion {
                    print("\(#function) が異常終了: \(error)")
                }
            } receiveValue: { scenario in
                print("usecase - \(#function): \(scenario)")
                
                guard case .last(let goal) = scenario.last else { fatalError() }
                    
                switch goal {
                case let .チュートリアル完了の記録がある場合_アプリはログイン画面を表示(udid):
                    self.udid = udid
                    self.routing(to: .login)

                case let .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示(udid):
                    self.udid = udid
                    self.routing(to: .tutorial)

                case let .UDIDの発行に失敗した場合_アプリはリトライダイアログを表示する(error):
                    self.alertContent = AlertContent(title: "システムエラー", message: "UDIDの発行に失敗しました")
                    // TODO: リトライ
                    // TODO: システムエラーと文言をenum化
                    self.isAlertPresented = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func completeTutorial(_ from: Usecases.CompleteTutorial) {
        from
            .interacted(by: self.actor)
            .sink { completion in
                self.resetUsecaseState()
                
                if case .finished = completion {
                    print("\(#function) は正常終了")
                } else if case .failure(let error) = completion {
                    print("\(#function) が異常終了: \(error)")
                }
            } receiveValue: { scenario in
                print("usecase - \(#function): \(scenario)")
                
                guard case .last(let goal) = scenario.last else { fatalError() }
                
                if case .アプリはログイン画面を表示する = goal {
                    self.routing(to: .login)
                }
                
            }.store(in: &cancellables)
    }
}
