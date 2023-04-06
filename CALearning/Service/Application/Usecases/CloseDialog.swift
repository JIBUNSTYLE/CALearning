//
//  CloseDialog.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/06.
//

import Foundation
import Combine

/// ユースケース【ダイアログを閉じる】を実現します。
extension Usecases.CloseDialog {
    
    func next() -> AnyPublisher<Self, Error>? {
        switch self {
        case .basic(.ユーザはOKボタンを押下する):
            return self.just(next: .last(scene: .アプリはダイアログを閉じる))
            
        case .last:
            return nil
        }
    }
}
