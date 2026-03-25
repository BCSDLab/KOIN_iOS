//
//  BusService.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Alamofire
import Combine

protocol BusService {
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDto, ErrorResponse>
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDto, ErrorResponse>
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDto, ErrorResponse>
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDto, ErrorResponse>
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDto, ErrorResponse>
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetableDto, ErrorResponse>
}

final class DefaultBusService: BusService {
    
    private let networkService = NetworkService.shared
    
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDto, ErrorResponse> {
        return networkService.requestWithResponse(api: BusAPI.fetchBusTimetableList(requestModel))
    }
    
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDto, ErrorResponse> {
        return networkService.requestWithResponse(api: BusAPI.searchBusInformation(requestModel))
    }
    
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDto, ErrorResponse> {
        return networkService.requestWithResponse(api: BusAPI.fetchShuttleBusTimetableRoute)
    }
    
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDto, ErrorResponse> {
        return networkService.requestWithResponse(api: BusAPI.fetchCityBusTimetableList(requestModel))
    }
    
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDto, ErrorResponse> {
        return networkService.requestWithResponse(api: BusAPI.fetchEmergencyNotice)
    }
    
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetableDto, ErrorResponse> {
        return networkService.requestWithResponse(api: BusAPI.fetchShuttleBusTimetableList(id))
    }
}
