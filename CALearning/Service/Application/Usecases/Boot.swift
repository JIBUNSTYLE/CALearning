//
//  Boot.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine

/// ユースケース【アプリを起動する】を実現します。
enum Boot {
    
    enum Basics {
        case ユーザはHome画面でアイコンを選択する
        case アプリはチュートリアル完了済かを確認する
    }
    
    enum Alternatives {}
   
    enum Goals {
        case 完了済の場合_アプリはログイン画面を表示する
        case 完了済でない場合_アプリはチュートリアル画面を表示する
    }
    
    case basic(scene: Basics)
    case alternate(scene: Alternatives)
    case last(scene: Goals)
}

extension Boot : Usecase {
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case .basic(scene: .ユーザはHome画面でアイコンを選択する):
            return self.just(next: .basic(scene: .アプリはチュートリアル完了済かを確認する))
        case .basic(scene: .アプリはチュートリアル完了済かを確認する):
            return self.detect()
        case .last:
            return nil
        }
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
                        promise(.success(.last(scene: .完了済の場合_アプリはログイン画面を表示する)))
                    } else {
                        promise(.success(.last(scene: .完了済でない場合_アプリはチュートリアル画面を表示する)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
