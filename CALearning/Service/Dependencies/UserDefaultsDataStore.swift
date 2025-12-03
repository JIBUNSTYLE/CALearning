//
//  UserDefaultsDataStore.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/26.
//

import Foundation

struct UserDefaultsDataStore : DataStore {
    
    func save(_ keyValue: KeyValue) {
        switch keyValue {
        case .bool(let key, let value):
            UserDefaults.standard.set(value, forKey: key.rawValue)
        case .string(let key, let value):
            UserDefaults.standard.set(value, forKey: key.rawValue)
        }
    }
    
    func get<T: Key>(_ key: T) -> T.ValueType? {
        return UserDefaults.standard
            .object(forKey: key.rawValue) as? T.ValueType
    }
    
    func delete<T: Key>(_ key: T) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
