//
//  Account.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/15.
//

import Foundation
import Combine
import RobustiveSwift
import SystemConfiguration


enum IdValidation : Validation {
    typealias Input = String
    
    case isValid(id: Input?)
    case isRequired(_: ValidationResult<Input?>.IsRequired)
    case isMalformed(_: ValidationResult<Input?>.IsMalformed)
    
    init(id: Input?) {
        self = .isValid(id: id)
    }
    
    func isRequired() -> Self {
        guard case let .isValid(id) = self else { return self }
        if let failed = self.validate(isRequired: id) {
            return .isRequired(failed)
        }
        return self
    }
    
    func isMalformed() -> Self {
        guard case let .isValid(id) = self else { return self }
        if let failed = self.validate(isMailAddress: id) {
            return .isMalformed(failed)
        }
        return self
    }
}

enum PasswordValidation : Validation {
    typealias Input = String
    
    case isValid(password: Input?)
    case isRequired(_: ValidationResult<Input?>.IsRequired)
    case isTooShort(_: ValidationResult<Input?>.IsTooShort)
    case isTooLong(_: ValidationResult<Input?>.IsTooLong)
    
    init(password: Input?) {
        self = .isValid(password: password)
    }
    
    func isRequired() -> Self {
        guard case let .isValid(password) = self else { return self }
        if let failed = self.validate(isRequired: password) {
            return .isRequired(failed)
        }
        return self
    }
    
    func isTooShort() -> Self {
        guard case let .isValid(password) = self else { return self }
        if let failed = self.validate(isEqualToOrGreaterThan: password, minLength: 8) {
            return .isTooShort(failed)
        }
        return self
    }
    
    func IsTooLong() -> Self {
        guard case let .isValid(password) = self else { return self }
        if let failed = self.validate(isEqualToOrLessThan: password, maxLength: 16) {
            return .isTooLong(failed)
        }
        return self
    }
}


enum SignInValidationResult {
    case success(id: String, password: String)
    case failed(idValidationResult: IdValidation, passwordValidationResult: PasswordValidation)
}

struct Account {
    let mailAddress: String
}

class AccountModel : Entity {
    typealias Properties = Account
    
    func authorize<T: Scenario>(_ actor: UserActor, toInteract usecase: Usecase<T>) -> Bool {
        switch T.self {
        case is Usecases.Booting.Type
            , is Usecases.CompleteTutorial.Type
            , is Usecases.CloseDialog.Type
            : do {
            // Actorが誰でも実行可能
            return true
        }
        case is Usecases.SigningIn.Type
            , is Usecases.StopSigningIn.Type
            , is Usecases.TrialUsing.Type : do {
            // 未サインインユーザのみ実行可能
            guard case .anyone = actor.userType else { return false }
            return true
        }
            
        case is Usecases.Purchase.Type : do {
            // サインイン済みユーザのみ実行可能
            guard case .signedIn = actor.userType else { return false }
            return true
        }

        default:
            return false
        }
    }
    
    func validate(_ id: String?, _ password: String?) -> SignInValidationResult {
        let idValidationResult = IdValidation(id: id)
            .isRequired()
            .isMalformed()
        
        let passwordValidationResult = PasswordValidation(password: password)
            .isRequired()
            .isTooShort()
            .IsTooLong()
        
        if case .isValid = idValidationResult, case .isValid = passwordValidationResult {
            return .success(id: id!, password: password!)
        } else {
            return .failed(idValidationResult: idValidationResult, passwordValidationResult: passwordValidationResult)
        }
    }

}

// MARK: - Requirements
extension AccountModel {
    
    /// ユーザはサービスに登録されているアカウントにサインインできること
    func signIn(with id: String, `and` password: String) -> AnyPublisher<Properties, ErrorWrapper> {
        return Dependencies.shared.backend.signIn(with: id, and: password)
    }
}