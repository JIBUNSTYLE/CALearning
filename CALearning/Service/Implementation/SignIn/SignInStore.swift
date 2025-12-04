//
//  SignInStore.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/04/06.
//

import Foundation
import RobustiveSwift

class SignInState : ObservableObject {
    @Published fileprivate(set) var signInValidationResult: SignInValidationResult?
}

struct SignInStore: Store {
    typealias Usecases = R.SignIn
    typealias State = SignInState
    
    private let service: FrontendService
    
    let state = State()
    
    init(with service: FrontendService) {
        self.service = service
    }
    
    func dispatch(_ usecase: Usecases, with actor: UserActor) {
        switch usecase {
        case let .completeTutorial(from: initialScene):
            self.completeTutorial(from: initialScene, with: actor)
            
        case let .signingIn(from: initialScene):
            self.signIn(from: initialScene, with: actor)
            
        case let .stopSigningIn(from: initialScene):
            self.stopSigningIn(from: initialScene, with: actor)
            
        case let .trialUsing(from: initialScene):
            self.trial(from: initialScene, with: actor)
        }
    }
}

// MARK: - Behaviors

extension SignInStore {
    
    func signIn(from initialScene: Scene<Usecases.SigningIn>, with actor: UserActor) {
        initialScene
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.service.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                switch goal {
                case let .ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error):
                    self.service.set(isAlertPresented: true)

                case let .ログイン認証に成功した場合_アプリはホーム画面を表示する(user):
                    let usecaseToResume = actor.usecaseToResume
                    self.service.change(actor: actor.update(user: user))
                    self.service.routing(to: .home)
                    self.service.set(isSignInModalPresented: false)
                    
                    guard let usecase = usecaseToResume else { return }
                    // receiveValueのクロージャが終わってからreceiveCompletionが呼ばれるため
                    // ここでdispatchするとreceiveCompletionでresetUsecaseStateが走り、
                    // resumeしたユースケースの実行時間が測れないためmainスレッドから実行している
                    self.service.dispatchMainAsync(usecase)

                case let .入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(result):
                    self.state.signInValidationResult = result
                    self.service.set(isAlertPresented: true)
                    
                case .予期せぬエラーが発生した場合_アプリはログイン画面にエラー内容を表示する(error: let error):
                    print(error)
                }
            }
            .store(in: &self.service.cancellables)
    }
    
    func stopSigningIn(from initialScene: Scene<Usecases.StopSigningIn>, with actor: UserActor) {
        initialScene
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.service.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                if case .アプリはログインモーダルを閉じる = goal {
                    self.state.signInValidationResult = nil
                    self.service.set(isSignInModalPresented: false)
                }
            }
            .store(in: &self.service.cancellables)
    }
 
    func trial(from initialScene: Scene<Usecases.TrialUsing>, with actor: UserActor) {
        self.state.signInValidationResult = nil
        initialScene
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.service.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                if case .アプリはホーム画面を表示する = goal {
                    self.service.routing(to: .home)
                }
            }
            .store(in: &self.service.cancellables)
    }
    
    func completeTutorial(from initialScene: Scene<Usecases.CompleteTutorial>, with actor: UserActor) {
        initialScene
            .interacted(
                by: actor
                , receiveCompletion: {
                    self.service.commonCompletionProcess(with: $0)
                }
            ) { (goal, _) in
                if case .アプリはログイン画面を表示する = goal {
                    self.service.routing(to: .signIn)
                }
                
            }
            .store(in: &self.service.cancellables)
    }
}
