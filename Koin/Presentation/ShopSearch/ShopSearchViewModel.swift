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
        case keywordDidChange(String)
    }
    enum Output {
        case update(ShopSearch)
    }
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchSearchShopUseCase: FetchSearchShopUseCase
    
    // MARK: - Initializer
    init(fetchSearchShopUseCase: FetchSearchShopUseCase) {
        self.fetchSearchShopUseCase = fetchSearchShopUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .keywordDidChange(let keyword):
                self.fetchSearchShop(keyword)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopSearchViewModel {
    
    private func fetchSearchShop(_ keyword: String) {
        fetchSearchShopUseCase.execute(keyword: keyword)
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("failed : \(failure)")
                }
            },
                  receiveValue: { [weak self] shopSearchResult in
                self?.outputSubject.send(.update(shopSearchResult))
            })
            .store(in: &subscriptions)
    }
}
