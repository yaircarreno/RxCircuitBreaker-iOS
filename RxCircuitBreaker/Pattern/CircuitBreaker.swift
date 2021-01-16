//
//  CircuitBreaker.swift
//  RxCircuitBreaker
//
//  Created by Yair Carreno on 14/01/21.
//

import Foundation
import RxSwift

class CircuitBreaker {

    var name: String
    var localPersistence: LocalPersistence

    var status = CircuitBreakerState.closed
    var resetTimeout = 5
    var callTimeout = 2
    var attempt = 3
    let serialScheduler = SerialDispatchQueueScheduler(qos: .default)

    init(name: String, localPersistence: LocalPersistence) {
        self.name = name
        self.localPersistence = localPersistence
    }

    public func callService(_ service: Single<Any>) -> Single<Any> {
        switch self.status {
        case .open:
            return openActions()
        case .closed, .halfOpen:
            return closeActions(service)
        }
    }

    private func openActions() -> Single<Any> {
        if (shouldBeAttemptReset()) {
            attemptReset()
        } else {
            callFast()
        }
        return Single.error(CircuitBreakerOpen.runtimeError("Sorry!, CircuitBreaker is open"))
    }

    private func closeActions(_ observable: Single<Any>) -> Single<Any> {
        return observable
            .timeout(RxTimeInterval.seconds(self.callTimeout), scheduler: self.serialScheduler)
            .retry(self.attempt)
            .catch({ error in Single.error(error)})
            .do(onSuccess: { ignore in self.success() },
                onError: { error in self.trip()})
    }

    private func trip() {
        print("CircuitBreaker is now open, and will not closed for \(resetTimeout) seconds")
        self.status = status.fail()
        saveTimeWhenOpenOccurs()
    }

    private func success() {
        print("CircuitBreaker still closed")
        self.status = status.sucess()
    }

    private func attemptReset() {
        print("CircuitBreaker is going to be half open, this is attempt reset")
        self.status = status.sucess()
    }

    private func callFast() {
        print("CircuitBreaker still is open, this is a calling fast")
        self.status = status.fail()
    }

    private func saveTimeWhenOpenOccurs() {
        print("Saving in local storage")
        localPersistence.saveTime(key: name, time: Date().timeIntervalSinceReferenceDate)
    }

    private func shouldBeAttemptReset() -> Bool {
        let timeSaved = localPersistence.getTime(key: name)
        let timeCalculated = Date().timeIntervalSinceReferenceDate - timeSaved
        let rounded: Int = Int(timeCalculated.rounded())
        print("ShouldBeAttemptReset? TimeElapsed: \(rounded)")
        return rounded > resetTimeout
    }
}

enum CircuitBreakerOpen: Error {
    case runtimeError(String)
}
