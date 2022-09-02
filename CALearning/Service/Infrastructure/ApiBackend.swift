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
    
    init() throws {
        do {
            self.apiClient = try AlamofireApiClient()
        }
    }
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func publishUdid() -> AnyPublisher<String, ErrorWrapper> {
        self.apiClient.call(api: Apis.Udid())
            .map { response in
                return response.udid
            }
            .eraseToAnyPublisher()
    }
    
    func login(with id: String, and password: String) -> AnyPublisher<Account, ErrorWrapper> {
        return Just(Account(mailAddress: "hoge"))
            .setFailureType(to: ErrorWrapper.self)
            .eraseToAnyPublisher()
    }
}

