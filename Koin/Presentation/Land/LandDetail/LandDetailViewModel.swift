//
//  LandDetailViewModel.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import Combine

final class LandDetailViewModel: ViewModelProtocol {
    enum Input {
        case viewDidLoad
        case logEvent(EventLabelType, Any, parameters: [String: String] = [:])
    }
    enum Output {
        case updateLandDetail(LandDetail)
        case showToastMessage(String)
    }

    // MARK: - Properties
    let landRow: LandRow
    private let fetchLandDetailUseCase: FetchLandDetailUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initializer
    init(
        landRow: LandRow,
        fetchLandDetailUseCase: FetchLandDetailUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.landRow = landRow
        self.fetchLandDetailUseCase = fetchLandDetailUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
}

extension LandDetailViewModel {
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                fetchLandDetail()
            case let .logEvent(label, value, parameters):
                logAnalyticsEventUseCase.execute(label: label, value: value, parameters: parameters)
            }
        }
        .store(in: &subscriptions)

        return outputSubject.eraseToAnyPublisher()
    }
}

extension LandDetailViewModel {
    private func fetchLandDetail() {
        fetchLandDetailUseCase.execute(landId: landRow.id).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToastMessage(error.message))
                }
            },
            receiveValue: { [weak self] landDetail in
                self?.outputSubject.send(.updateLandDetail(landDetail))
            }
        ).store(in: &subscriptions)
    }
}
