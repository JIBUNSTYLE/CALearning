//
//  Usecases.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/09/02.
//

import Foundation

enum UsecaseStatus {
    case idle
    case executing(usecase: Usecases, startAt: Date)
    
    var isExecuting: Bool {
        if case .idle = self {
            return false
        }
        return true
    }
    
    var elapsedTime: TimeInterval {
        guard case let .executing(_, startAt) = self else {
            return -1
        }
        // 開始からの経過秒数を取得する
        return Date().timeIntervalSince(startAt)
    }
    
    func printElapsedTime() {
        guard case let .executing(usecase, startAt) = self else {
            print("no usecase is executed.")
            return
        }
        // 開始からの経過秒数を取得する
        let elapsedTime = Date().timeIntervalSince(startAt)
        
        print("usecase \(usecase) takes \(elapsedTime) seconds.")
    }
}

enum Usecases {
    
    /// ユースケース【アプリを起動する】を実現します。
    enum Booting : Usecase {
        
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
        
        case basic(scene: Basics)
        case alternate(scene: Alternatives)
        case last(scene: Goals)
    }
    
    /// ユースケース【チュートリアルを完了する】を実現します。
    enum CompleteTutorial : Usecase {
        
        enum Basics {
            case ユーザはチュートリアルを閉じる
            case アプリはチュートリアル完了を記録する
        }
        
        enum Alternatives {}
        
        enum Goals {
            case アプリはログイン画面を表示する
        }
        
        case basic(scene: Basics)
        case alternate(scene: Alternatives)
        case last(scene: Goals)
        
    }
    
    /// ユースケース【ログインする】を実現します。
    enum LoggingIn : Usecase {
        
        enum Basics {
            case ユーザはログインボタンを押下する(id: String?, password: String?)
            case アプリは入力が正しいかを確認する(id: String?, password: String?)
            case 入力が正しい場合_アプリはログインを試行する(id: String, password: String)
        }
        
        enum Alternatives {
            //        case UDIDがない場合_アプリはUDIDを取得する
        }
        
        enum Goals {
            case 入力が正しくない場合_アプリはログイン画面にエラー内容を表示する(result: LoginValidationResult)
            case ログイン認証に成功した場合_アプリはホーム画面を表示する(user: Account)
            case ログイン認証に失敗した場合_アプリはログイン画面にエラー内容を表示する(error: ServiceErrors)
            case 予期せぬエラーが発生した場合_アプリはログイン画面にエラー内容を表示する(error: SystemErrors)
        }
        
        case basic(scene: Basics)
        case alternate(scene: Alternatives)
        case last(scene: Goals)
    }
    
    case booting(from: Booting)
    case completeTutorial(from: CompleteTutorial)
    case loggingIn(from: LoggingIn)
}
