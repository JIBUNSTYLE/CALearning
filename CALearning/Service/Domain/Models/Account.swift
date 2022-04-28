//
//  Account.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/15.
//

import Foundation
import SwiftUI

enum LoginValidationResult {
    case id(isRequired: ValidationResult<String>.IsRequired)
    case password(isRequired: ValidationResult<String>.IsRequired)
    case password(isTooShort: ValidationResult<String>.IsTooShort)
}

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
    
    
    func validate(_ id: String, _ password: String) -> LoginValidationResult {
        
    }
}
