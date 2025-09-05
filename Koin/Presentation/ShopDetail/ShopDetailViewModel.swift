//
//  ShopDetailViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import Combine

class ShopDetailViewModel {
    
    enum Input {
    case someInput
    }
    
    enum Output {
    case someOutput
    }
    
    // MARK: - Properties
    let someOutput = PassthroughSubject<Output, Never>()
    var subscriptions: Set<AnyCancellable> = []
    
    // MARK: Transform
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { input in
            switch input {
            case .someInput: return
            }
        }
        .store(in: &subscriptions)
        return someOutput.eraseToAnyPublisher()
    }
}
