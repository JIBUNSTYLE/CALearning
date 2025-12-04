//
//  Helpers.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2025/12/04.
//

import Combine

/// Deferred + Future をまとめた糖衣構文
/// Futureが非同期になる場合、sinkする側ではcancellableをstoreしておかないと、
/// 非同期処理が終わる前に subsciption はキャンセルされてしまうので注意
/// @see: https://forums.swift.org/t/combine-future-broken/28560/2
func DeferredFuture<T, E: Error>(
    _ work: @escaping (@escaping (Result<T, E>) -> Void) -> Void
) -> AnyPublisher<T, E> {
    // Deferredでsubscribesされてから実行されるようになる
    Deferred {
        // Futureは一度だけ結果を返す
        Future { promise in
            work { result in
                promise(result)
            }
        }
    }
    .eraseToAnyPublisher()
}
