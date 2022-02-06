//
//  SystemErrors.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/01.
//

import Foundation

/// サービスエラーとシステムエラーをが起きた際、どのAPIで起きたのか、何のエラー起因で起きたのかのコンテキストを伝えるために、Enumでラッピングしている。
///
/// - service: サービスで予め想定しているエラー
/// - system: サービスで想定していないエラー
enum ErrorWrapper<T>: Error {
    case service(error: ServiceErrors, args: T?, causedBy: Error?)
    case system(error: SystemErrors, args: T?, causedBy: Error?)
}

enum SystemErrors: Error {

    enum Development: Error {
        case 未実装
        case キャストに失敗
    }
    
    enum Test: Error {
        case 準備されたAPIスタブが呼び出されたAPIと合致しません(message: String)
        case 準備されたAPIスタブのEncodeまたはDecodeに失敗(stub: String)
    }

    enum Api: Error {
        case クライアントの初期化に失敗
        case エラーレスポンスのデシリアライズに失敗(responseJson: String)
        // call時（specでは扱わない）
        case レスポンスがnil
        case デシリアライズに失敗(responseJson: String)
        case 通信エラー(httpStatusCode: String)
        case HTTPステータスエラー(statusCode: Int?, description: String? = nil)
        case HTTPクライアントエラー(statusCode: Int?, description: String? = nil)
        
        // response -> context変換時
        case 未定義のサーバーエラー(errorCd: String)
        case このAPIで想定されていないサーバーエラーが返されました(errorCd: String)
        case レスポンスの内容が想定と違います(description: String)
        case データ変換エラー(description: String)
    }

    case development(_ error: Development)
    case test(_ error: Test)
    case api(_ error: Api)
}
