//
//  Loggingin.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2022/04/28.
//

import Foundation
import Combine

/// ユースケース【ログインする】を実現します。
enum Loggingin : Usecase {
    
    enum Basics {
        case ユーザはログインボタンを押下する(id: String?, password: String?)
        case アプリは入力が正しいかを確認する(id: String?, password: String?)
        case 入力が正しい場合_アプリはログインを試行する(id: String, password: String)
    }
    
    enum Alternatives {
//        case UDIDがない場合_アプリはUDIDを取得する
    }
    
    enum Goals {
        case 入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(result: LoginValidationResult)
        case ログイン認証に成功した場合_アプリはホーム画面を表示する(user: Account)
        case ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error: ServiceErrors)
        case 予期せぬエラーが発生した場合_アプリはログイン画面にエラー内容を表示する(error: SystemErrors)
    }
    
    case basic(scene: Basics)
    case alternate(scene: Alternatives)
    case last(scene: Goals)
    
    init(id: String, password: String) {
        self = .basic(scene: .ユーザはログインボタンを押下する(id: id, password: password))
    }
    
    func authorize(_ actor: UserActor) throws -> Bool {
        return AccountModel().authorize(actor, toInteract: self)
    }
    
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case let .basic(scene: .ユーザはログインボタンを押下する(id, password)):
            return self.just(next: .basic(scene: .アプリは入力が正しいかを確認する(id: id, password: password)))
            
        case let .basic(.アプリは入力が正しいかを確認する(id, password)):
            return self.validate(id, password)
            
        case let .basic(.入力が正しい場合_アプリはログインを試行する(id, password)):
            return self.login(id, password)
            
        case .last:
            return nil
        }
        
    }
    
    private func validate(_ id: String?, _ password: String?) -> AnyPublisher<Self, Error> {
        return Deferred {
            Future<Self, Error> { promise in
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
    
    private func login(_ id: String, _ password: String) -> AnyPublisher<Self, Error> {
        return AccountModel()
            .login(with: id, and: password)
            .map { account in
                return .last(scene: .ログイン認証に成功した場合_アプリはホーム画面を表示する(user: account))
            }
            .catch { errorWrapper -> AnyPublisher<Self, Error> in
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
