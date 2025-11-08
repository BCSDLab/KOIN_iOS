//
//  ShopSearchViewModel.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import Foundation
import Combine

final class ShopSearchViewModel {
    
    enum Input {
        
    }
    enum Output {
        
    }
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let outputSubject = PassthroughSubject<Output, Never>()
    
    // MARK: - Initializer
    init() {
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { input in
            switch input {
            default: break
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}
