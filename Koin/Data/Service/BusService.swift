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
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDTO, Error>
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDTO, Error>
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDTO, Error>
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDTO, Error>
}

final class DefaultBusService: BusService {
    let mockNetworkService = MockNetworkService()
    
    func fetchExpressTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDTO, Error> {
        return request(.fetchBusTimetableList(requestModel))
    }
    
    func fetchBusInformationList(requestModel: FetchBusInformationListRequest) -> AnyPublisher<BusDTO, Error> {
        return request(.fetchBusInformationList(requestModel))
    }
    
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDTO, Error> {
        return request(.searchBusInformation(requestModel))
    }
    
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDTO, Error> {
        guard let url = URL(string: "https://c01aaba6-9825-4309-b30e-aff4753bebfe.mock.pstmn.io/test/bus/courses") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
      
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        return mockNetworkService.request(api: urlRequest)
            .eraseToAnyPublisher()
    }
    
    func fetchCityTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDTO, Error> {
        return request(.fetchCityBusTimetableList(requestModel))
    }
    
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDTO, Error> {
        guard let url = URL(string: "https://c01aaba6-9825-4309-b30e-aff4753bebfe.mock.pstmn.io/bus/Notice") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
      
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        return mockNetworkService.request(api: urlRequest)
            .eraseToAnyPublisher()
    }
    

    private func request<T: Decodable>(_ api: BusAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
