//
//  CompleteTutorial.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/04/27.
//

import Foundation
import Combine

/// ユースケース【チュートリアルを完了する】を実現します。
extension Usecases.CompleteTutorial {
    
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case .basic(.ユーザはチュートリアルを閉じる):
            return self.just(next: .basic(scene: .アプリはチュートリアル完了を記録する))
            
        case .basic(.アプリはチュートリアル完了を記録する):
            return self.save()
            
        case .last:
            return nil
        }
    }
    
    private func save() -> AnyPublisher<Self, Error> {
        return Deferred {
            Future<Self, Error> { promise in
                Application().hasCompletedTutorial = true
                promise(.success(.last(scene: .アプリはログイン画面を表示する)))
            }
        }
        .eraseToAnyPublisher()
    }
    
}
