//
//  Requirements.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/09/02.
//

import Foundation
import RobustiveSwift

enum UsecaseStatuses {
    case idle
    case executing(usecase: Requirements, file: String, line: Int, function: String, startAt: Date)
    
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

enum Requirements {
    
    enum Application {
        case booting(from: Scene<Booting>)
        case closeDialog(from: Scene<CloseDialog>)
    }
    
    enum SignIn {
        case completeTutorial(from: Scene<CompleteTutorial>)
        case signingIn(from: Scene<SigningIn>)
        case stopSigningIn(from: Scene<StopSigningIn>)
        case trialUsing(from: Scene<TrialUsing>)
    }
    
    enum Shopping {
        case purchase(from: Scene<Purchase>)
    }
    
    case application(usecase: Application)
    case signIn(usecase: SignIn)
    case shopping(usecase: Shopping)
}

typealias R = Requirements
