//
//  MockApiClient.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/01.
//

import Foundation
import Combine
import Alamofire

/// callを呼ぶと、stubで渡したDataをDecodeして返します
struct MockApiClient<U> : ApiClient where U: Api {
    
    enum ApiResult<T> where T : Api {
        case success(entity: T.Entity)
        case failure(by: ErrorWrapper)
    }
    
    // ネットワークに接続されているか否か
    var isReachable: Bool = true

    let stub: ApiResult<U>
    let beforeCall: ((U) -> Void)?
    let afterCall: ((ApiResult<U>) -> Void)?

    init(stub: ApiResult<U>, beforeCall: ((U) -> Void)? = nil, afterCall: ((ApiResult<U>) -> Void)? = nil) {
        self.stub = stub
        self.beforeCall = beforeCall
        self.afterCall = afterCall
    }
    
    func call<T>(api: T) -> AnyPublisher<T.Entity, ErrorWrapper> where T: Api {

        return Deferred {
            Future<T.Entity, ErrorWrapper> { promise in
                guard let _api = api as? U else {
                    return promise(.failure(
                        ErrorWrapper.system(error: SystemErrors.test(.準備されたAPIスタブが呼び出されたAPIと合致しません(message: "mocking: \(U.self), called: \(type(of: api))")), args: api.description(), causedBy: nil)
                    ))
                }
                
                guard self.isReachable else {
                    return promise(.failure(
                        ErrorWrapper.service(error: .client(.ネットワーク接続不可), args: api.description(), causedBy: nil)
                    ))
                }
                
                // リクエストパラメータのassertionを行う
                self.beforeCall?(_api)
                
                if case .success(let entity) = self.stub {
                    do {
                        let jsonEncoder = JSONEncoder()
                        jsonEncoder.dateEncodingStrategy = .iso8601
                        let data = try jsonEncoder.encode(entity)
                        let entity = try api.deserialize(data)
                        promise(.success(entity))
                    } catch let error {
                        promise(.failure(
                            ErrorWrapper.system(error: SystemErrors.test(.準備されたAPIスタブのEncodeまたはDecodeに失敗(stub: "\(entity)")), args: api.description(), causedBy: error)
                            )
                        )
                    }
                } else if case .failure(let errorWrapper) = self.stub {
                    promise(.failure(errorWrapper))
                }
            }
        }
        .handleEvents(
            receiveOutput: { entity in
                if let f = self.afterCall {
                    f(.success(entity: entity as! U.Entity))
                }
            }
            , receiveCompletion: { completion in
                if case .finished = completion {
                    print("\(api) は正常終了")
                } else if case .failure(let errorWrapper) = completion {
                    if let f = self.afterCall {
                        f(.failure(by: errorWrapper))
                    }
                }
            }
        )
        .eraseToAnyPublisher()
    }
}
