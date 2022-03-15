//
//  Usecase.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine

protocol Usecase {
    /// 自身が表すユースケースのSceneを実行した結果として、次のSceneがあれば次のSceneを返すFutureを、ない（シナリオの最後の）場合には nil を返します。
    func next() -> AnyPublisher<Self, Error>?
    
    /// 引数で渡されたSceneを次のSceneとして返します。
    /// next関数の実装時、特にドメイン的な処理がSceneが続く場合に使います。
    func just(next: Self) -> AnyPublisher<Self, Error>
    
    func authorize(actor: Account?) -> Bool
    
    /// Usecaseに準拠するenumを引数に取り、再帰的にnext()を実行します。
    ///
    /// - Parameter contexts: ユースケースシナリオの（画面での分岐を除く）分岐をけcaseに持つenumのある要素
    /// - Returns: 引数のenumと同様のenumで、引数の分岐を処理した結果の要素
    func interact(with actor: Account?) -> AnyPublisher<[Self], Error>
}



extension Usecase {
    
    func just(next: Self) -> AnyPublisher<Self, Error> {
        return Deferred {
            Future<Self, Error> { promise in
                promise(.success(next))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func recursive(contexts: [Self]) -> AnyPublisher<[Self], Error> {
        guard let context = contexts.last else { fatalError() }
        
        // 終了条件
        guard let future = context.next() else {
            return Deferred {
                Future<[Self], Error> { promise in
                    promise(.success(contexts))
                }
            }
            .eraseToAnyPublisher()
        }
        
        // 再帰呼び出し
        return future
            .flatMap { nextContext -> AnyPublisher<[Self], Error> in
                var _contexts = contexts
                _contexts.append(nextContext)
                return self.recursive(contexts: _contexts)
            }
            .eraseToAnyPublisher()
    }
    
    func authorize(actor: Account?) -> Bool {
        return AccountModel().authorize(actor, toInteract: self)
    }
    
    func interact(with actor: Account? = nil) -> AnyPublisher<[Self], Error> {
        guard self.authorize(actor: actor) else {
            return Fail(error: ErrorWrapper.service(error: .client(.現在のアカウントには許可されていないユースケースが実行されました), args: ["actor": actor, "usecase": self], causedBy: nil))
                .eraseToAnyPublisher()
        }
        return self.recursive(contexts: [self])
    }
}
