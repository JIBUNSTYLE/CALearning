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
    associatedtype Usecases
    associatedtype Store : ObservableObject
    
    var store: Store { get }
    func dispatch(_ usecase: Usecases, with actor: UserActor)
}
