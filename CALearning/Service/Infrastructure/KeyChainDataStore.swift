//
//  KeyChainDataStore.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/03/30.
//

import Foundation
import Security

struct KeyChainDataStore : DataStore {
    
    func save(_ keyValue: KeyValue) {
        
        switch keyValue {
        case .bool(let key, let value):
            guard let data = try? JSONEncoder().encode(value) else {
                fatalError()
            }
            
            let query = [
                kSecClass: kSecClassGenericPassword
                , kSecAttrAccount: key
                , kSecValueData: data
            ] as CFDictionary

            SecItemDelete(query)
            let resultStatus = SecItemAdd(query, nil)
            if resultStatus != errSecSuccess {
                print("saveに失敗")
            }
        
        case .string(let key, let value):
            guard let data = value.data(using: .utf8) else {
                fatalError()
            }
            
            let query = [
                kSecClass: kSecClassGenericPassword
                , kSecAttrAccount: key
                , kSecValueData: data
            ] as CFDictionary
            
            SecItemDelete(query)
            let resultStatus = SecItemAdd(query, nil)
            if resultStatus != errSecSuccess {
                print("saveに失敗")
            }
        }
    }
    
    func get<T: Key>(_ key: T) -> T.ValueType? {
        
        let query = [
            kSecClass: kSecClassGenericPassword
            , kSecAttrAccount: key.rawValue
            , kSecReturnData: kCFBooleanTrue as Any
            , kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        let resultStatus = SecItemCopyMatching(query, &result)
        
        guard resultStatus == noErr else {
            return nil
        }

        guard let data = result as? Data else {
            return nil
        }
        
        switch key {
        case is KeyValue.BoolKey:
            guard let value = try? JSONDecoder().decode(Bool.self, from: data) else {
                return nil
            }
            return value as? T.ValueType
            
        case is KeyValue.StringKey:
            return String(data: data, encoding: .utf8) as? T.ValueType

        default:
            return nil
        }
    }
    
    func delete<T: Key>(_ key: T) {
        
        let query = [
            kSecClass: kSecClassGenericPassword
            , kSecAttrAccount: key.rawValue
        ] as CFDictionary
        
        let resultStatus = SecItemDelete(query)
        if resultStatus != errSecSuccess {
            print("\(key)の削除に失敗")
        }
    }
}
