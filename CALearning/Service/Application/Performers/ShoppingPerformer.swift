//
//  ShoppingPerformer.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import Foundation
import RobustiveSwift

class ShoppingStore: ObservableObject {
    @Published fileprivate(set) var isConfirming = false
}

struct ShoppingPerformer: Performer {
    typealias Store = ShoppingStore

    private let dispatcher: Dispatcher
    
    let store = Store()
    
    init(with dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
    }
}

// MARK: - Behaviors

extension ShoppingPerformer {
    
    func purchase(from initialScene: Scene<Usecases.Purchase>, with actor: UserActor) {
        initialScene
            .interacted(
                by: actor
                , receiveCompletion: { completion in
                    self.dispatcher.commonCompletionProcess(with: completion)
                    
                    guard case let .failure(error) = completion
                        , case RobustiveError.Interaction<Usecases.Purchase, UserActor>.notAuthorized = error else { return }
                    // 再開したいユースケースを保存
                    self.dispatcher.change(actor: actor.update(usecaseToResume: .purchase(from: initialScene)))
                    // ログインを促す
                    self.dispatcher.set(isSignInModalPresented: true)
                }
            ) { (goal, scenario) in
                switch goal {
                case .アプリは購入確認画面を表示する:
                    self.store.isConfirming = true
                }
            }
            .store(in: &self.dispatcher.cancellables)
    }
}
