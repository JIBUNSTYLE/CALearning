//
//  Anyone.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/15.
//

import Foundation

struct Anyone : Actor {

    let user: Account?
    
    init() {
        self.user = nil
    }
}
