//
//  GoogleMapApiClient.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/30.
//

import Foundation
import Combine

protocol GoogleMapApiClient {
    func call<T>(api: T) -> AnyPublisher<T.Entity, ErrorWrapper> where T: Api
}
