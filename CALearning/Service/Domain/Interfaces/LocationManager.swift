//
//  LocationManager.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/09/26.
//

import Foundation

protocol LocationManager {
    func requestAuthorization()
    func requestAlwaysAuthorization()
}
