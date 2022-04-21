//
//  ActionCreator.swift
//  CALearning
//  
//  Created by e86_s-anzai on 2022/04/20
//

import Foundation
import Combine

final class ActionCreator {
    private let dispatcher: Dispatcher
    var cancellables = [AnyCancellable]()

    init(dispatcher: Dispatcher = .shared) {
        self.dispatcher = dispatcher
    }
}

// MARK: Boot

extension ActionCreator {
    func boot() {
            Boot()
                .interact()
                .sink { completion in
                    if case .finished = completion {
                        print("boot は正常終了")
                    } else if case .failure(let error) = completion {
                        print("boot が異常終了: \(error)")
                    }
                } receiveValue: { scenario in
                    print("usecase - boot: \(scenario)")
                    
                    if case .basic(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示) = scenario.last {
                        self.dispatcher.dispatch(.boot(currentView: .login))

                    } else if case .alternate(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示) = scenario.last {
                        self.dispatcher.dispatch(.boot(currentView: .tutorial))
                    }
                }
                .store(in: &cancellables)
        }
}

