//
//  LoginStore.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/04/06.
//

import Foundation
import Combine

class LoginStore: ObservableObject {
    private let controller: Controller
    
    private var cancellables = [AnyCancellable]()
    
    init(with controller: Controller) {
        self.controller = controller
    }
}

extension LoginStore {
    
    func login(_ from: Usecases.LoggingIn) {
        from
            .interacted(by: self.controller.actor)
            .sink { completion in
                self.controller.resetUsecaseState()
                if case .finished = completion {
                    print("\(#function) は正常終了")
                } else if case .failure(let error) = completion {
                    print("\(#function) が異常終了: \(error)")
                }
            } receiveValue: { scenario in
                print("usecase - \(#function): \(scenario)")
                
                guard case .last(let goal) = scenario.last else { fatalError() }
                
                switch goal {
                case let .ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error):
                    self.controller.isAlertPresented = true

                case let .ログイン認証に成功した場合_アプリはホーム画面を表示する(user):
                    self.controller.routing(to: .home)

                case let .入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(result):
                    self.controller.isAlertPresented = true
                    
                case .予期せぬエラーが発生した場合_アプリはログイン画面にエラー内容を表示する(error: let error):
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
}
