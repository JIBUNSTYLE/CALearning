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
   
    init(
        dataStore: DataStore = UserDefaultsDataStore()
    ) {
        self.dataStore = dataStore
    }
    
    /// mockなどを差し込む際に使う
    func set(mock: Dependencies) {
        Dependencies.shared = mock
    }
}
