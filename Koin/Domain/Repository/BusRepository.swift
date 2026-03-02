//
//  BusRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Combine

protocol BusRepository {
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDto, ErrorResponse>
    func fetchExpressBusTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDto, ErrorResponse>
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDto, ErrorResponse>
    func fetchCityBusTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDto, ErrorResponse>
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDto, ErrorResponse>
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetable, ErrorResponse>
}
