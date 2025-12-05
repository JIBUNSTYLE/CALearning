//
//  +StopSigningIn.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2025/12/04.
//

import Foundation
import RobustiveSwift

extension R.SignIn {
    /// ユースケース【ログインをやめる】のシーン一覧
    struct StopSigningIn : Scenes {
        typealias UsecaseActor = UserActor
        
        enum Basics {
            case ユーザはキャンセルボタンを押下する
       }
        
        enum Alternatives {}
        
        enum Goals {
            case アプリはログインモーダルを閉じる
        }
    }
}
