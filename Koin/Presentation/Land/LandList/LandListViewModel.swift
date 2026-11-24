//
//  LandListViewModel.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import Combine

final class LandListViewModel: ViewModelProtocol {
    enum Input {
        case viewDidLoad
        case logEvent(EventLabelType, Any, parameters: [String: String] = [:])
    }
    enum Output {
        case updateLandList(LandList)
        case showToastMessage(String)
    }
    
    // MARK: - Properties
    private let fetchLandListUseCase: DefaultFetchLandListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(
        fetchLandListUseCase: DefaultFetchLandListUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.fetchLandListUseCase = fetchLandListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
}

extension LandListViewModel {
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                fetchLandList()
            case let .logEvent(label, value, parameters):
                logAnalyticsEventUseCase.execute(label: label, value: value, parameters: parameters)
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LandListViewModel {
    private func fetchLandList() {
        fetchLandListUseCase.execute(query: nil).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToastMessage(error.message))
                }
            },
            receiveValue: { [weak self] landList in
                self?.outputSubject.send(.updateLandList(landList))
            }
        ).store(in: &subscriptions)
    }
}
