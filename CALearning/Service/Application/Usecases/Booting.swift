//
//  Booting.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine

/// ユースケース【アプリを起動する】を実現します。
enum Booting : Usecase {
    
    enum Basics {
        case ユーザはアプリを起動する
        case アプリはサーバで発行したUDIDが保存されていないかを調べる
        case アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: String)
    }
    
    enum Alternatives {
        case UDIDがない場合_アプリはUDIDを取得する
    }
    
    enum Goals {
        case チュートリアル完了の記録がある場合_アプリはログイン画面を表示
        case チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示
    }
    
    case basic(scene: Basics)
    case alternate(scene: Alternatives)
    case last(scene: Goals)
    
    init() {
        self = .basic(scene: .アプリはサーバで発行したUDIDが保存されていないかを調べる)
    }
    
    func authorize(_ actor: UserActor) throws -> Bool {
        // Actorが誰でも実行可能
        return true
    }
    
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case .basic(scene: .ユーザはアプリを起動する):
            return self.just(next: .basic(scene: .アプリはサーバで発行したUDIDが保存されていないかを調べる))
            
        case .basic(.アプリはサーバで発行したUDIDが保存されていないかを調べる):
            return self.checkUdid()
            
        case .basic(.アプリはユーザがチュートリアルを完了した記録がないかを調べる):
            return self.detect()

        case .alternate(.UDIDがない場合_アプリはUDIDを取得する):
            return self.publishUdid()
            
        case .last:
            return nil
        }
    }
    
    private func checkUdid() -> AnyPublisher<Self, Error> {
        return Deferred {
            Future<Self, Error> { promise in
                guard let udid = Application().udid else {
                    return promise(.success(.alternate(scene: .UDIDがない場合_アプリはUDIDを取得する)))
                }
                promise(.success(.basic(scene: .アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: udid))))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func detect() -> AnyPublisher<Self, Error> {
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
