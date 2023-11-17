//
//  Purchase.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import Foundation
import Combine
import RobustiveSwift

/// ユースケース【購入する】を実現します。
extension Domains.Shopping.Usecases.Purchase : Scenario {
    
    func next(to currentScene: Scene<Self>, by actor: UsecaseActor) -> AnyPublisher<Scene<Self>, Error> {
        switch currentScene {
        case .basic(.ユーザは購入ボタンを押下する):
            return self.just(next: .last(scene: .アプリは購入確認画面を表示する))
            
        case .last:
            fatalError()
        }
    }
}
