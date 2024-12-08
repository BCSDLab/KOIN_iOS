//
//  FetchExpressTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/28/24.
//

import Combine

protocol FetchExpressTimetableUseCase {
    func execute(filterIdx: Int) -> AnyPublisher<BusTimetableInfo, Error>
}

final class DefaultFetchExpressTimetableUseCase: FetchExpressTimetableUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func execute(filterIdx: Int) -> AnyPublisher<BusTimetableInfo, Error> {
        let busCourse = setBusFilter()[filterIdx]
        let requestModel = FetchBusTimetableRequest(busType: busCourse.busType.rawValue, direction: busCourse.direction.rawValue, region: busCourse.region)
        return busRepository.fetchExpressBusTimetableList(requestModel: requestModel).map {
            $0.toDomain()
        }.map { busTimetable in
            return busTimetable
        }.eraseToAnyPublisher()
    }
    
    private func setBusFilter() -> [BusCourseInfo] {
        let fromCourse = BusCourseInfo(busCourse: "병천방면", busType: .expressBus, direction: .from, region: "천안")
        let toCourse = BusCourseInfo(busCourse: "천안방면", busType: .expressBus, direction: .to, region: "천안")
        return [fromCourse, toCourse]
    }
}
