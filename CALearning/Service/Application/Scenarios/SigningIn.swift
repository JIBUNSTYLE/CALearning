//
//  SigningIn.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2022/04/28.
//

import Foundation
import Combine
import RobustiveSwift

/// ユースケース【ログインする】を実現します。
extension Usecases.SignIn.SigningIn : Scenario {
    
    func next(to currentScene: Scene<Self>, by actor: UsecaseActor) -> AnyPublisher<Scene<Self>, Error> {
        switch currentScene {
        case let .basic(scene: .ユーザはログインボタンを押下する(id, password)):
            return self.just(next: .basic(scene: .アプリは入力が正しいかを確認する(id: id, password: password)))
            
        case let .basic(.アプリは入力が正しいかを確認する(id, password)):
            return self.validate(id, password)
            
        case let .basic(.入力が正しい場合_アプリはログインを試行する(id, password)):
            return self.signIn(id, password)
            
        case .last:
            fatalError()
        }
        
    }
    
    private func validate(_ id: String?, _ password: String?) -> AnyPublisher<Scene<Self>, Error> {
        return Deferred {
            Future<Scene<Self>, Error> { promise in
                let result = AccountModel().validate(id, password)
                switch result {
                case let .success(id, password):
                    return promise(.success(.basic(scene: .入力が正しい場合_アプリはログインを試行する(id: id, password: password))))
                case .failed:
                    return promise(.success(.last(scene: .入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(result: result))))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func signIn(_ id: String, _ password: String) -> AnyPublisher<Scene<Self>, Error> {
        return AccountModel()
            .signIn(with: id, and: password)
            .map { account in
                return .last(scene: .ログイン認証に成功した場合_アプリはホーム画面を表示する(user: account))
            }
            .catch { errorWrapper -> AnyPublisher<Scene<Self>, Error> in
                switch (errorWrapper) {
                case let .service(error, _, _):
                    return self.just(next: .last(scene: .ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error: error)))
                case let .system(error, _, _):
                    return self.just(next: .last(scene: .予期せぬエラーが発生した場合_アプリはログイン画面にエラー内容を表示する(error: error)))
                }
            }
            .eraseToAnyPublisher()
    }
}
