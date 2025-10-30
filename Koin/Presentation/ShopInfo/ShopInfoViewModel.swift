//
//  ShopInfoViewModel.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import Foundation
import Combine

final class ShopInfoViewModel {
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case update(shopInfo: ShopInfo)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    
    
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad: self?.fetchShopInfo()
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopInfoViewModel {
    
    private func fetchShopInfo() {
        outputSubject.send(.update(shopInfo: ShopInfo.dummy()))
    }
}
