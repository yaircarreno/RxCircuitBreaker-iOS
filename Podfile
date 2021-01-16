use_frameworks!
platform :ios, '9.0'

def rxswift
  pod 'RxSwift', '6.0.0'
  pod 'RxCocoa', '6.0.0'
end

def firebasefunctions
  pod 'Firebase/Functions'
end

def testing_rxswift
  pod 'RxBlocking', '6.0.0'
  pod 'RxTest', '6.0.0'
end

target 'RxCircuitBreaker' do
  rxswift
  firebasefunctions

  target 'RxCircuitBreakerTests' do
    inherit! :search_paths
    testing_rxswift
  end

  target 'RxCircuitBreakerUITests' do
    inherit! :search_paths
    testing_rxswift
  end

end
