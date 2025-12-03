//
//  +TrialUsing.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2025/12/04.
//

import Foundation
import RobustiveSwift

extension R.SignIn {
    /// ユースケース【お試し利用する】を実現します。
    struct TrialUsing : Scenes {
        typealias UsecaseActor = UserActor
        
        enum Basics {
            case ユーザはログインしないで使うボタンを押下する
        }
        
        enum Alternatives {}
        
        enum Goals {
            case アプリはホーム画面を表示する
        }
    }
}
