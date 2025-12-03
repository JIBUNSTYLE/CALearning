//
//  R+SignIn.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2025/12/04.
//

import Foundation
import RobustiveSwift

extension R {
    
    enum SignIn {
        case completeTutorial(from: Scene<CompleteTutorial>)
        case signingIn(from: Scene<SigningIn>)
        case stopSigningIn(from: Scene<StopSigningIn>)
        case trialUsing(from: Scene<TrialUsing>)
    }
}
