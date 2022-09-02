//
//  UserActor.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/05/18.
//

import Foundation

struct UserActor : Actor {
    typealias User = Account
    
    var user: User?
}

extension Usecase {
    func authorize<T: Actor>(_ actor: T) throws -> Bool {
        if let userActor = actor as? UserActor {
            return AccountModel().authorize(userActor, toInteract: self)
        } else {
            throw ServiceErrors.development(ServiceErrors.Development.権限未設定_AccountModelのAuthorizeに追加が必要です)
        }
    }
}
