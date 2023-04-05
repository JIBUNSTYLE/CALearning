//
//  Purchase.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import Foundation
import Combine

/// ユースケース【購入する】を実現します。
extension Usecases.Purchase {
    
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case .basic(.ユーザは購入ボタンを押下する):
            return self.just(next: .last(scene: .アプリは購入確認画面を表示する))
            
        case .last:
            return nil
        }
    }
}
