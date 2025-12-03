//
//  CLLocationManagerWrapper.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/09/26.
//

import Foundation
import CoreLocation
import Combine

class CLLocationManagerWrapper : NSObject, LocationManager {

    private let manager: CLLocationManager
    private let authorizationStatusSubject: CurrentValueSubject<LocationAuthorizationStatus, Never>
//    private let currentLocationSubject: CurrentValueSubject<CurrentLocation?, Never> = .init(nil)
    
//    var authorizationStatus: LocationAuthorizationStatus {
//        return LocationAuthorizationStatus(from: self.manager.authorizationStatus, with: self.manager.accuracyAuthorization)
//    }
//    
//    var authorizationStatusPublisher: AnyPublisher<LocationAuthorizationStatus, Never> {
//        return self.authorizationStatusSubject
//            .eraseToAnyPublisher()
//    }
    
//    var currentLocationPublisher: AnyPublisher<CurrentLocation, Never> {
//        return self.currentLocationSubject
//            .handleEvents(
//                receiveCancel: {
//                    // cancelされたらポーリングも停止
//                    self.manager.stopUpdatingLocation()
//                }, receiveRequest: { _ in
//                    // sinkと同時にポーリングスタート
//                    if !IS_TEST {
//                        // テスト時には実行しない
//                        self.manager.startUpdatingLocation()
//                    }
//                })
//            .compactMap { $0 } // location が nil の場合は send しないようにする
//            .eraseToAnyPublisher()
//    }
   
    override init() {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        self.manager = manager
        self.authorizationStatusSubject = .init(LocationAuthorizationStatus(from: manager.authorizationStatus, with: manager.accuracyAuthorization))

        super.init()
        
        manager.delegate = self
    }
    
    func requestAuthorization() {
        print("位置情報の利用許諾ダイアログを表示します...")
        self.manager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        print("バックグラウンド状態での位置情報の利用許諾ダイアログを表示します...")
        self.authorizationStatusSubject.value = .notDetermined
        self.manager.requestAlwaysAuthorization()
    }
}

// MARK: -　CLLocationManagerDelegateの実装
extension CLLocationManagerWrapper : CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        self.authorizationStatusSubject
//            .send(LocationAuthorizationStatus(from: manager.authorizationStatus, with: manager.accuracyAuthorization))
    }

//    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        self.currentLocationSubject.value = CurrentLocation(from: location)
//    }
}

