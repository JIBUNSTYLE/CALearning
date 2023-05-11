//
//  Backend.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/03.
//

import Foundation
import Combine

protocol Backend {

    /// UDIDを発行します。
    func publishUdid() -> AnyPublisher<String, ErrorWrapper>

    /// ログインします。
    func signIn(with id: String, `and` password: String) -> AnyPublisher<Account, ErrorWrapper>
}
