//
//  DataStore.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/26.
//

import Foundation

protocol Key: CaseIterable, RawRepresentable where Self.RawValue == String {
    associatedtype ValueType
}

enum KeyValue {

    enum BoolKey: String, Key {
        typealias ValueType = Bool
        case hasCompletedTutorial
    }
    
    enum StringKey: String, Key {
        typealias ValueType = String
        case udid
    }
    
    case bool(key: BoolKey, value: BoolKey.ValueType)
    case string(key: StringKey, value: StringKey.ValueType)
}

protocol DataStore {

    /// データの保存
    func save(_ keyValue: KeyValue)

    /// データの取り出し
    func get<T: Key>(_ key: T) -> T.ValueType?

    /// データの削除
    func delete<T: Key>(_ key: T)
}
