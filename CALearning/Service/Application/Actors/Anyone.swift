//
//  Anyone.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/15.
//

import Foundation

struct Anyone : Actor {
    typealias User = Account
    let user: User?
    
    init() {
        self.user = nil
    }
}