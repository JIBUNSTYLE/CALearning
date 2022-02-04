//
//  Boot.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine

/// ユースケース【アプリを起動する】を実現します。
enum Boot : Usecase {
    
    enum Basics {
        case アプリはサーバで発行したUDIDが保存されていないかを調べる
        case アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: String)
        case チュートリアル完了の記録がある場合_アプリはログイン画面を表示
    }
    
    enum Alternatives {
        case UDIDがない場合_アプリはUDIDを取得する
        case チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示
    }
    
    case basic(scene: Basics)
    case alternate(scene: Alternatives)
    
    init() {
        self = .basic(scene: .アプリはサーバで発行したUDIDが保存されていないかを調べる)
    }
    
    func next() -> AnyPublisher<Boot, Error>? {
        switch self {
        case .basic(.アプリはサーバで発行したUDIDが保存されていないかを調べる):
            return self.checkUdid()
            
        case .basic(.アプリはユーザがチュートリアルを完了した記録がないかを調べる):
            return self.detect()

        case .basic(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示):
            return nil

        case .alternate(.UDIDがない場合_アプリはUDIDを取得する):
            return self.publishUdid()
            
        case .alternate(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示):
            return nil
        }
    }
    
    private func checkUdid() -> AnyPublisher<Boot, Error> {
        return Deferred {
            Future<Boot, Error> { promise in
                guard let udid = Application().udid else {
                    return promise(.success(.alternate(scene: .UDIDがない場合_アプリはUDIDを取得する)))
                }
                promise(.success(.basic(scene: .アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: udid))))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func detect() -> AnyPublisher<Boot, Error> {
        // Deferredでsubscribesされてから実行されるようになる
        // Futureは一度だけ結果を返す
        return Deferred {
            Future<Boot, Error> { promise in
                // Futureが非同期になる場合、sinkする側ではcancellableをstoreしておかないと、
                // 非同期処理が終わる前にsubsciptionはキャンセルされてしまうので注意
                // @see: https://forums.swift.org/t/combine-future-broken/28560/2
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if Application().hasCompletedTutorial {
                        promise(.success(.basic(scene: .チュートリアル完了の記録がある場合_アプリはログイン画面を表示)))
                    } else {
                        promise(.success(.alternate(scene: .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func publishUdid() -> AnyPublisher<Boot, Error> {
        return Application()
            .publishUdid()
            .map { udid -> Boot in
                Application().save(udid: udid)
                return .basic(scene: .アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: udid))
            }
            .eraseToAnyPublisher()
    }
}
