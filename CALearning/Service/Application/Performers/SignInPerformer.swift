//
//  SignInPerformer.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/04/06.
//

import Foundation
import RobustiveSwift

class SignInStore : ObservableObject {
    @Published fileprivate(set) var signInValidationResult: SignInValidationResult?
}

struct SignInPerformer: Performer {
    typealias Store = SignInStore
    
    private let dispatcher: Dispatcher
    
    let store = Store()
    
    init(with dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
    }
}

// MARK: - Behaviors

extension SignInPerformer {
    
    func signIn(_ from: Usecase<Usecases.SigningIn>, with actor: UserActor) {
        from
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.dispatcher.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                switch goal {
                case let .ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error):
                    self.dispatcher.set(isAlertPresented: true)

                case let .ログイン認証に成功した場合_アプリはホーム画面を表示する(user):
                    let usecaseToResume = actor.usecaseToResume
                    self.dispatcher.change(actor: actor.update(user: user))
                    self.dispatcher.routing(to: .home)
                    self.dispatcher.set(isSignInModalPresented: false)
                    
                    guard let usecase = usecaseToResume else { return }
                    // receiveValueのクロージャが終わってからreceiveCompletionが呼ばれるため
                    // ここでdispatchするとreceiveCompletionでresetUsecaseStateが走り、
                    // resumeしたユースケースの実行時間が測れないためmainスレッドから実行している
                    self.dispatcher.dispatchMainAsync(usecase)

                case let .入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(result):
                    self.store.signInValidationResult = result
                    self.dispatcher.set(isAlertPresented: true)
                    
                case .予期せぬエラーが発生した場合_アプリはログイン画面にエラー内容を表示する(error: let error):
                    print(error)
                }
            }
            .store(in: &self.dispatcher.cancellables)
    }
    
    func stopSigningIn(_ from: Usecase<Usecases.StopSigningIn>, with actor: UserActor) {
        from
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.dispatcher.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                if case .アプリはログインモーダルを閉じる = goal {
                    self.store.signInValidationResult = nil
                    self.dispatcher.set(isSignInModalPresented: false)
                }
            }
            .store(in: &self.dispatcher.cancellables)
    }
 
    func trial(_ from: Usecase<Usecases.TrialUsing>, with actor: UserActor) {
        self.store.signInValidationResult = nil
        from
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.dispatcher.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                if case .アプリはホーム画面を表示する = goal {
                    self.dispatcher.routing(to: .home)
                }
            }
            .store(in: &self.dispatcher.cancellables)
    }
    
    func completeTutorial(_ from: Usecase<Usecases.CompleteTutorial>, with actor: UserActor) {
        from
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.dispatcher.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                if case .アプリはログイン画面を表示する = goal {
                    self.dispatcher.routing(to: .signIn)
                }
                
            }
            .store(in: &self.dispatcher.cancellables)
    }
}
