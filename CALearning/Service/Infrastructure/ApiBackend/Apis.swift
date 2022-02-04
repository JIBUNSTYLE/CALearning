//
//  Apis.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/03.
//

import Foundation
import Alamofire

struct ErrorResponse: Codable, Error {
    let code: Int
    let message: String
}

struct Apis {
    static let BASE_URL = "http://apps.dev.timesclub.jp/yorimichiappsweb" // Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as! String

    static let DEFAULT_HEADERS = HTTPHeaders(["Content-Type" : "application/json"])
 
    /// 端末識別ID発行
    struct Udid: Api {
        typealias Entity = Response

        struct Response: Codable {
            let udid: String
        }

        let method = HTTPMethod.post
        let url = Apis.BASE_URL + "/device/id/issue"
        let headers: HTTPHeaders?
        let params: [String: Any]

        init(headers: HTTPHeaders? = Apis.DEFAULT_HEADERS) {
            self.params = ["appDeviceKbn" : 11]
            self.headers = headers
        }
    }
}
