//
//  Location.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/09/26.
//

import Foundation
import CoreLocation

enum LocationAuthorizationStatus: Equatable {
    // 正確な位置情報許可設定
    enum AccuracyAuthorization {
        // 正確な位置情報が許可されている場合
        case full
        // 正確な位置情報が許可されていない場合
        case reduced
        
        init(from accuracyAuthorization: CLAccuracyAuthorization) {
            switch accuracyAuthorization {
            case .fullAccuracy:
                self = .full
            case .reducedAccuracy:
                self = .reduced
            @unknown default:
                fatalError("未実装の値【\(accuracyAuthorization)】が連携されました。実装を追加して下さい。")
            }
        }
    }
    
    // 位置情報が常に取れる場合
    case authorizedAlways(accuracy: AccuracyAuthorization)
    // 位置情報が一時的に取れる場合
    case authorizedWhenInUse(accuracy: AccuracyAuthorization)
    //　未決定の場合
    case notDetermined
    // 制限されている場合
    case restricted
    // 拒否された場合
    case denied
    
    
    init(from authorizationStatus: CLAuthorizationStatus, with accuracyAuthorization: CLAccuracyAuthorization) {
        switch authorizationStatus {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .authorizedAlways:
            self = .authorizedAlways(accuracy: AccuracyAuthorization(from: accuracyAuthorization))
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse(accuracy: AccuracyAuthorization(from: accuracyAuthorization))
        @unknown default:
            fatalError("未実装の値【\(authorizationStatus)】が連携されました。実装を追加して下さい。")
        }
    }
}
