//
//  BusSearchViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine

enum BusAreaButtonState {
    case allSelected
    case departureSelected
    case arrivalSelected
    case notSelected
}

final class BusSearchViewModel: ViewModelProtocol {
    enum Input {
        case selectBusArea(Int, Int, Int)
        case fetchBusNotice
    }
    
    enum Output {
        case updateBusArea(BusAreaButtonState, BusPlace?, Int)
        case updateEmergencyNotice(notice: BusNoticeDTO)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let selectBusAreaUseCase: SelectDepartAndArrivalUseCase
    private let fetchEmergencyNoticeUseCase: FetchEmergencyNoticeUseCase
    
    init(selectBusAreaUseCase: SelectDepartAndArrivalUseCase, fetchEmergencyNoticeUseCase: FetchEmergencyNoticeUseCase) {
        self.selectBusAreaUseCase = selectBusAreaUseCase
        self.fetchEmergencyNoticeUseCase = fetchEmergencyNoticeUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .selectBusArea(departAreaIdx, arrivedAreaIdx, busRouteType):
                self?.selectBusInfo(departAreaIdx: departAreaIdx, arrivalAreaIdx: arrivedAreaIdx, busRouteType: busRouteType)
            case .fetchBusNotice:
                self?.getEmergencyNotice()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension BusSearchViewModel {
    private func selectBusInfo(departAreaIdx: Int, arrivalAreaIdx: Int, busRouteType: Int) {
        let busAreaInfo = selectBusAreaUseCase.execute(departedAreaIdx: departAreaIdx, arrivalAreaIdx: arrivalAreaIdx, busRouteType: busRouteType)
        outputSubject.send(.updateBusArea(busAreaInfo.0, busAreaInfo.1, busRouteType))
    }
    
    private func getEmergencyNotice() {
        fetchEmergencyNoticeUseCase.execute().sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] notice in
            self?.outputSubject.send(.updateEmergencyNotice(notice: notice))
        }).store(in: &subscriptions)
    }
}
