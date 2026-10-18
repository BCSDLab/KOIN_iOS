//
//  DiningNoticeViewModel.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

import Combine
import Foundation

final class DiningNoticeViewModel: ViewModelProtocol {
    
    enum Input {
        case fetchCoopShopList
    }
    enum Output {
        case showCoopShopData(CoopShopData)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchCoopShopListUseCase: FetchCoopShopListUseCase
    
    init(fetchCoopShopListUseCase: FetchCoopShopListUseCase) {
        self.fetchCoopShopListUseCase = fetchCoopShopListUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchCoopShopList:
                self?.fetchCoopShopList()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension DiningNoticeViewModel {
    private func fetchCoopShopList() {
        fetchCoopShopListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.outputSubject.send(.showCoopShopData(response))
            }
        ).store(in: &subscriptions)
    }
}

