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
    
    func next(to currentScene: Scene<Self>, by actor: UsecaseActor) -> AnyPublisher<Scene<Self>, Error> {
        switch currentScene {
        case .basic(.ユーザはチュートリアルを閉じる):
            return self.just(next: .basic(scene: .アプリはチュートリアル完了を記録する))
            
        case .basic(.アプリはチュートリアル完了を記録する):
            return self.save()
            
        case .last:
            fatalError()
        }
    }
    
    private func save() -> AnyPublisher<Scene<Self>, Error> {
        return Deferred {
            Future<Scene<Self>, Error> { promise in
                Application().hasCompletedTutorial = true
                promise(.success(.last(scene: .アプリはログイン画面を表示する)))
            }
        }
        .eraseToAnyPublisher()
    }
    
}
