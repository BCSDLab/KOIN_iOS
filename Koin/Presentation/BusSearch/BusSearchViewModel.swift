//
//  BusSearchViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine

enum BusAreaButtonState {
    case allSelected // 출발지, 도착지 모두 다 선택된 상태
    case departureSelect // 출발지 선택하는 상태
    case arrivalSelect // 도착지 선택하는 상태
}

enum BusAreaButtonType {
    case departure
    case arrival
}

final class BusSearchViewModel: ViewModelProtocol {
    enum Input {
        case selectBusArea(Int, BusAreaButtonState)
        case fetchBusNotice
    }
    
    enum Output {
        case updateBusArea(BusAreaButtonState, BusPlace?)
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
            case let .selectBusArea(busAreaIdx, busRouteType):
                self?.selectBusInfo(busAreaIdx: busAreaIdx, busRouteType: busRouteType)
            case .fetchBusNotice:
                self?.getEmergencyNotice()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension BusSearchViewModel {
    private func selectBusInfo(busAreaIdx: Int, busRouteType: BusAreaButtonState) {
        let busAreaInfo = selectBusAreaUseCase.execute(busAreaIdx: busAreaIdx, busRouteType: busRouteType)
        outputSubject.send(.updateBusArea(busAreaInfo.0, busAreaInfo.1))
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
