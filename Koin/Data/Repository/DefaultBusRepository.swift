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
    
    func fetchBusInformationList(requestModel: FetchBusInformationListRequest) -> AnyPublisher<BusDTO, Error> {
        return service.fetchBusInformationList(requestModel: requestModel)
    }
    
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDTO, Error> {
        return service.searchBusInformation(requestModel: requestModel)
    }
    
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDTO, Error> {
        return service.fetchShuttleRouteList()
    }
    
    func fetchExpressBusTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDTO, Error> {
        return service.fetchExpressTimetableList(requestModel: requestModel)
    }
    
    func fetchCityBusTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDTO, Error> {
        return service.fetchCityTimetableList(requestModel: requestModel)
    }
    
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDTO, Error> {
        return service.fetchEmergencyNotice()
    }
    
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetableDTO, Error> {
        return service.fetchShuttleBusTimetable(id: id)
    }
}
