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
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "M월 d일(EEE) a hh:mm"
        let formattedDate = Date().stringToDate(dateValue: date, dateFormatter: dateFormatter) ?? Date() // string 값으로 받은 것을 date로 변환해줌
        if date.prefix(2) == "오늘" {
            departDate = Date().formatDateToYYYYMMDD(separator: "-")
        }
        else if date.prefix(2) == "내일" {
            departDate = (Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()).formatDateToYYYYMMDD(separator: "-")
        }
        else {
            departDate = returnIncludeYear(date: formattedDate).formatDateToYYYYMMDD(separator: "-")
        }
        
        let departTime = formattedDate.formatDateToHHMM(isHH: true)
        
        let request = SearchBusInfoRequest(date: departDate, time: departTime, busType: busType.rawValue, depart: departure.rawValue, arrival: arrival.rawValue)
        return busRepository.searchBusInformation(requestModel: request).map {
            $0.toDomain()
        }.eraseToAnyPublisher()
    }
    
    private func returnIncludeYear(date: Date) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let currentYear = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
    
        let comparisonDateComponents = DateComponents(year: currentYear, month: month, day: day)
        let comparisonDate = calendar.date(from: comparisonDateComponents)!
   
        if comparisonDate >= today {
            return comparisonDate
        } else {
            let nextYear = currentYear + 1
            let adjustedDateComponents = DateComponents(year: nextYear, month: month, day: day)
            return calendar.date(from: adjustedDateComponents) ?? Date()
        }
    }
}
