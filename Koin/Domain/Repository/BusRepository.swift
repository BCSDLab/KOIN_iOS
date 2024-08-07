//
//  BusRepository.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Combine

protocol BusRepository {
    func fetchBusInformationList(requestModel: FetchBusInformationListRequest) -> AnyPublisher<BusDTO, Error>
    func searchBusInformation(requestModel: SearchBusInfoRequest) -> AnyPublisher<BusSearchDTO, Error>
    func fetchShuttleBusTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ShuttleBusTimetableDTO, Error>
    func fetchExpressBusTimetableList(requestModel: FetchBusTimetableRequest) -> AnyPublisher<ExpressTimetableDTO, Error>
    func getBusCourse() -> AnyPublisher<BusCourses, Error>
    func fetchCityBusTimetableList(requestModel: FetchCityBusTimetableRequest) -> AnyPublisher<CityBusTimetableDTO, Error>
}
