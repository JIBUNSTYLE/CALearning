//
//  ServiceErrors.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/01.
//

import Foundation

enum ServiceErrors: Error {
    
    enum Development: Error {
        case 権限未設定_AccountModelのAuthorizeに追加が必要です
    }

    enum Client: Error {
        case 現在のアカウントには許可されていないユースケースが実行されました
        case ネットワーク接続不可
    }

    case development(_ error: Development)
    case client(_ error: Client)
    case server(_ error: ErrorResponse)

}
