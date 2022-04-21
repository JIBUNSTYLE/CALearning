//
//  Store.swift
//  CALearning
//  
//  Created by e86_s-anzai on 2022/04/20
//

import Foundation

class Store: ObservableObject {
    private lazy var dispatchToken: DispatchToken = {
        return dispatcher.register(callback: { [weak self] action in
            self?.onDispatch(action)
        })
    }()

    private let dispatcher: Dispatcher

    deinit {
        dispatcher.unregister(dispatchToken)
    }

    init(dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
        _ = dispatchToken
    }

    func onDispatch(_ action: Action) {
        fatalError("must override")
    }
}
