//
//  DefaultBusRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Combine

final class DefaultBusRepository: BusRepository {
    
    private let service: BusService
    
    init(service: BusService) {
        self.service = service
    }

    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDto, Error> {
        return service.searchBusInformation(requestModel: requestModel)
    }
    
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDto, Error> {
        return service.fetchShuttleRouteList()
    }
    
    func fetchExpressBusTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDto, Error> {
        return service.fetchExpressTimetableList(requestModel: requestModel)
    }
    
    func fetchCityBusTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDto, Error> {
        return service.fetchCityTimetableList(requestModel: requestModel)
    }
    
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDto, Error> {
        return service.fetchEmergencyNotice()
    }
    
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetableDto, Error> {
        return service.fetchShuttleBusTimetable(id: id)
    }
}
