//
//  StopLoggingIn.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/06.
//

import Foundation
import Combine

/// ユースケース【ログインをやめる】を実現します。
extension Usecases.StopLoggingIn {
    
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case .basic(.ユーザはキャンセルボタンを押下する):
            return self.just(next: .last(scene: .アプリはログインモーダルを閉じる))
            
        case .last:
            return nil
        }
    }
}
