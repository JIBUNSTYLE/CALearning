//
//  ApiClient.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/02/01.
//

import Foundation
import Combine

protocol ApiClient {
    func call<T>(api: T) -> AnyPublisher<T.Entity, ErrorWrapper<T>> where T: Api
}
