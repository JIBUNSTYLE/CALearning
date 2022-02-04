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
    var dataStore: DataStore
    var backend: Backend
   
    init(
        dataStore: DataStore = UserDefaultsDataStore()
        , backend: Backend = ApiBackend(apiClient: nil)
    ) {
        self.dataStore = dataStore
        self.backend = backend
    }
    
    /// mockなどを差し込む際に使う
    func set(mock: Dependencies) {
        Dependencies.shared = mock
    }
}
