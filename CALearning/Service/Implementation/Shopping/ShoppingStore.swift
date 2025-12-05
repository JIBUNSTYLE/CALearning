//
//  ShoppingStore.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import Foundation
import RobustiveSwift

class ShoppingState: ObservableObject {
    @Published fileprivate(set) var isConfirming = false
}

struct ShoppingStore: Store {
    typealias Usecases = R.Shopping
    typealias State = ShoppingState

    private let service: FrontendService
    
    let state = State()
    
    init(with service: FrontendService) {
        self.service = service
    }
    
    func dispatch(_ usecase: Usecases, with actor: UserActor) {
        switch usecase {
        case let .purchase(from: initialScene):
            self.purchase(from: initialScene, with: actor)
        }
    }
}

// MARK: - Mutations

extension ShoppingStore {
    
    func purchase(from initialScene: Scene<Usecases.Purchase>, with actor: UserActor) {
        initialScene
            .interacted(
                by: actor
                , receiveCompletion: { completion in
                    self.service.commonCompletionProcess(with: completion)
                    guard case let .failure(error) = completion
                            , case RobustiveError.Interaction<Usecases.Purchase, UserActor>.notAuthorized = error else { return }
                    // 再開したいユースケースを保存
                    self.service.change(actor: actor.update(usecaseToResume: R.shopping(usecase: .purchase(from: initialScene))))
                    // ログインを促す
                    self.service.set(isSignInModalPresented: true)

                }
            ) { (goal, scenario) in
                switch goal {
                case .アプリは購入確認画面を表示する:
                    self.state.isConfirming = true
                }
            }
            .store(in: &self.service.cancellables)
    }
}
