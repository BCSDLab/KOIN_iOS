//
//  SearchBusInfoUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/26/24.
//

import Combine
import Foundation

protocol SearchBusInfoUseCase {
    func execute(date: Date, busType: BusType, departure: BusPlace, arrival: BusPlace) -> AnyPublisher<SearchBusInfoResult, ErrorResponse>
}

final class DefaultSearchBusInfoUseCase: SearchBusInfoUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func execute(date: Date, busType: BusType, departure: BusPlace, arrival: BusPlace) -> AnyPublisher<SearchBusInfoResult, ErrorResponse> {
        return busRepository.searchBusInformation(date: date, busType: busType, departure: departure, arrival: arrival)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
}
