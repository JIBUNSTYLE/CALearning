//
//  Api.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/01.
//

import Foundation
import Alamofire

struct ErrorResponse: Codable, Error {
    let code: String
    let title: String
    let message: String
}

protocol Api {
    associatedtype Entity: Codable
    
    var method: HTTPMethod { get }
    var url: String { get }
    var headers: HTTPHeaders? { get }
    var params: [String: Any] { get }

    // サーバから戻ってきたJSONを専用の構造体に変更する
    func deserialize(_ json: Data) throws -> Entity
}

extension Api {
    
    func deserialize(_ json: Data) throws -> Entity {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // 日付のデコードする際の形式を指定
        return try decoder.decode(Entity.self, from: json)
    }
    
    func deserializeErrorResponse(_ json: Data) throws -> ErrorResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // 日付のデコードする際の形式を指定
        return try decoder.decode(ErrorResponse.self, from: json)
    }
}
