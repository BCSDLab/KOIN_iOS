//
//  FetchExpressTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/28/24.
//

import Combine

protocol FetchExpressTimetableUseCase {
    func fetchExpressTimetable(firstFilterIdx: Int) -> AnyPublisher<BusTimetableInfo, Error>
}

final class DefaultFetchExpressTimetableUseCase: FetchExpressTimetableUseCase, GetExpressFiltersUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func fetchExpressTimetable(firstFilterIdx: Int) -> AnyPublisher<BusTimetableInfo, Error> {
        let busCourse = setBusFirstFilter()[firstFilterIdx]
        let requestModel = FetchBusTimetableRequest(busType: busCourse.busType.rawValue, direction: busCourse.direction.rawValue, region: busCourse.region)
        return busRepository.fetchExpressBusTimetableList(requestModel: requestModel).map {
            $0.toDomain()
        }.map { [weak self] busTimetable in
            return self?.setBusCourseInEntity(busTimetable: busTimetable, busCourse: busCourse.busCourse) ?? BusTimetableInfo(courseName: "", routeName: "", arrivalInfos: [], updatedAt: "")
        }.eraseToAnyPublisher()
    }
    
    func getBusFirstFilter() -> [String] {
        return ["병천방면", "천안방면"]
    }
    
    private func setBusFirstFilter() -> [BusCourseInfo] {
        let fromCourse = BusCourseInfo(busCourse: "병천방면", busType: .expressBus, direction: .from, region: "천안")
        let toCourse = BusCourseInfo(busCourse: "천안방면", busType: .expressBus, direction: .to, region: "천안")
        return [fromCourse, toCourse]
    }
    
    private func setBusCourseInEntity(busTimetable: BusTimetableInfo, busCourse: String) -> BusTimetableInfo {
        var newBusTimetable = busTimetable
        newBusTimetable.courseName = busCourse
        return newBusTimetable
    }
}
