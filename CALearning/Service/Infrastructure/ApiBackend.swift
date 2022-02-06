//
//  ApiBackend.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/03.
//

import Foundation
import Combine

struct ApiBackend : Backend {
    
    let apiClient: ApiClient
    
    init(apiClient: ApiClient? = nil) throws {
        if let a = apiClient {
            self.apiClient = a
        } else {
            do {
                self.apiClient = try AlamofireApiClient()
            }
        }
    }
    
    func publishUdid() -> AnyPublisher<String, Error> {
        self.apiClient.call(api: Apis.Udid())
            .map { response in
                return response.udid
            }
            .mapError { errorWrapper in
                return errorWrapper
            }
            .eraseToAnyPublisher()
    }
}

