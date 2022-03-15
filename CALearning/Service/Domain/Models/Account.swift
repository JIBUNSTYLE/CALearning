//
//  Account.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/15.
//

import Foundation

struct Account {
    let mailAddress: String
}

class AccountModel : Model {
    typealias Entity = Account
    
    func authorize<T: Usecase>(_ actor: Account?, toInteract usecase: T) -> Bool {
        switch usecase {
        case is Boot : do {
            return true
        }
        default:
            return false
        }
    }
}
