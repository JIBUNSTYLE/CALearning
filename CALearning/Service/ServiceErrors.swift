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

    /// API仕様書に従い、APIが返してくるエラーコードをAPI毎に定義しています。
    enum Server: Error {
        
        enum Udid: Error {}
        enum Authentication: Error {}
        enum Information: Error {}
        enum Genre: Error {}
        enum Spot: Error {}
        enum Favorite: Error {}


        case udid(_ error: Udid)
        case authentication(_ error: Authentication)
        case information(_ error: Information)
        case genre(_ error: Genre)
        case spot(_ error: Spot)
        case favorite(_ error: Favorite)
    }

    case client(_ error: Client)
    case server(_ error: Server)

}
