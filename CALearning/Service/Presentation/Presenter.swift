//
//  Presenter.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine

class Presenter: ObservableObject {
    
    @Published var currentView: Views = .splash
    
    private var cancellables = [AnyCancellable]()
    
    func boot() {
        Boot()
            .interact()
            .sink { completion in
                if case .finished = completion {
                    print("boot は正常終了")
                } else if case .failure(let error) = completion {
                    print("boot が異常終了: \(error)")
                }
            } receiveValue: { scenario in
                print("usecase - boot: \(scenario)")
                
                if case .basic(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示) = scenario.last {
                    self.currentView = .login

                } else if case .alternate(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示) = scenario.last {
                    self.currentView = .tutorial
                }
            }
            .store(in: &cancellables)
    }
}
