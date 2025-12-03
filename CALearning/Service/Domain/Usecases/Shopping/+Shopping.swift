//
//  +Shopping.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2025/12/04.
//

import Foundation
import RobustiveSwift

extension R.Shopping {
    /// ユースケース【購入する】を実現します。
    struct Purchase : Scenes {
        typealias UsecaseActor = UserActor
        
        enum Basics {
            case ユーザは購入ボタンを押下する
        }
        
        enum Alternatives {}
        
        enum Goals {
            case アプリは購入確認画面を表示する
        }
    }
}
