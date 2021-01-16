//
//  LocalPersistence.swift
//  RxCircuitBreaker
//
//  Created by Yair Carreno on 14/01/21.
//

import Foundation

protocol LocalPersistence {
    func getTime(key: String) -> Double
    func saveTime(key: String, time: Double)
}
