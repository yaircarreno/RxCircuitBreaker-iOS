//
//  ViewController.swift
//  RxCircuitBreaker
//
//  Created by Yair Carreno on 14/01/21.
//

import UIKit
import Firebase
import RxSwift

class ViewController: UIViewController {

    lazy var functions = Functions.functions()
    let disposeBag = DisposeBag()
    let serialScheduler = SerialDispatchQueueScheduler(qos: .default)
    let userDefaultsStorage = UserDefaultsStorage()
    let circuitBreakersManager = CircuitBreakersManager()

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var circuitState: UILabel!
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    @IBAction func callSuccess(_ sender: Any) {
        callServiceWithCircuitBreaker(tySimulation: "Success")
    }

    @IBAction func callWithError(_ sender: Any) {
        callServiceWithCircuitBreaker(tySimulation: "Error")
    }

    @IBAction func callWithLatency(_ sender: Any) {
        callServiceWithCircuitBreaker(tySimulation: "Latency")
    }

    private func callServiceWithCircuitBreaker(tySimulation: String) {
        activityIndicator.startAnimating()
        let circuitBreaker = circuitBreakersManager
            .getCircuitBreaker("cicuit-1", userDefaultsStorage)
        CircuitBreakersManager
            .callWithCircuitBreaker(service(tySimulation), circuitBreaker)
            .subscribe(on: serialScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { result in
                self.logs(result as! String, circuitBreaker.status, true)
                self.showMessages(result as! String, circuitBreaker.status)
                self.activityIndicator.stopAnimating()
            } ,
            onFailure: { error in
                self.logs(error.localizedDescription,circuitBreaker.status, false)
                self.showMessages(error.localizedDescription, circuitBreaker.status)
                self.activityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }

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

    private func showMessages(_ messageFromAPI: String, _ circuitBreakerState: CircuitBreakerState) {
        message.text = messageFromAPI
        circuitState.text = "\(circuitBreakerState)"
    }
    
    private func logs(_ messageFromAPI: String, _ circuitBreakerState: CircuitBreakerState, _ success: Bool) {
        print(success ? messageFromAPI : "Event called Error: \(messageFromAPI)")
        print(circuitBreakerState)
    }

    private func setUpUI() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
