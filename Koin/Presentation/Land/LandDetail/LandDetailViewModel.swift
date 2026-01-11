//
//  DiningDetailViewMoel.swift
//  Koin
//
//  Created by 김나훈 on 3/14/24.
//

import Combine

final class LandDetailViewModel: ViewModelProtocol {
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchLandDetailUseCase: FetchLandDetailUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private var subscriptions: Set<AnyCancellable> = []
    private let landId: Int
    
    init(fetchLandDetailUseCase: FetchLandDetailUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, landId: Int) {
        self.fetchLandDetailUseCase = fetchLandDetailUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.landId = landId
    }
    
    enum Input {
        case viewDidLoad
    }
    enum Output {
        case showLandDetail(LandDetailItem)
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.getLandDetail()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LandDetailViewModel {
    private func getLandDetail() {
        fetchLandDetailUseCase.execute(landId: landId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showLandDetail(response))
        }.store(in: &subscriptions)
    }
}
