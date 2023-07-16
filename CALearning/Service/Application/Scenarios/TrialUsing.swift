//
//  TrialUsing.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import Foundation
import Combine
import RobustiveSwift

/// ユースケース【お試し利用する】を実現します。
extension Usecases.TrialUsing : Scenario {
    
    func next(to currentScene: Scene<Self>, by actor: UsecaseActor) -> AnyPublisher<Scene<Self>, Error> {
        switch currentScene {
        case .basic(.ユーザはログインしないで使うボタンを押下する):
            return self.just(next: .last(scene: .アプリはホーム画面を表示する))
            
        case .last:
            fatalError()
        }
    }
}
