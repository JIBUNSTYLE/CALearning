//
//  Usecases.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/09/02.
//

import Foundation
import RobustiveSwift

enum UsecaseStatus {
    case idle
    case executing(usecase: Usecases, file: String, line: Int, function: String, startAt: Date)
    
    var isExecuting: Bool {
        if case .idle = self {
            return false
        }
        return true
    }
    
    var elapsedTime: TimeInterval {
        guard case let .executing(_, _, _, _, startAt) = self else {
            return -1
        }
        // 開始からの経過秒数を取得する
        return Date().timeIntervalSince(startAt)
    }
    
    func printElapsedTime(_ msg: String? = nil, efile: String = #file, eline: Int = #line, efunction: String = #function) {
        guard case let .executing(usecase, sfile, sline, sfunction, startAt) = self else {
            print("no usecase is executed.")
            return
        }
        
        guard let _f = sfile.components(separatedBy: "/").last else { return }
        let sf = _f.replacingOccurrences(of: ".swift", with: "")
        
        guard let _f = efile.components(separatedBy: "/").last else { return }
        let ef = _f.replacingOccurrences(of: ".swift", with: "")
        // 開始からの経過をミリ秒で取得する
        let elapsedTime = String.init(format: "%9.4f", (Date().timeIntervalSince(startAt) * 1000000) / 1000)
        
        if let msg = msg {
            print("Usecase \(usecase) takes \(elapsedTime) msecs from \(sf):L\(sline) [\(sfunction)] to \(ef):L\(eline) [\(efunction)] \(msg)")
        } else {
            print("Usecase \(usecase) takes \(elapsedTime) msecs from \(sf):L\(sline) [\(sfunction)] to \(ef):L\(eline) [\(efunction)]")
        }
    }
}
    
enum Usecases {
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

    /// ユースケース【ログインをやめる】を実現します。
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
    case completeTutorial(from: Scene<CompleteTutorial>)
    case signingIn(from: Scene<SigningIn>)
    case stopSigningIn(from: Scene<StopSigningIn>)
    case trialUsing(from: Scene<TrialUsing>)
    case purchase(from: Scene<Purchase>)
    case closeDialog(from: Scene<CloseDialog>)
}
