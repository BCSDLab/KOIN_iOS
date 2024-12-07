//
//  GetBusFiltersUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/29/24.
//

import Combine

protocol GetShuttleBusFiltersUseCase {
    func getBusFirstFilter() -> AnyPublisher<[BusCourseInfo], Error>
    func getBusSecondFilter(firstFilterIdx: Int) -> AnyPublisher<[String], Error>
}

protocol GetExpressFiltersUseCase {
    func getBusFirstFilter() -> [String]
}

protocol GetCityFiltersUseCase {
    func getBusFilter() -> ([String], [String])
}
