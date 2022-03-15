//
//  Actor.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/15.
//

import Foundation
import Combine

protocol Actor {
    var user: Account? { get }
    /// Usecaseに準拠するenumを引数に取り、再帰的にnext()を実行します。
    ///
    /// - Parameter contexts: ユースケースシナリオの（画面での分岐を除く）分岐をけcaseに持つenumのある要素
    /// - Returns: 引数のenumと同様のenumで、引数の分岐を処理した結果の要素
    func interact<T : Usecase>(in initialScene: T) -> AnyPublisher<[T], Error>
}

extension Actor {
    private func recursive<T : Usecase>(contexts: [T]) -> AnyPublisher<[T], Error> {
        guard let context = contexts.last else { fatalError() }
        
        // 終了条件
        guard let future = context.next() else {
            return Deferred {
                Future<[T], Error> { promise in
                    promise(.success(contexts))
                }
            }
            .eraseToAnyPublisher()
        }
        
        // 再帰呼び出し
        return future
            .flatMap { nextContext -> AnyPublisher<[T], Error> in
                var _contexts = contexts
                _contexts.append(nextContext)
                return self.recursive(contexts: _contexts)
            }
            .eraseToAnyPublisher()
    }
    
    func interact<T : Usecase>(in initialScene: T) -> AnyPublisher<[T], Error> {
        guard Application().authorize(self, toInteractFrom: initialScene) else {
            return Fail(error: ErrorWrapper.service(error: .client(.現在のアカウントには許可されていないユースケースが実行されました), args: ["actor": self, "initialScene": self], causedBy: nil))
                .eraseToAnyPublisher()
        }
        return self.recursive(contexts: [initialScene])
    }
}
