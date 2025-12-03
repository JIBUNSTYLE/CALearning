//
//  +SigningIn.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2025/12/04.
//

import Foundation
import RobustiveSwift

extension R.SignIn {
    /// ユースケース【ログインする】を実現します。
    struct SigningIn : Scenes {
        typealias UsecaseActor = UserActor
        
        enum Basics {
            case ユーザはログインボタンを押下する(id: String?, password: String?)
            case アプリは入力が正しいかを確認する(id: String?, password: String?)
            case 入力が正しい場合_アプリはログインを試行する(id: String, password: String)
        }
        
        enum Alternatives {
//        case UDIDがない場合_アプリはUDIDを取得する
        }
        
        enum Goals {
            case 入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(result: SignInValidationResult)
            case ログイン認証に成功した場合_アプリはホーム画面を表示する(user: Account)
            case ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error: ServiceErrors)
            case 予期せぬエラーが発生した場合_アプリはログイン画面にエラー内容を表示する(error: SystemErrors)
        }
    }
}
