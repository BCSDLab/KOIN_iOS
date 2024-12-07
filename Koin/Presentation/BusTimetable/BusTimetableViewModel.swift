//
//  BusTimetableViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
//
import Combine
import Foundation

final class BusTimetableViewModel: ViewModelProtocol {
    // MARK: - properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    enum Input {
        case getBusRoute(BusType)
    }

    enum Output {
        case updateBusRoute(busType: BusType, firstBusRoute: [String], secondBusRoute: [String]?)
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .getBusRoute(busType):
                self?.getBusRoute(busType: busType)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func getBusRoute(busType: BusType) {
        let firstBusRoute: [String]
        var secondBusRoute: [String]? = nil
        switch busType {
        case .shuttleBus:
            firstBusRoute = ["전체", "주중노선", "주말노선", "순환노선"]
        case .expressBus:
            firstBusRoute = ["병천방면", "천안방면"]
        default:
            firstBusRoute = ["400번", "405번", "495번"]
            secondBusRoute = ["병천방면", "천안방면"]
        }
        outputSubject.send(.updateBusRoute(busType: busType, firstBusRoute: firstBusRoute, secondBusRoute: secondBusRoute))
    }
}
