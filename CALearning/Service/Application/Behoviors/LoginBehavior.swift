//
//  LoginBehavior.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/04/06.
//

import Foundation
import Combine

class LoginBehavior: ObservableObject {
    private let controller: Controller
    
    @Published var loginValidationResult: LoginValidationResult?
    
    private var cancellables = [AnyCancellable]()
    
    init(with controller: Controller) {
        self.controller = controller
    }
}

extension LoginBehavior {
    
    func login(_ from: Usecases.LoggingIn, with actor: UserActor) {
        from
            .interacted(by: actor)
            .sink {
                self.controller.commonCompletionProcess(with: $0)
            } receiveValue: { scenario in
                guard case let .last(goal) = self.controller.commonReceiveProcess(with: scenario) else { fatalError() }
                
                switch goal {
                case let .ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error):
                    self.controller.set(isAlertPresented: true)

                case let .ログイン認証に成功した場合_アプリはホーム画面を表示する(user):
                    let usecaseToResume = actor.usecaseToResume
                    self.controller.change(actor: actor.update(user: user))
                    self.controller.routing(to: .home)
                    self.controller.set(isLoginModalPresented: false)
                    
                    guard let usecase = usecaseToResume else { return }
                    self.controller.dispatch(usecase)

                case let .入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(result):
                    self.loginValidationResult = result
                    self.controller.set(isAlertPresented: true)
                    
                case .予期せぬエラーが発生した場合_アプリはログイン画面にエラー内容を表示する(error: let error):
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func stopLoggingIn(_ from: Usecases.StopLoggingIn, with actor: UserActor) {
        from
            .interacted(by: actor)
            .sink {
                self.controller.commonCompletionProcess(with: $0)
            } receiveValue: { scenario in
                guard case let .last(goal) = self.controller.commonReceiveProcess(with: scenario) else { fatalError() }
                if case .アプリはログインモーダルを閉じる = goal {
                    self.loginValidationResult = nil
                    self.controller.set(isLoginModalPresented: false)
                }
            }
            .store(in: &cancellables)
    }
 
    func trial(_ from: Usecases.TrialUsing, with actor: UserActor) {
        self.loginValidationResult = nil
        from
            .interacted(by: actor)
            .sink {
                self.controller.commonCompletionProcess(with: $0)
            } receiveValue: { scenario in
                guard case let .last(goal) = self.controller.commonReceiveProcess(with: scenario) else { fatalError() }
                
                if case .アプリはホーム画面を表示する = goal {
                    self.controller.routing(to: .home)
                }
            }
            .store(in: &cancellables)
    }
    
    func completeTutorial(_ from: Usecases.CompleteTutorial, with actor: UserActor) {
        from
            .interacted(by: actor)
            .sink {
                self.controller.commonCompletionProcess(with: $0)
            } receiveValue: { scenario in
                guard case let .last(goal) = self.controller.commonReceiveProcess(with: scenario) else { fatalError() }
                
                if case .アプリはログイン画面を表示する = goal {
                    self.controller.routing(to: .login)
                }
                
            }.store(in: &cancellables)
    }
}
