//
//  CircuitBreakersManager.swift
//  RxCircuitBreaker
//
//  Created by Yair Carreno on 14/01/21.
//

import Foundation
import RxSwift

class CircuitBreakersManager {

    private var circuitBreakerDirectory: [String: CircuitBreaker] = [:]

    public static func callWithCircuitBreaker(_ service: Single<Any>,
                                              _ circuitBreaker: CircuitBreaker) -> Single<Any> {
        return circuitBreaker.callService(service)
    }

    public func getCircuitBreaker(_ nameCircuitBreaker: String,
                                  _ localPersistence: LocalPersistence) -> CircuitBreaker {
        guard let circuitBreaker = circuitBreakerDirectory[nameCircuitBreaker] else {
            circuitBreakerDirectory[nameCircuitBreaker] = CircuitBreaker(name: nameCircuitBreaker,
                                                                         localPersistence: localPersistence)
            return circuitBreakerDirectory[nameCircuitBreaker]!
        }
        return circuitBreaker
    }
}
