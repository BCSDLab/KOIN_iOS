//
//  BusService.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Alamofire
import Combine

protocol BusService {
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDTO, Error>
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDTO, Error>
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDTO, Error>
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDTO, Error>
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDTO, Error>
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetableDto, Error>
}

final class DefaultBusService: BusService {
    let mockNetworkService = MockNetworkService()
    
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDTO, Error> {
        return request(.fetchBusTimetableList(requestModel))
    }
    
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDTO, Error> {
        return request(.searchBusInformation(requestModel))
    }
    
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDTO, Error> {
        return request(.fetchShuttleBusTimetableRoute)
    }
    
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDTO, Error> {
        return request(.fetchCityBusTimetableList(requestModel))
    }
    
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDTO, Error> {
        return request(.fetchEmergencyNotice)
    }
    
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetableDto, Error> {
        return request(.fetchShuttleBusTimetableList(id))
    }

    private func request<T: Decodable>(_ api: BusAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
