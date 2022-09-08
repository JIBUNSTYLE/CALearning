//
//  BootSpec.swift
//  CALearningTests
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import XCTest
@testable import CALearning

import Quick
import Nimble

class BootSpec: QuickSpec {

    override func spec() {
        let presenter = Controller()
        
        describe("アプリを起動する") {
            context("UDIDがない場合") {
                beforeEach {
                    presenter.currentView = .splash
                    Application().discardUdid()
                }
                it("アプリはUDIDを取得する") {
                    
                    waitUntil(timeout: .seconds(10)) { done in
                        
                        let mockApiClient = MockApiClient<Apis.Udid>(
                            stub: .success(entity: Apis.Udid.Entity(udid: "fugafuga"))
                            , afterCall: { result in
                                print("● afterCall: \(result)")
                                
                                if case .success(let entity) = result {
                                    expect(entity.udid).to(equal("fugafuga"))
                                } else if case .failure(_) = result {
                                    fail()
                                }
                                
                                done()
                            })
                        
                        let backend = ApiBackend(apiClient: mockApiClient)
                        Dependencies.shared.set(backend: backend)
                        
                        presenter.boot()
                    }
                }
            }
            context("チュートリアル完了の記録がある場合") {
                beforeEach {
                    presenter.currentView = .splash
                    Application().save(udid: "hogehoge")
                    Application().hasCompletedTutorial = true
                }
                it("アプリはログイン画面を表示") {
                    presenter.boot()
                    
                    expect(presenter.currentView)
                        .toEventually(equal(Views.login), timeout: .seconds(2))
                        
                }
            }
            context("チュートリアル完了の記録がない場合") {
                beforeEach {
                    presenter.currentView = .splash
                    Application().save(udid: "hogehoge")
                    Application().hasCompletedTutorial = false
                }
                it("アプリはチュートリアル画面を表示") {
                    presenter.boot()
                    
                    expect(presenter.currentView)
                        .toEventually(equal(Views.tutorial), timeout: .seconds(2))
                }
            }
        }
    }
}
