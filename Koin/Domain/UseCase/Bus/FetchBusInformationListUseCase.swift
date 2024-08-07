//
//  FetchBusInformationListUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Combine

protocol FetchBusInformationListUseCase {
    func execute(departedPlace: BusPlace, arrivedPlace: BusPlace) -> AnyPublisher<[BusCardInformation], Error>
}

final class DefaultFetchBusInformationListUseCase: FetchBusInformationListUseCase {
    private let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func execute(departedPlace: BusPlace, arrivedPlace: BusPlace) -> AnyPublisher<[BusCardInformation], Error> {
        var busType: BusType = .shuttleBus
        
        let shuttleRequestModel = FetchBusInformationListRequest(busType: busType.rawValue, depart: departedPlace.rawValue, arrival: arrivedPlace.rawValue)
        
        busType = .expressBus
        let expressRequestModel = FetchBusInformationListRequest(busType: busType.rawValue, depart: departedPlace.rawValue, arrival: arrivedPlace.rawValue)
        
        busType = .cityBus
        let cityRequestModel = FetchBusInformationListRequest(busType: busType.rawValue, depart: departedPlace.rawValue, arrival: arrivedPlace.rawValue)
        
        let publisher1 = busRepository.fetchBusInformationList(requestModel: shuttleRequestModel).map {
            $0.toEntity(departedPlace: departedPlace, arrivedPlace: arrivedPlace)
        }
        let publisher2 = busRepository.fetchBusInformationList(requestModel: expressRequestModel).map {
            $0.toEntity(departedPlace: departedPlace, arrivedPlace: arrivedPlace)
        }
        let publisher3 = busRepository.fetchBusInformationList(requestModel: cityRequestModel).map {
            $0.toEntity(departedPlace: departedPlace, arrivedPlace: arrivedPlace)
        }
        return Publishers.Zip3(publisher1, publisher2, publisher3).map { bus1, bus2, bus3 in
            let busEntity = [bus1, bus2, bus3]
            return busEntity
        }.eraseToAnyPublisher()
    }
}


