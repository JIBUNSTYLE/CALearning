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
        case アプリはユーザがチュートリアルを完了した記録がないかを調べる
    }
    
    enum Goals {
        case チュートリアル完了の記録がある場合_アプリはログイン画面を表示
        case チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示
    }
    
    case basic(scene: Basics)
    case goal(scene: Goals)
    
    init() {
        self = .basic(scene: .アプリはユーザがチュートリアルを完了した記録がないかを調べる)
    }
    
    func next() -> AnyPublisher<Boot, Error>? {
        switch self {
        case .basic(.アプリはユーザがチュートリアルを完了した記録がないかを調べる):
            return self.detect()

        case .goal(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示):
            return nil
        case .goal(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示):
            return nil
        }
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
                        promise(.success(.goal(scene: .チュートリアル完了の記録がある場合_アプリはログイン画面を表示)))
                    } else {
                        promise(.success(.goal(scene: .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
