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
        case fetchCartDelivery
        case fetchCartTakeOut
    }
    enum Output {
        case updateCart(cart: Cart)
    }
    
    // MARK: - Properties
    private let fetchCartUseCase: FetchCartUseCase
    private let fetchCartDeliveryUseCase: FetchCartDeliveryUseCase
    private let fetchCartTakeOutUseCase: FetchCartTakeOutUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(fetchCartUseCase: FetchCartUseCase,
         fetchCartDeliveryUseCase: FetchCartDeliveryUseCase,
         fetchCartTakeOutUseCase: FetchCartTakeOutUseCase) {
        self.fetchCartUseCase = fetchCartUseCase
        self.fetchCartDeliveryUseCase = fetchCartDeliveryUseCase
        self.fetchCartTakeOutUseCase = fetchCartTakeOutUseCase
    }
    // MARK: - Transform
    func transform(with input: PassthroughSubject<Input, Never>) -> PassthroughSubject<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad: self?.fetchCart()
            case .fetchCartDelivery: self?.fetchCartDelivery()
            case .fetchCartTakeOut: self?.fetchCartTakeOut()
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
    
    private func fetchCartDelivery() {
        fetchCartDeliveryUseCase.execute()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] cart in
                self?.outputSubject.send(.updateCart(cart: cart))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchCartTakeOut() {
        fetchCartTakeOutUseCase.execute()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] cart in
                self?.outputSubject.send(.updateCart(cart: cart))
            })
            .store(in: &subscriptions)
    }
}
