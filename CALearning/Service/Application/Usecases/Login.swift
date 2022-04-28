//
//  Login.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2022/04/28.
//

import Foundation
import Combine

/// ユースケース【ログインする】を実現します。
enum Login : Usecase {
    
    enum Basics {
        case ユーザはログインボタンを押下する(id: String, password: String)
        case アプリは入力が正しいかを確認する(id: String, password: String)
        case 入力が正しい場合_アプリはログインを試行する(id: String, password: String)
    }
    
    enum Alternatives {
//        case UDIDがない場合_アプリはUDIDを取得する
    }
    
    enum Goals {
        case 入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(error: ServiceErrors)
        case ログイン認証に成功した場合_アプリはホーム画面を表示する(user: Account)
        case ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error: ServiceErrors)
    }
    
    case basic(scene: Basics)
    case alternate(scene: Alternatives)
    case last(scene: Goals)
    
    init(id: String, password: String) {
        self = .basic(scene: .ユーザはログインボタンを押下する(id: id, password: password))
    }
    
    func authorize(_ actor: Actor) throws -> Bool {
        // Actorが誰でも実行可能
        return true
    }
    
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case let .basic(scene: .ユーザはログインボタンを押下する(id, password)):
            return self.just(next: .basic(scene: .アプリは入力が正しいかを確認する(id: id, password: password)))
            
        case let .basic(.アプリは入力が正しいかを確認する(id, password)):
            return self.check(id, password)
            
        case let .basic(.入力が正しい場合_アプリはログインを試行する(id, password)):
            return self.login(id, password)

        
            
        case .last:
            return nil
    }
    
    private func check(_ id: String, _ password: String) -> AnyPublisher<Self, Error> {
        return Deferred {
            Future<Self, Error> { promise in
                if AccountModel().validate(id, password) {
                    return promise(.success(.basic(scene: .UDIDがない場合_アプリはUDIDを取得する)))
                }
                promise(.success(.last(scene: .入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(udid: udid))))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func login(_ id: String, _ password: String) -> AnyPublisher<Self, Error> {
        // Deferredでsubscribesされてから実行されるようになる
        // Futureは一度だけ結果を返す
        return Deferred {
            Future<Self, Error> { promise in
                // Futureが非同期になる場合、sinkする側ではcancellableをstoreしておかないと、
                // 非同期処理が終わる前にsubsciptionはキャンセルされてしまうので注意
                // @see: https://forums.swift.org/t/combine-future-broken/28560/2
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if Application().hasCompletedTutorial {
                        promise(.success(.last(scene: .チュートリアル完了の記録がある場合_アプリはログイン画面を表示)))
                    } else {
                        promise(.success(.last(scene: .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func publishUdid() -> AnyPublisher<Self, Error> {
        return Application()
            .publishUdid()
            .map { udid -> Self in
                Application().save(udid: udid)
                return .basic(scene: .アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: udid))
            }
            .eraseToAnyPublisher()
    }
}
