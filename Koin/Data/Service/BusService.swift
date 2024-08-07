//
//  BusService.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Alamofire
import Combine

protocol BusService {
    func fetchBusInformationList(requestModel: FetchBusInformationListRequest) -> AnyPublisher<BusDTO, Error>
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDTO, Error>
    func fetchShuttleTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ShuttleBusTimetableDTO, Error>
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDTO, Error>
    func getBusCourse() -> AnyPublisher<BusCourses, Error>
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDTO, Error>
}

final class DefaultBusService: BusService {
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDTO, Error> {
        return request(.fetchBusTimetableList(requestModel))
    }
    
    func fetchBusInformationList(requestModel: FetchBusInformationListRequest) -> AnyPublisher<BusDTO, Error> {
        return request(.fetchBusInformationList(requestModel))
    }
    
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDTO, Error> {
        return request(.searchBusInformation(requestModel))
    }
    
    func fetchShuttleTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ShuttleBusTimetableDTO, Error> {
        return request(.fetchBusTimetableList(requestModel))
    }
    
    func getBusCourse() -> AnyPublisher<BusCourses, Error> {
        return request(.getBusCourse)
    }
    
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDTO, Error> {
        return request(.fetchCityBusTimetableList(requestModel))
    }
    

    private func request<T: Decodable>(_ api: BusAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
