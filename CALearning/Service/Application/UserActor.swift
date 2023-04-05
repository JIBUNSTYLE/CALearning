//
//  UserActor.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/05/18.
//

import Foundation
import RobustiveSwift

struct UserActor : Actor, CustomStringConvertible {
    typealias User = Account
    
    let udid: String?
    let user: User? // nil の場合はアノニマス
    let usecaseToResume: Usecases?
    
    var description: String {
        "udid: \(self.udid ?? "-"), user: \(self.user?.mailAddress ?? "-")"
    }
    
    func update(udid: String? = nil, user: User? = nil, usecaseToResume: Usecases? = nil) -> Self {
        return UserActor(
            udid: udid ?? self.udid
            , user: user ?? self.user
            , usecaseToResume: usecaseToResume ?? self.usecaseToResume
        )
    }
}

extension Usecase {

    func authorize<T: Actor>(_ actor: T) throws -> Bool {
        guard let userActor = actor as? UserActor else {
            fatalError()
        }
        return AccountModel().authorize(userActor, toInteract: self)
    }
}
