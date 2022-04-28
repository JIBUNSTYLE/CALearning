//
//  LoginStore.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/04/06.
//

import Foundation
import Combine

class LoginStore: ObservableObject {
    private let presenter: Presenter
    
    init(with presenter: Presenter) {
        self.presenter = presenter
    }
}
