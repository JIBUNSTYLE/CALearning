//
//  R+Application.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2025/12/03.
//
import Foundation
import RobustiveSwift

extension R {
    
    enum Application {
        /// ユースケース【アプリを起動する】を実現します。
        struct Booting : Scenes {
            typealias UsecaseActor = UserActor
            
            enum Basics {
                case ユーザはアプリを起動する
                case アプリはサーバで発行したUDIDが保存されていないかを調べる
                case UDIDがある場合_アプリはユーザがチュートリアルを完了した記録がないかを調べる(udid: String)
            }
            
            enum Alternatives {
                case UDIDがない場合_アプリはUDIDを取得する
            }
            
            enum Goals {
                case UDIDの発行に失敗した場合_アプリはリトライダイアログを表示する(error: SystemErrors)
                case チュートリアル完了の記録がある場合_アプリはログイン画面を表示(udid: String)
                case チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示(udid: String)
            }
        }
        
        /// ユースケース【ダイアログを閉じる】を実現します。
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
        
        case booting(from: Scene<Booting>)
        case closeDialog(from: Scene<CloseDialog>)
    }
}
