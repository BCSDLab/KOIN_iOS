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
        case logEvent(EventLabelType, Any)
    }
    enum Output {
        case update(ShopSearch)
    }
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchSearchShopUseCase: FetchSearchShopUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    // MARK: - Initializer
    init(fetchSearchShopUseCase: FetchSearchShopUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchSearchShopUseCase = fetchSearchShopUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .keywordDidChange(let keyword):
                self.fetchSearchShop(keyword)
            case let .logEvent(label, value):
                self.logAnalyticsEventUseCase.execute(label: label, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopSearchViewModel {
    
    func makeLogAnalyticsEvent(label: EventLabelType, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, value: value)
    }
    
    private func fetchSearchShop(_ keyword: String) {
        fetchSearchShopUseCase.execute(keyword: keyword).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] shopSearchResult in
                self?.outputSubject.send(.update(shopSearchResult))
            }
        ).store(in: &subscriptions)
    }
}
