//
//  BusRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Combine

protocol BusRepository {
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDto, Error>
    func fetchExpressBusTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDto, Error>
    func fetchShuttleRouteList() -> AnyPublisher<ShuttleRouteDto, Error>
    func fetchCityBusTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDto, Error>
    func fetchEmergencyNotice() -> AnyPublisher<BusNoticeDto, Error>
    func fetchShuttleBusTimetable(id: String) -> AnyPublisher<ShuttleBusTimetable, Error>
}
