//
//  SearchBusInfoUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/26/24.
//

import Combine

protocol SearchBusInfoUseCase {
    func execute(requestModel: SearchBusInfoRequest) -> AnyPublisher<SearchBusInfoResult, Error>
}

final class DefaultSearchBusInfoUseCase: SearchBusInfoUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func execute(requestModel: SearchBusInfoRequest) -> AnyPublisher<SearchBusInfoResult, Error> {
        busRepository.searchBusInformation(requestModel: requestModel).map { result in
            return result.toDomain()
        }.eraseToAnyPublisher()
    }
}
