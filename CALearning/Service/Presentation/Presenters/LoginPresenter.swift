//
//  LoginPresenter.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/04/06.
//

import Foundation
import Combine

class LoginPresenter: ObservableObject {
    private let parent: SharedPresenter
    
    init(with parent: SharedPresenter) {
        self.parent = parent
    }
}
