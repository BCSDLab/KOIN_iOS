//
//  BusTimetableDataViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/5/24.
//

import Combine
import Foundation

final class BusTimetableDataViewModel: ViewModelProtocol {
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
            
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
   
}

