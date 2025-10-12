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
        case deleteItem(cartMenuItemId: Int)
    }
    enum Output {
        case updateSegment(isDeliveryAvailable: Bool, isTakeOutAvailable: Bool)
        case updateCart(cart: Cart, isFromDelivery: Bool)
        case removeItemFromTableView(cartMenuItemId: Int)
    }
    
    // MARK: - Properties
    private let fetchCartUseCase: FetchCartUseCase
    private let fetchCartDeliveryUseCase: FetchCartDeliveryUseCase
    private let fetchCartTakeOutUseCase: FetchCartTakeOutUseCase
    private let deleteCartMenuItemUseCase: DeleteCartMenuItemUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(fetchCartUseCase: FetchCartUseCase, fetchCartDeliveryUseCase: FetchCartDeliveryUseCase, fetchCartTakeOutUseCase: FetchCartTakeOutUseCase, deleteCartMenuItemUseCase: DeleteCartMenuItemUseCase) {
        self.fetchCartUseCase = fetchCartUseCase
        self.fetchCartDeliveryUseCase = fetchCartDeliveryUseCase
        self.fetchCartTakeOutUseCase = fetchCartTakeOutUseCase
        self.deleteCartMenuItemUseCase = deleteCartMenuItemUseCase
    }
    
    // MARK: - Transform
    func transform(with input: PassthroughSubject<Input, Never>) -> PassthroughSubject<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad: self?.fetchCart()
            case .fetchCartDelivery: self?.fetchCartDelivery()
            case .fetchCartTakeOut: self?.fetchCartTakeOut()
            case .deleteItem(let cartMenuItemId): self?.deleteItem(cartMenuItemId: cartMenuItemId)
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
                  receiveValue: { [weak self] (cart, isFromDelivery) in
                self?.outputSubject.send(.updateCart(cart: cart, isFromDelivery: isFromDelivery))
                self?.outputSubject.send(.updateSegment(isDeliveryAvailable: cart.isDeliveryAvailable, isTakeOutAvailable: cart.isTakeoutAvailable))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchCartDelivery() {
        fetchCartDeliveryUseCase.execute()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] (cart, isFromDelivery) in
                self?.outputSubject.send(.updateCart(cart: cart, isFromDelivery: isFromDelivery))
            })
            .store(in: &subscriptions)
    }
    
    private func fetchCartTakeOut() {
        fetchCartTakeOutUseCase.execute()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] (cart, isFromDelivery) in
                self?.outputSubject.send(.updateCart(cart: cart, isFromDelivery: isFromDelivery))
            })
            .store(in: &subscriptions)
    }
    
    private func deleteItem(cartMenuItemId: Int) {
        deleteCartMenuItemUseCase.execute(cartMenuItemId: cartMenuItemId)
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    switch failure.code {
                    case "401":
                        print(failure.message) /// 인증 정보 오류
                    case "404":
                        switch failure.code {
                        case "NOT_FOUND_CART_ITEM": print(failure.message) /// 존재하지 않는 리소스 - 존재하지 않는 장바구니 상품
                        case "NOT_FOUND_CART": print(failure.message) /// 존재하지 않는 리소스 - 장바구니 없음
                        default: print("DeleteItem Failed: unknown error - \(failure)")
                        }
                    default:
                        print("DeleteItem Failed: unknown error - \(failure)")
                    }
                }
            }, receiveValue: { [weak self] in
                self?.outputSubject.send(.removeItemFromTableView(cartMenuItemId: cartMenuItemId))
                print("deleteItem succeeded")
            })
            .store(in: &subscriptions)
    }
}
