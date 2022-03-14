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
    var encoding: ParameterEncoding { get }
    var params: [String: Any] { get }
    var decoder: DataDecoder { get }

    // サーバから戻ってきたJSONを専用の構造体に変更する
    func deserialize(_ json: Data) throws -> Entity
    func deserializeErrorResponse(_ json: Data) throws -> ErrorResponse
    
    // エラー発生時に問題解決の手掛かりにするなどのために、APIの情報をDictionaryで返します
    func description() -> [String:Any]
}

extension Api {
    
    var encoding: ParameterEncoding {
        if case .get = self.method {
            return URLEncoding.default
        } else {
            return JSONEncoding.default
        }
    }
    
    var decoder: DataDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // 日付のデコードする際の形式を指定
        return decoder
    }
    
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
    
    func description() -> [String:Any] {
        return [
            "method"    : self.method.rawValue
            , "url"     : self.url
            , "headers" : self.headers.debugDescription
            , "params"  : self.params.debugDescription
        ]
    }
}
