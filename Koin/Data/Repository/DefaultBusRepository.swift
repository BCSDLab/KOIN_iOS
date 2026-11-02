//
//  DefaultBusRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Combine
import Foundation

final class DefaultBusRepository: BusRepository {
    
    private let service: BusService
    
    init(service: BusService) {
        self.service = service
    }

    func searchBusInformation(date: Date, busType: BusType, departure: BusPlace, arrival: BusPlace) -> AnyPublisher<BusSearchDto, ErrorResponse> {
        let requestModel = SearchBusInfoRequest(
            date: date.string(with: .yearMonthDayHyphen),
            time: date.string(with: .hourMinute),
            busType: busType.rawValue,
            depart: departure.rawValue,
            arrival: arrival.rawValue
        )
        return service.searchBusInformation(requestModel: requestModel)
    }
    
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDto, ErrorResponse> {
        return service.fetchShuttleRouteList()
    }
    
    func fetchExpressBusTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDto, ErrorResponse> {
        return service.fetchExpressTimetableList(requestModel: requestModel)
    }
    
    func fetchCityBusTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDto, ErrorResponse> {
        return service.fetchCityTimetableList(requestModel: requestModel)
    }
    
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDto, ErrorResponse> {
        return service.fetchEmergencyNotice()
    }
    
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetable, ErrorResponse> {
        service.fetchShuttleBusTimetable(id: id)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
}
