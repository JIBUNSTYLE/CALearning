//
//  ServiceErrors.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/01.
//

import Foundation

enum ServiceErrors: Error {

    enum Client: Error {
        case ネットワーク接続不可
    }

    case client(_ error: Client)
    case server(_ error: ErrorResponse)

}