//
//  Dependencies.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/26.
//

import Foundation

struct Dependencies {
    // シングルトン
    static private(set) var shared: Dependencies = Dependencies()
    
    // 依存性逆転が必要なものが増えたら足していく
    private(set) var dataStore: DataStore
    private(set) var backend: Backend
    private(set) var locationManager: LocationManager
   
    init(
        dataStore: DataStore = UserDefaultsDataStore()
        , backend: Backend? = nil
        , locationManager: LocationManager = CLLocationManagerWrapper()
    ) {
        self.dataStore = dataStore
        self.locationManager = locationManager
        
        if let b = backend {
            self.backend = b
        } else {
            do {
                self.backend = try ApiBackend()
            } catch let error {
                // 在るべきはPreesntation層まで伝えてダイアログ表示などが適切
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// mockなどを差し込む際に使う
    func set(
        dataStore: DataStore? = nil
        , backend: Backend? = nil
        , locationManager: LocationManager? = nil
    ) {
        if let d = dataStore { Dependencies.shared.dataStore = d }
        if let b = backend { Dependencies.shared.backend = b }
        if let l = locationManager { Dependencies.shared.locationManager = l }
    }
}
