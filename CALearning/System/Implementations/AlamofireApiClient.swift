//
//  AlamofireApiClient.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/01.
//

import Foundation
import Combine
import Alamofire

class AlamofireApiClient: ApiClient {
    // 端末のネットワーク状況を検査するクラス
    private(set) var reachabilityManager: NetworkReachabilityManager?
    // ネットワークに接続されているか否か
    private(set) var reachablityStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown

    init() throws {
        // 通信状況の監視を起動
        guard let reachabilityManager = NetworkReachabilityManager() else {
            throw SystemErrors.api(SystemErrors.Api.クライアントの初期化に失敗)
        }
        
        reachabilityManager.startListening(onUpdatePerforming: { status in
            self.reachablityStatus = status
            print("● ReachabilityStatusが変わりました: \(status)")
        })
        
        self.reachablityStatus = reachabilityManager.status

        self.reachabilityManager = reachabilityManager
        print("● 初期段階の reachablityStatus: \(self.reachablityStatus)")
    }
    
    func call<T>(api: T) -> AnyPublisher<T.Entity, ErrorWrapper> where T: Api {

        return Deferred {
            Future<T.Entity, ErrorWrapper> { promise in
                
                guard case .reachable(_) = self.reachablityStatus else {
                    return promise(.failure(
                        ErrorWrapper.service(error: ServiceErrors.client(.ネットワーク接続不可), args: api.description(), causedBy: nil)
                    ))
                }
                
                print(">>>>> API Request: \(api.url) with \(api.params)")
                
                AF.request(
                    api.url
                    , method: api.method
                    , parameters: api.params
                    , encoding: (api.method == .get) ? URLEncoding.default : JSONEncoding.default
                    , headers: api.headers
                )
                    .validate(statusCode: 200..<300) // 正常系のレスポンスかどうかチェック
                    .responseDecodable(of: T.Entity.self) { response in
                        
                        switch response.result {
                        case .success(let entity):
                            promise(.success(entity))

                        case .failure(let error):

                            if case 400 = response.response?.statusCode
                                , let data = response.data
                            {
                                do {
                                    let errorResponse = try api.deserializeErrorResponse(data)
                                    return promise(.failure(
                                        ErrorWrapper.service(error: ServiceErrors.server(errorResponse), args: api.description(), causedBy: error)
                                    ))
                                } catch let error {
                                    return promise(.failure(
                                        ErrorWrapper.system(error: SystemErrors.api(.エラーレスポンスのデシリアライズに失敗(responseJson: String(data: data, encoding: .utf8) ?? "※ 文字列への変換もできませんでした")), args: api.description(), causedBy: error)
                                    ))
                                }
                            }
                            
                            promise(.failure(
                                ErrorWrapper.system(error: SystemErrors.api(.HTTPクライアントエラー(statusCode: response.response?.statusCode)), args: api.description(), causedBy: error)
                            ))
                        }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
