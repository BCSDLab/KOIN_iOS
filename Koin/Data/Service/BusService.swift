//
//  BusService.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Alamofire
import Combine

protocol BusService {
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDto, Error>
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDto, Error>
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDto, Error>
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDto, Error>
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDto, Error>
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetableDto, Error>
}

final class DefaultBusService: BusService {
    
    private let networkService = NetworkService()
    
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDto, Error> {
        return networkService.requestWithResponse(api: BusAPI.fetchBusTimetableList(requestModel))
    }
    
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDto, Error> {
        return networkService.requestWithResponse(api: BusAPI.searchBusInformation(requestModel))
    }
    
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDto, Error> {
        return networkService.requestWithResponse(api: BusAPI.fetchShuttleBusTimetableRoute)
    }
    
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDto, Error> {
        return networkService.requestWithResponse(api: BusAPI.fetchCityBusTimetableList(requestModel))
    }
    
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDto, Error> {
        return networkService.requestWithResponse(api: BusAPI.fetchEmergencyNotice)
    }
    
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetableDto, Error> {
        return networkService.requestWithResponse(api: BusAPI.fetchShuttleBusTimetableList(id))
    }
}
