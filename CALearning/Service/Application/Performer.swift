//
//  Performer.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine

class Performer: ObservableObject {
    
    @Published private(set) var currentView: Views = .splash {
        didSet {
            print("===fff=== \(oldValue), \(currentView)")
        }
    }
    
    private var cancellables = [AnyCancellable]()
    
    func boot(from initialScene: Boot) {
        initialScene
            .interacted()
            .sink { completion in
                if case .finished = completion {
                    print("boot は正常終了")
                } else if case .failure(let error) = completion {
                    print("boot が異常終了: \(error)")
                }
            } receiveValue: { scenario in
                print("usecase - boot: \(scenario)")
                
                guard case let .last(scene) = scenario.last else { fatalError() }
                
                switch scene {
                case .完了済の場合_アプリはログイン画面を表示する:
                    self.currentView = .login
                    print("======= \(self.currentView), \(Views.login)")

                case .完了済でない場合_アプリはチュートリアル画面を表示する:
                    self.currentView = .tutorial
                }
            }
            .store(in: &cancellables)
    }
}
