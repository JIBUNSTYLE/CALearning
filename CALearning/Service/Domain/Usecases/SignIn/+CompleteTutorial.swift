//
//  +CompleteTutorial.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2025/12/04.
//

import Foundation
import RobustiveSwift

extension R.SignIn {
    /// ユースケース【チュートリアルを完了する】を実現します。
    struct CompleteTutorial : Scenes {
        typealias UsecaseActor = UserActor
        
        enum Basics {
            case ユーザはチュートリアルを閉じる
            case アプリはチュートリアル完了を記録する
        }
        
        enum Alternatives {}
        
        enum Goals {
            case アプリはログイン画面を表示する
        }
    }
}
