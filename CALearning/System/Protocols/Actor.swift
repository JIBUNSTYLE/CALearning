//
//  Actor.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/15.
//

import Foundation

enum UserTypes {
    case anyone
    case signedIn
}

protocol Actor {
    associatedtype User
    var user: User? { get }
    var userType: UserTypes { get }
}

extension Actor {
    var userType: UserTypes {
        guard let _ = self.user else {
            return .anyone
        }
        return .signedIn
    }
}
