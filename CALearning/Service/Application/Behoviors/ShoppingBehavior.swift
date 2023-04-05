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
    
    private var cancellables = [AnyCancellable]()
    
    init(with controller: Controller) {
        self.controller = controller
    }
}

extension ShoppingBehavior {
    
    func purchase(_ from: Usecases.Purchase, with actor: UserActor) {
        from
            .interacted(by: actor)
            .sink { completion in
                self.controller.resetUsecaseState()
                if case .finished = completion {
                    print("\(#function) は正常終了")
                } else if case .failure(let error) = completion {
                    print("\(#function) が異常終了: \(error)")
                    if case RobustiveError.Interaction<Usecases.Purchase, UserActor>.notAuthorized = error {
                        // 再開したいユースケースを保存
                        self.controller.change(actor: actor.update(usecaseToResume: .purchase(from: from)))
                        
                        // ログインを促す
                        self.controller.isLoginModalPresented = true
                    }
                }
            } receiveValue: { scenario in
                print("usecase - \(#function): \(scenario)")
                
                guard case .last(let goal) = scenario.last else { fatalError() }
                
                switch goal {
                case .アプリは購入確認画面を表示する:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
