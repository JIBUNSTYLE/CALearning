//
//  DomainModels.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/15.
//

import Foundation

protocol Entity {
    associatedtype Properties
}

protocol ValueObject {
    associatedtype Properties
}

protocol Service {}


protocol Performer {
    associatedtype Store : ObservableObject
    var store: Store { get }
}
