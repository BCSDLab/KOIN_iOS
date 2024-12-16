//
//  SearchBusInfoUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/26/24.
//

import Combine
import Foundation

protocol SearchBusInfoUseCase {
    func execute(date: String, busType: BusType, departure: BusPlace, arrival: BusPlace) -> AnyPublisher<SearchBusInfoResult, Error>
}

final class DefaultSearchBusInfoUseCase: SearchBusInfoUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func execute(date: String, busType: BusType, departure: BusPlace, arrival: BusPlace) -> AnyPublisher<SearchBusInfoResult, Error> {
        let departDate: String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일(EEE) a hh:mm"
        let formattedDate = Date().stringToDate(dateValue: date, dateFormatter: dateFormatter) ?? Date() // string 값으로 받은 것을 date로 변환해줌
   
        if date.prefix(2) == "오늘" {
            departDate = Date().formatDateToMDEEE()
        }
        else if date.prefix(2) == "내일" {
            departDate = (Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()).formatDateToMDEEE()
        }
        else {
            departDate = formattedDate.formatDateToMDEEE()
        }
        let departTime = formattedDate.formatDateToHHMM(isHH: true)
        
        let request = SearchBusInfoRequest(date: departDate, time: departTime, busType: busType.rawValue, depart: departure.rawValue, arrival: arrival.rawValue)
        print(request)
        return Just(returnExpample().toDomain()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    private func returnExpample() -> BusSearchDTO {
        return BusSearchDTO(depart: .koreatech, arrival: .station, departDate: "2024-12-20", departTime: "16:00", schedule: [Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00"), Schedule(busType: .shuttleBus, routeName: "대성티엔이", departTime: "17:00")])
    }
}
