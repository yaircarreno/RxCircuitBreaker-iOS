# RxCircuitBreaker in iOS

This repository contains an example of the Circuit Breaker pattern implementation in iOS applications.
You can also find the Android implementation at [RxCircuitBreaker-Android](https://github.com/yaircarreno/RxCircuitBreaker-Android)

## Articles

- [Circuit Breaker Pattern Implemented with Rx in Mobile or Web Applications](https://www.yaircarreno.com/2021/01/circuit-breaker-pattern-implemented.html)


## States Diagram

![Circuit Breaker Pattern](https://github.com/yaircarreno/RxCircuitBreaker-iOS/blob/main/Screenshots/circuit-breaker-diagram.png)

## Implementation

We have *CircuitBreaker* as a main component in the pattern, like this:

```swift
class CircuitBreaker {

    ...

    init(name: String, localPersistence: LocalPersistence) {
        ...
    }

    public func callService(_ service: Single<Any>) -> Single<Any> {
        switch self.status {
        case .open:
            return openActions()
        case .closed, .halfOpen:
            return closeActions(service)
        }
    }
}
```
In this example, I have combined the two events (reset - success).

You also have the Rx wrapper for the service:

```swift
private func service(_ tySimulation: String) -> Single<Any> {
    return Single<Any>.create { emitter in
        self.functions.httpsCallable("simulateResponses?typeSimulation=" + tySimulation)
            .call() { (result, error) in
                if let error = error as NSError? {
                    emitter(.failure(error))
                }
                emitter(.success(result?.data ?? ""))
            }
        return Disposables.create()
    }
}
```

Calling from the client, you could use something like this:

```swift
private func callServiceWithCircuitBreaker(tySimulation: String) {
    ...
    let circuitBreaker = circuitBreakersManager.getCircuitBreaker("cicuit-1", userDefaultsStorage)
    CircuitBreakersManager
        .callWithCircuitBreaker(service(tySimulation), circuitBreaker)
        .subscribe(on: serialScheduler)
        .observe(on: MainScheduler.instance)
        .subscribe(onSuccess: { result in
            self.logs(result as! String, circuitBreaker.status, true)
            ...
        } ,
        onFailure: { error in
            self.logs(error.localizedDescription,circuitBreaker.status, false)
            ...
        })
        .disposed(by: disposeBag)
}
```

## Demo

![Circuit Breaker Pattern](https://github.com/yaircarreno/RxCircuitBreaker-iOS/blob/main/Screenshots/demo-circuit-breaker-ios.gif)


## Versions of IDEs and technologies used.

- Xcode 12.3 - Swift 5
- RxSwift 6
- Storyboards
- Cocoapods


