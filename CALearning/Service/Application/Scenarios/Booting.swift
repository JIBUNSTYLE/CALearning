//
//  Booting.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine
import RobustiveSwift

/// ユースケース【アプリを起動する】を実現します。
extension Usecases.Booting : Scenario {
    
    func next(to currentScene: Usecase<Self>, by actor: UsecaseActor) -> AnyPublisher<Usecase<Self>, Error> {
        switch currentScene {
        case .basic(scene: .ユーザはアプリを起動する):
            return self.just(next: .basic(scene: .アプリはサーバで発行したUDIDが保存されていないかを調べる))
            
        case .basic(.アプリはサーバで発行したUDIDが保存されていないかを調べる):
            return self.checkUdid()
            
        case let .basic(.UDIDがある場合_アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid)):
            return self.detect(udid: udid)

        case .alternate(.UDIDがない場合_アプリはUDIDを取得する):
            return self.publishUdid()
            
        case .last:
            fatalError()
        }
    }
    
    private func checkUdid() -> AnyPublisher<Usecase<Self>, Error> {
        return Deferred {
            Future<Usecase<Self>, Error> { promise in
                guard let udid = Application().udid else {
                    return promise(.success(.alternate(scene: .UDIDがない場合_アプリはUDIDを取得する)))
                }
                promise(.success(.basic(scene: .UDIDがある場合_アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: udid))))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func detect(udid: String) -> AnyPublisher<Usecase<Self>, Error> {
        // Deferredでsubscribesされてから実行されるようになる
        // Futureは一度だけ結果を返す
        return Deferred {
            Future<Usecase<Self>, Error> { promise in
                // Futureが非同期になる場合、sinkする側ではcancellableをstoreしておかないと、
                // 非同期処理が終わる前にsubsciptionはキャンセルされてしまうので注意
                // @see: https://forums.swift.org/t/combine-future-broken/28560/2
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if Application().hasCompletedTutorial {
                        promise(.success(.last(scene: .チュートリアル完了の記録がある場合_アプリはログイン画面を表示(udid: udid))))
                    } else {
                        promise(.success(.last(scene: .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示(udid: udid))))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func publishUdid() -> AnyPublisher<Usecase<Self>, Error> {
        return Application()
            .publishUdid()
            .map { udid -> Usecase<Self> in
                Application().save(udid: udid)
                return .basic(scene: .UDIDがある場合_アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: udid))
            }
            .catch { errorWrapper -> AnyPublisher<Usecase<Self>, Error> in
                switch (errorWrapper) {
                case .service(_, _, _):
                    fatalError()

                case let .system(error, _, _):
                    return self.just(next: .last(scene: .UDIDの発行に失敗した場合_アプリはリトライダイアログを表示する(error: error)))
                }
            }
            .eraseToAnyPublisher()
    }
}
