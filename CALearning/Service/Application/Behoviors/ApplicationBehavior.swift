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
    
    func boot(_ from: Usecases.Booting, with actor: UserActor) {
        
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
            .interacted(by: actor)
            .sink { completion in
                self.controller.resetUsecaseState()
                
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
                    self.controller.change(actor: actor.update(udid: udid))
                    self.controller.routing(to: .login)

                case let .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示(udid):
                    self.controller.change(actor: actor.update(udid: udid))
                    self.controller.routing(to: .tutorial)

                case let .UDIDの発行に失敗した場合_アプリはリトライダイアログを表示する(error):
                    self.controller.alertContent = AlertContent(title: "システムエラー", message: "UDIDの発行に失敗しました")
                    // TODO: リトライ
                    // TODO: システムエラーと文言をenum化
                    self.controller.isAlertPresented = true
                }
            }
            .store(in: &cancellables)
    }
}
