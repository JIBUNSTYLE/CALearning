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
        
//        let apiClient = MockApiClient<Apis.Udid>(
//            stub: .success(entity: Apis.Udid.Entity(udid: "hoge"))
//            , afterCall: { result in
//                print("● afterCall: \(result)")
//            })

//        let apiClient = MockApiClient<Apis.Udid>(
//            stub: .failure(by: ErrorWrapper<Apis.Udid>.service(error: .client(.ネットワーク接続不可), args: Apis.Udid(), causedBy: nil))
//            , afterCall: { result in
//                print("● afterCall: \(result)")
//            })
//        let backend = ApiBackend(apiClient: apiClient)
//        Dependencies.shared.set(backend: backend)
//
//        Application().discardUdid()
//
        
        Anyone()
            .interact(in: Boot())
            .sink { completion in
                if case .finished = completion {
                    print("boot は正常終了")
                } else if case .failure(let error) = completion {
                    switch error {
                    case let ErrorWrapper.service(error, args, causedBy):
                        print("サービスエラー発生:\(error), args:\(String(describing: args)), causedBy: \(String(describing: causedBy))")
                    case let ErrorWrapper.system(error, args, causedBy):
                        print("サービスエラー発生:\(error), args:\(String(describing: args)), causedBy: \(String(describing: causedBy))")
                    default:
                        print("boot が異常終了: \(error)")
                    }
                }
            } receiveValue: { scenario in
                print("usecase - boot: \(scenario)")
                
                guard case .last(let goal) = scenario.last else { fatalError() }
                    
                switch goal {
                case .チュートリアル完了の記録がある場合_アプリはログイン画面を表示:
                    self.currentView = .login
                case .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示:
                    self.currentView = .tutorial
                }
            }
            .store(in: &cancellables)
    }
}
