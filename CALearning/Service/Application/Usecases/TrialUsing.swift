//
//  TrialUsing.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import Foundation
import Combine

/// ユースケース【お試し利用する】を実現します。
extension Usecases.TrialUsing {
    
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case .basic(.ユーザはログインしないで使うボタンを押下する):
            return self.just(next: .last(scene: .アプリはホーム画面を表示する))
            
        case .last:
            return nil
        }
    }
}
