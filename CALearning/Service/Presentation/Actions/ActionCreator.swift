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
                    
                    if let last = scenario.last {
                        self.dispatcher.dispatch(last)
                    }
                }
                .store(in: &cancellables)
        }
}

