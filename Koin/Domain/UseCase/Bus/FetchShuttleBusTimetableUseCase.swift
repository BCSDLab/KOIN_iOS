//
//  FetchShuttleBusTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/27/24.
//

import Combine

protocol FetchShuttleBusTimetableUseCase {
    func fetchShuttleBusTimetable(busFirstFilterIdx: Int, busSecondFilterIdx: Int) -> AnyPublisher<BusTimetableInfo, Error>
}

final class DefaultFetchShuttleBusTimetableUseCase: FetchShuttleBusTimetableUseCase, GetShuttleBusFiltersUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func fetchShuttleBusTimetable(busFirstFilterIdx: Int, busSecondFilterIdx: Int) -> AnyPublisher<BusTimetableInfo, Error> {
        return busRepository.getBusCourse()
            .flatMap { [weak self] busCourse -> AnyPublisher<BusTimetableInfo, Just<BusTimetableInfo>.Failure> in
                guard let self = self else {
                    return Just(BusTimetableInfo(courseName: "", routeName: "", arrivalInfos: [], updatedAt: "")).eraseToAnyPublisher()
                }
                let fetchBusTimetableRequest = FetchBusTimetableRequest(
                    busType: busCourse[busFirstFilterIdx].busType?.rawValue ?? "",
                    direction: busCourse[busFirstFilterIdx].direction?.rawValue ?? "",
                    region: busCourse[busFirstFilterIdx].region ?? ""
                )
                return self.busRepository.fetchShuttleBusTimetableList(requestModel: fetchBusTimetableRequest)
                    .tryMap { busTimetableResponse in
                        let busTimetables = busTimetableResponse.toDomain()
                        guard busTimetables.indices.contains(busSecondFilterIdx) else {
                            return BusTimetableInfo(courseName: "", routeName: "", arrivalInfos: [], updatedAt: "")
                        }
                        return self.filterByBusFilter(busTimetableList: busTimetables, busRouteFilter: busTimetables[busSecondFilterIdx].routeName, busCourse: busCourse[busFirstFilterIdx])
                    }
                    .catch { _ in Just(BusTimetableInfo(courseName: "", routeName: "", arrivalInfos: [], updatedAt: "")) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getBusFirstFilter() -> AnyPublisher<[BusCourseInfo], Error> {
        busRepository.getBusCourse()
            .map { busCourses in
                busCourses.toDomain()
            }.eraseToAnyPublisher()
    }
    
    func getBusSecondFilter(firstFilterIdx: Int) -> AnyPublisher<[String], Error> {
        return busRepository.getBusCourse()
            .flatMap { [weak self] busCourse -> AnyPublisher<[String], Just<[BusTimetableInfo]>.Failure> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                let fetchBusTimetableRequest = FetchBusTimetableRequest(
                    busType: busCourse[firstFilterIdx].busType?.rawValue ?? "",
                    direction: busCourse[firstFilterIdx].direction?.rawValue ?? "",
                    region: busCourse[firstFilterIdx].region ?? ""
                )
                return self.busRepository.fetchShuttleBusTimetableList(requestModel: fetchBusTimetableRequest)
                    .tryMap { busTimetableResponse in
                        let busTimetables = busTimetableResponse.toDomain()
                        return self.makeBusRouteToString(busTimetable: busTimetables)
                    }
                    .catch { _ in Just([]) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func makeBusRouteToString(busTimetable: [BusTimetableInfo]) -> [String] {
        return busTimetable.map { $0.routeName }
    }

    private func filterByBusFilter(busTimetableList: [BusTimetableInfo], busRouteFilter: String, busCourse: BusCourse) -> BusTimetableInfo {
        let filteredBusTimetable = busTimetableList.filter {
            $0.routeName == busRouteFilter
        }
        var newBusTimetable = filteredBusTimetable.first ?? BusTimetableInfo(courseName: "", routeName: "", arrivalInfos: [], updatedAt: "")
        newBusTimetable.courseName = busCourse.toDomain().busCourse
        return newBusTimetable
    }
}
