//
//  ShopDetailViewModel.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import Foundation
import Combine

final class ShopDetailViewModel {
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case update(shopDetail: ShopDetail)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    
    
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad: self?.fetchShopDetail()
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDetailViewModel {
    
    private func fetchShopDetail() {
        outputSubject.send(.update(shopDetail: ShopDetail.dummy()))
    }
}
