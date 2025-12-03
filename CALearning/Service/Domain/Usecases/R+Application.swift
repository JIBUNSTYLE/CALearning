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
        case booting(from: Scene<Booting>)
        case closeDialog(from: Scene<CloseDialog>)
    }
}
