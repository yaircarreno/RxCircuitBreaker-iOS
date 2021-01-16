//
//  UserDefaultsStorage.swift
//  RxCircuitBreaker
//
//  Created by Yair Carreno on 14/01/21.
//

import Foundation

struct UserDefaultsStorage: LocalPersistence {

    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getTime(key: String) -> Double {
        return userDefaults.value(forKey: key) as! Double
    }

    func saveTime(key: String, time: Double) {
        self.userDefaults.setValue(time, forKey: key)
    }
}
