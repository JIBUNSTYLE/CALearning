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
        let actionCreator = ActionCreator()
        let store = SplashViewStore.shared
        
        describe("アプリを起動する") {
            context("チュートリアル完了の記録がある場合") {
                beforeEach {
                    store.currentView = .splash
                    Application().hasCompletedTutorial = true
                }
                it("アプリはログイン画面を表示") {
                    actionCreator.boot()
                    expect(store.currentView)
                        .toEventually(equal(Views.login), timeout: .seconds(2))
                        
                }
            }
            context("チュートリアル完了の記録がない場合") {
                beforeEach {
                    store.currentView = .splash
                    Application().hasCompletedTutorial = false
                }
                it("アプリはチュートリアル画面を表示") {
                    actionCreator.boot()
                    expect(store.currentView)
                        .toEventually(equal(Views.tutorial), timeout: .seconds(2))
                }
            }
        }
    }
}
