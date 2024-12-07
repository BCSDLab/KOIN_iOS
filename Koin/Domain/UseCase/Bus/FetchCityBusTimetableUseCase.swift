//
//  FetchCityBusTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/29/24.
//

import Combine

protocol FetchCityBusTimetableUseCase {
    func fetchCityBusTimetableUseCase(firstFilterIdx: Int, secondFilterIdx: Int) -> AnyPublisher<BusTimetableInfo, Error>
}

final class DefaultFetchCityBusTimetableUseCase: FetchCityBusTimetableUseCase, GetCityFiltersUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func fetchCityBusTimetableUseCase(firstFilterIdx: Int, secondFilterIdx: Int) -> AnyPublisher<BusTimetableInfo, Error> {
        var busCourses: [CityBusCourseInfo] = []
        if firstFilterIdx == 0 {
            busCourses = setFromCityBusCourses()
        }
        else {
            busCourses = setToCityBusCourses()
        }
        let requestModel = FetchCityBusTimetableRequest(busNumber: busCourses[secondFilterIdx].busNumber.rawValue, direction: busCourses[secondFilterIdx].busNode.rawValue)
        return busRepository.fetchCityBusTimetableList(requestModel: requestModel).map {
            $0.toDomain()
        }.eraseToAnyPublisher()
    }
    
    func getBusFilter() -> ([String], [String]) {
        return (["병천방면", "천안방면"], ["400번", "402번", "405번"])
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
