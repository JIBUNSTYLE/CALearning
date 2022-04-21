//
//  Dispatcher.swift
//  CALearning
//  
//  Created by e86_s-anzai on 2022/04/20
//

import Foundation

typealias DispatchToken = String
typealias Callback = (Action) -> Void

final class Dispatcher{

    static let shared = Dispatcher()

    let lock: NSLocking
    private var callbacks: [DispatchToken: (Action) -> Void]

    private init() {
        self.lock = NSRecursiveLock()
        self.callbacks = [:]
    }

    func register(callback: @escaping Callback) -> DispatchToken {
        lock.lock(); defer { lock.unlock() }

        let token =  UUID().uuidString
        callbacks[token] = callback
        return token
    }

    func unregister(_ token: DispatchToken) {
        lock.lock(); defer { lock.unlock() }

        callbacks.removeValue(forKey: token)
    }

    func dispatch(_ action: Action) {
        lock.lock(); defer { lock.unlock() }

        callbacks.forEach { _, callback in
            callback(action)
        }
    }
}
