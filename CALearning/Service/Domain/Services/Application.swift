//
//  Application.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import Foundation
import Combine

class Application : Service {
    
    var hasCompletedTutorial: Bool {
        get {
            if let value = Dependencies.shared.dataStore.get(KeyValue.BoolKey.hasCompletedTutorial) {
                return value
            } else {
                return false
            }
        }
        set {
            Dependencies.shared.dataStore.save(
                .bool(key: .hasCompletedTutorial, value: newValue)
            )
        }
    }
    
    private(set) var udid: String? {
        get {
            return Dependencies.shared.dataStore.get(KeyValue.StringKey.udid)
        }
        set {
            guard let udid = newValue else {
                return Dependencies.shared.dataStore.delete(KeyValue.StringKey.udid)
            }
            Dependencies.shared.dataStore.save(
                .string(key: .udid, value: udid)
            )
        }
    }
    
    func publishUdid() -> AnyPublisher<String, ErrorWrapper> {
        return Dependencies.shared.backend.publishUdid()
    }
    
    func save(udid: String) -> Void {
        self.udid = udid
    }
    
    func discardUdid() -> Void {
        print("保存されたUDIDを消します")
        self.udid = nil
    }
}