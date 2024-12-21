//
//  FetchCityBusTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/29/24.
//

import Combine

protocol FetchCityBusTimetableUseCase {
    func execute(firstFilterIdx: Int, secondFilterIdx: Int) -> AnyPublisher<(BusTimetableInfo, [CityBusDirection]), Error>
}

final class DefaultFetchCityBusTimetableUseCase: FetchCityBusTimetableUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func execute(firstFilterIdx: Int, secondFilterIdx: Int) -> AnyPublisher<(BusTimetableInfo, [CityBusDirection]), Error> {
        var busCourses: [CityBusCourseInfo] = []
        var cityDirections: [CityBusDirection] = []
        if firstFilterIdx == 0 {
            busCourses = setFromCityBusCourses()
        }
        else {
            busCourses = setToCityBusCourses()
        }
        for course in busCourses {
            cityDirections.append(course.busNode)
        }
        let requestModel = FetchCityBusTimetableRequest(busNumber: busCourses[secondFilterIdx].busNumber.rawValue, direction: busCourses[secondFilterIdx].busNode.rawValue)
        return busRepository.fetchCityBusTimetableList(requestModel: requestModel).map {
            ($0.toDomain(), cityDirections)
        }.eraseToAnyPublisher()
    }
    
    private func setToCityBusCourses() -> [CityBusCourseInfo] {
        var cityBusInfos: [CityBusCourseInfo] = []
        let busCourseText = "병천방면"
        for busNumber in BusNumber.allCases {
            var cityBusInfo: CityBusCourseInfo = .init(busNumber: .fourHundred, busCourse: busCourseText, busNode: .byungChun)
            switch busNumber {
            case .fourHundred:
                cityBusInfo = CityBusCourseInfo(busNumber: .fourHundred, busCourse: busCourseText, busNode: .byungChun)
            case .fourHundredTwo:
                cityBusInfo = CityBusCourseInfo(busNumber: .fourHundredTwo, busCourse: busCourseText, busNode: .hwangSaDong)
            default:
                cityBusInfo = CityBusCourseInfo(busNumber: .fourHundredFive, busCourse: busCourseText, busNode: .yuGwanSun)
            }
            cityBusInfos.append(cityBusInfo)
        }
        return cityBusInfos
    }
    
    private func setFromCityBusCourses() -> [CityBusCourseInfo] {
        var cityBusInfos: [CityBusCourseInfo] = []
        let busCourseText = "천안방면"
        for busNumber in BusNumber.allCases {
            var cityBusInfo: CityBusCourseInfo = .init(busNumber: .fourHundred, busCourse: busCourseText, busNode: .terminal)
            switch busNumber {
            case .fourHundred:
                cityBusInfo = CityBusCourseInfo(busNumber: .fourHundred, busCourse: busCourseText, busNode: .terminal)
            case .fourHundredTwo:
                cityBusInfo = CityBusCourseInfo(busNumber: .fourHundredTwo, busCourse: busCourseText, busNode: .terminal)
            default:
                cityBusInfo = CityBusCourseInfo(busNumber: .fourHundredFive, busCourse: busCourseText, busNode: .terminal)
            }
            cityBusInfos.append(cityBusInfo)
        }
        return cityBusInfos
    }
}
