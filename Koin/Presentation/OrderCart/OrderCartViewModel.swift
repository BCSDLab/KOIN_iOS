//
//  OrderCartViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/25/25.
//

import Foundation
import Combine

final class OrderCartViewModel {
    
    enum Input {
        case viewDidLoad
    }
    enum Output {
        case updateCart(cart: Cart)
    }
    
    // MARK: - Properties
    private let fetchCartUseCase: FetchCartUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(fetchCartUseCase: FetchCartUseCase) {
        self.fetchCartUseCase = fetchCartUseCase
    }
    // MARK: - Transform
    func transform(with input: PassthroughSubject<Input, Never>) -> PassthroughSubject<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad: self?.fetchCart()
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject
    }
}

extension OrderCartViewModel {
    
    private func fetchCart() {
        fetchCartUseCase.execute()
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("fetchingCartUseCase Failed : \(failure)")
                }
            },
                  receiveValue: { [weak self] cart in
                self?.outputSubject.send(.updateCart(cart: cart))
            })
            .store(in: &subscriptions)
    }
}
