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
    
    init(apiClient: ApiClient?) {
        if let apiClient = apiClient {
            self.apiClient = apiClient
        } else {
            do {
                self.apiClient = try AlamofireApiClient()
            } catch {
                fatalError()
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

