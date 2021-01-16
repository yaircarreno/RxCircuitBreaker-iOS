//
//  CircuitBreakerState.swift
//  RxCircuitBreaker
//
//  Created by Yair Carreno on 14/01/21.
//

import Foundation

enum CircuitBreakerState: Events {

    case closed, halfOpen, open

    mutating func sucess() -> CircuitBreakerState {
        switch self {
        case .closed, .halfOpen:
            return CircuitBreakerState.closed
        case .open:
            return CircuitBreakerState.halfOpen
        }
    }

    mutating func fail() -> CircuitBreakerState {
        return CircuitBreakerState.open
    }
}

protocol Events {
    mutating func sucess() -> CircuitBreakerState
    mutating func fail() -> CircuitBreakerState
}
