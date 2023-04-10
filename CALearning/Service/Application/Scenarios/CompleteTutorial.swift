//
//  CompleteTutorial.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/04/27.
//

import Foundation
import Combine
import RobustiveSwift

/// ユースケース【チュートリアルを完了する】を実現します。
extension Usecases.CompleteTutorial : Scenario {
    
    func next(to currentScene: Usecase<Self>) -> AnyPublisher<Usecase<Self>, Error>? {
        switch currentScene {
        case .basic(.ユーザはチュートリアルを閉じる):
            return self.just(next: .basic(scene: .アプリはチュートリアル完了を記録する))
            
        case .basic(.アプリはチュートリアル完了を記録する):
            return self.save()
            
        case .last:
            return nil
        }
    }
    
    private func save() -> AnyPublisher<Usecase<Self>, Error> {
        return Deferred {
            Future<Usecase<Self>, Error> { promise in
                Application().hasCompletedTutorial = true
                promise(.success(.last(scene: .アプリはログイン画面を表示する)))
            }
        }
        .eraseToAnyPublisher()
    }
    
}
