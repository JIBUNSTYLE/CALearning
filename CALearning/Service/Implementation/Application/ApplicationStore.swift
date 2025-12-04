//
//  ApplicationStore.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/03/20.
//

import Foundation
import RobustiveSwift

class ApplicationState : ObservableObject {}

struct ApplicationStore : Store {
    typealias Usecases = R.Application
    typealias State = ApplicationState
    
    private let service: FrontendService
    
    let state = State()
    
    init(with service: FrontendService) {
        self.service = service
    }
               
    func dispatch(_ usecase: Usecases, with actor: UserActor) {
        switch usecase {
        case let .booting(from: initialScene):
            self.boot(from: initialScene, with: actor)
            
        case let .closeDialog(from: initialScene):
            self.closeDialog(from: initialScene, with: actor)
        }
    }
}

// MARK: - Behaviors

extension ApplicationStore {
    
    func boot(from initialScene: Scene<Usecases.Booting>, with actor: UserActor) {
        
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
        initialScene
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.service.commonCompletionProcess(with: $0)
                }
            ) { (goal, scenario) in
                switch goal {
                case let .チュートリアル完了の記録がある場合_アプリはログイン画面を表示(udid):
                    self.service.change(actor: actor.update(udid: udid))
                    self.service.routing(to: .signIn)

                case let .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示(udid):
                    self.service.change(actor: actor.update(udid: udid))
                    self.service.routing(to: .tutorial)

                case let .UDIDの発行に失敗した場合_アプリはリトライダイアログを表示する(error):
                    self.service.alertContent = AlertContent(title: "システムエラー", message: "UDIDの発行に失敗しました")
                    // TODO: リトライ
                    // TODO: システムエラーと文言をenum化
                    self.service.set(isAlertPresented: true)
                }
            }
            .store(in: &self.service.cancellables)
    }
    
    func closeDialog(from initialScene: Scene<Usecases.CloseDialog>, with actor: UserActor) {
        initialScene
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.service.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                if case .アプリはダイアログを閉じる = goal {
                    self.service.set(isAlertPresented: false)
                }
            }
            .store(in: &self.service.cancellables)
    }
}
