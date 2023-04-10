//
//  StopLoggingIn.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/06.
//

import Foundation
import Combine
import RobustiveSwift

/// ユースケース【ログインをやめる】を実現します。
extension Usecases.StopLoggingIn : Scenario {
    
    func next(to currentScene: Usecase<Self>) -> AnyPublisher<Usecase<Self>, Error>? {
        switch currentScene {
        case .basic(.ユーザはキャンセルボタンを押下する):
            return self.just(next: .last(scene: .アプリはログインモーダルを閉じる))
            
        case .last:
            return nil
        }
    }
}
