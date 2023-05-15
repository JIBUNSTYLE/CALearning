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
        describe("アプリを起動する") {
            context("ユーザはHome画面でアイコンを選択する") {
                context("アプリはチュートリアル完了済かを確認する") {
                    context("完了済の場合") {
                        let performer = Performer()
                        beforeEach {
                            Application().hasCompletedTutorial = true
                        }
                        it("アプリはログイン画面を表示する") {
                            performer.boot(from:.basic(scene: .ユーザはHome画面でアイコンを選択する))
                            
                            expect(performer.currentView)
                                .toEventually(equal(Views.login), timeout: .seconds(3)) // Bootで2秒待たせているので、それより長くすること
                                
                        }
                    }
                    context("完了済でない場合") {
                        let performer = Performer()
                        beforeEach {
                            Application().hasCompletedTutorial = false
                        }
                        it("アプリはチュートリアル画面を表示する") {
                            performer.boot(from:.basic(scene: .ユーザはHome画面でアイコンを選択する))
                            
                            expect(performer.currentView)
                                .toEventually(equal(Views.tutorial), timeout: .seconds(3)) // Bootで2秒待たせているので、それより長くすること
                        }
                    }
                }
            }
        }
    }
}
