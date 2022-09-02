//
//  Presenter.swift
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

class Presenter: ObservableObject {
    // ViewからはReadonlyとして扱う
    @Published private(set) var currentView: Views = .splash
    @Published var isAlertPresented = false
    
    var alertContent = AlertContent(title: "お知らせ", message: "ほげほげ")
    
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
extension Presenter {
    
    func routing(to view: Views) {
        DispatchQueue.main.async {
            self.currentView = view
        }
    }
    
    func changeActor(to actor: UserActor) {
        self.actor = actor
    }
}
    
// MARK: - usecase dispatcher
extension Presenter {
    
    func dispatch<T: Usecase>(_ initialScene: T) {
        switch initialScene {
        case let scene as Booting:
            self.boot(from: scene)

        case let scene as CompleteTutorial:
            self.completeTutorial(from: scene)
            
        case let scene as Loggingin:
            self.loginStore.login(from: scene)

        default:
            fatalError("未実装")
        }
    }
    
    
    func boot(from: Booting) {
        
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
                if case .finished = completion {
                    print("boot は正常終了")
                } else if case .failure(let error) = completion {
                    switch error {
                    case let ErrorWrapper.service(error, args, causedBy):
                        print("サービスエラー発生:\(error), args:\(String(describing: args)), causedBy: \(String(describing: causedBy))")
                    case let ErrorWrapper.system(error, args, causedBy):
                        print("サービスエラー発生:\(error), args:\(String(describing: args)), causedBy: \(String(describing: causedBy))")
                    default:
                        print("boot が異常終了: \(error)")
                    }
                }
            } receiveValue: { scenario in
                print("usecase - boot: \(scenario)")
                
                guard case .last(let goal) = scenario.last else { fatalError() }
                    
                switch goal {
                case .チュートリアル完了の記録がある場合_アプリはログイン画面を表示:
                    self.routing(to: .login)
                case .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示:
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
    
    func completeTutorial(from: CompleteTutorial) {
        from
            .interacted(by: self.actor)
            .sink { completion in
                if case .finished = completion {
                    print("completeTutorial は正常終了")
                } else if case .failure(let error) = completion {
                    print("completeTutorial が異常終了: \(error)")
                }
            } receiveValue: { scenario in
                print("usecase - completeTutorial: \(scenario)")
                
                guard case .last(let goal) = scenario.last else { fatalError() }
                
                if case .アプリはログイン画面を表示する = goal {
                    self.routing(to: .login)
                }
                
            }.store(in: &cancellables)
    }
}
