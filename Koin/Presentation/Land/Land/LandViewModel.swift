//
//  DiningDetailViewMoel.swift
//  Koin
//
//  Created by 김나훈 on 3/14/24.
//

import Combine
import Foundation

final class LandViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
    }
    enum Output {
        case showLandList([LandItem])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchLandListUseCase: FetchLandListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private var subscriptions: Set<AnyCancellable> = []

    init(fetchLandListUseCase: FetchLandListUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchLandListUseCase = fetchLandListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.getLandList()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LandViewModel {
    
    private func getLandList() {
        fetchLandListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.outputSubject.send(.showLandList(response))
            }
        ).store(in: &subscriptions)
    }
}
