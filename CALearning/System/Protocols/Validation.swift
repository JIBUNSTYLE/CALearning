//
//  Validation.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2022/04/28.
//

import Foundation


enum ValidationResult<T> {
    enum IsRequired {
        case isFailed(_: T)
    }
    enum IsTooShort {
        case isFailed(_: T, lessThan: Int, actual: Int)
    }
    enum IsTooLong {
        case isFailed(_: T, greaterThan: Int, actual: Int)
    }
    enum IsMalformed {
        case isFailed(_: T)
    }
}


protocol Validation {
    associatedtype Input
}

extension Validation {

    func validate(isRequired value: Input?) -> ValidationResult<Input?>.IsRequired? {
        guard let _ = value else { return .isFailed(value) }
        return nil
    }
    
    func validate(isEqualToOrGreaterThan value: String?, minLength: Int) -> ValidationResult<String?>.IsTooShort? {
        guard let value = value else { return nil }
        if value.count < minLength {
            return .isFailed(value, lessThan: minLength, actual: value.count)
        }
        return nil
    }
    
    func validate(isEqualToOrLessThan value: String?, maxLength: Int) -> ValidationResult<String?>.IsTooLong? {
        guard let value = value else { return nil }
        if value.count > maxLength {
            return .isFailed(value, greaterThan: maxLength, actual: value.count)
        }
        return nil
    }
    
    func validate(isMailAddress value: String?) -> ValidationResult<String?>.IsMalformed? {
        guard let value = value else { return nil }
        let pattern = "^[\\w\\.\\-_]+@[\\w\\.\\-_]+\\.[a-zA-Z]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { fatalError() }
        guard regex.matches(in: value, range: NSRange(location: 0, length: value.count)).count == 1 else {
            return .isFailed(value)
        }
        return nil
    }
}
