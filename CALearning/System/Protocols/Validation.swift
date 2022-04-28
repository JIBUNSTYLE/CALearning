//
//  Validation.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2022/04/28.
//

import Foundation


enum ValidationResult<T> {
    enum IsRequired {
        case failed(item: T)
    }
    enum IsTooShort {
        case failed(item: T)
    }
    enum IsTooLong {
        case failed(item: T)
    }
    enum IsMalformed {
        case failed(item: T)
    }
}

struct Validator {

    func isRequired(v: String?) -> ValidationResult {
        guard let _ = v else { return .isRequired }
        return .success
    }
}

protocol Validation {
    associatedtype Input
    associatedtype Result
    
    var input: Input? { get }
    var isValid: Result { get }
}

extension Validation {
    
}
