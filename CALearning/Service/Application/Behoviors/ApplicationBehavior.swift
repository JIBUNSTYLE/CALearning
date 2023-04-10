//
//  ApplicationBehavior.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/03/20.
//

import Foundation
import Combine
import RobustiveSwift

class ApplicationBehavior : ObservableObject {
    private let controller: Controller
    
    private var cancellables = [AnyCancellable]()
    
    init(with controller: Controller) {
        self.controller = controller
    }
}

extension ApplicationBehavior {
    
    func boot(_ from: Usecase<Usecases.Booting>, with actor: UserActor) {
        
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
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.controller.commonCompletionProcess(with: $0)
                }
            ) { (goal, scenario) in
                switch goal {
                case let .チュートリアル完了の記録がある場合_アプリはログイン画面を表示(udid):
                    self.controller.change(actor: actor.update(udid: udid))
                    self.controller.routing(to: .login)

                case let .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示(udid):
                    self.controller.change(actor: actor.update(udid: udid))
                    self.controller.routing(to: .tutorial)

                case let .UDIDの発行に失敗した場合_アプリはリトライダイアログを表示する(error):
                    self.controller.alertContent = AlertContent(title: "システムエラー", message: "UDIDの発行に失敗しました")
                    // TODO: リトライ
                    // TODO: システムエラーと文言をenum化
                    self.controller.set(isAlertPresented: true)
                }
            }
            .store(in: &cancellables)
    }
    
    func closeDialog(_ from: Usecase<Usecases.CloseDialog>, with actor: UserActor) {
        from
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.controller.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                if case .アプリはダイアログを閉じる = goal {
                    self.controller.set(isAlertPresented: false)
                }
            }
            .store(in: &cancellables)
    }
}
