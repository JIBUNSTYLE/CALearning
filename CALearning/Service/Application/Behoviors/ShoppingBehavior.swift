//
//  ShoppingBehavior.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import Foundation
import Combine
import RobustiveSwift

class ShoppingBehavior: ObservableObject {
    private let controller: Controller
    
    @Published var isConfirming = false
    
    private var cancellables = [AnyCancellable]()
    
    init(with controller: Controller) {
        self.controller = controller
    }
}

extension ShoppingBehavior {
    
    func purchase(_ from: Usecase<Usecases.Purchase>, with actor: UserActor) {
        from
            .interacted(
                by: actor
                , receiveCompletion: { completion in
                    self.controller.commonCompletionProcess(with: completion)
                    
                    guard case let .failure(error) = completion
                        , case RobustiveError.Interaction<Usecases.Purchase, UserActor>.notAuthorized = error else { return }
                    // 再開したいユースケースを保存
                    self.controller.change(actor: actor.update(usecaseToResume: .purchase(from: from)))
                    // ログインを促す
                    self.controller.set(isLoginModalPresented: true)
                }
            ) { (goal, scenario) in
                switch goal {
                case .アプリは購入確認画面を表示する:
                    self.isConfirming = true
                }
            }
            .store(in: &cancellables)
    }
}
