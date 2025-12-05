//
//  +CloseDialog.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2025/12/04.
//

import Foundation
import RobustiveSwift

extension R.Application {
    /// ユースケース【ダイアログを閉じる】のシーン一覧
    struct CloseDialog : Scenes {
        typealias UsecaseActor = UserActor
        
        enum Basics {
            case ユーザはOKボタンを押下する
        }
        
        enum Alternatives {}
        
        enum Goals {
            case アプリはダイアログを閉じる
        }
    }
}
