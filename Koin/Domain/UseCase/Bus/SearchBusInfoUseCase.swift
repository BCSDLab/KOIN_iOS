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
        let (departDate, departTime): (String, String) = self.processDate(date)
        let request = SearchBusInfoRequest(
            date: departDate,
            time: departTime,
            busType: busType.rawValue,
            depart: departure.rawValue,
            arrival: arrival.rawValue
        )
        return busRepository.searchBusInformation(requestModel: request)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
    private func processDate(_ date: String) -> (String, String) {
        let dateFormatter = DateFormatter()
        var departDate: String
        var departTime: String
        
        dateFormatter.locale = Locale(identifier: "ko_kr")
        
        if date.prefix(2) == "오늘" {
            departDate = Date().formatDateToYYYYMMDD(separator: "-")
            dateFormatter.dateFormat = "오늘 a h:mm"
        } else if date.prefix(2) == "내일" {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            departDate = tomorrow.formatDateToYYYYMMDD(separator: "-")
            dateFormatter.dateFormat = "내일 a h:mm"
        } else {
            dateFormatter.dateFormat = "M월 d일(EEE) a h:mm"
            let formattedDate = Date().stringToDate(dateValue: date, dateFormatter: dateFormatter) ?? Date()
            departDate = returnIncludeYear(date: formattedDate).formatDateToYYYYMMDD(separator: "-")
            departTime = formattedDate.formatDateToHHMM(isHH: true)
            return (departDate, departTime)
        }
        let formattedDate = Date().stringToDate(dateValue: date, dateFormatter: dateFormatter) ?? Date()
        departTime = formattedDate.formatDateToHHMM(isHH: true)
        
        return (departDate, departTime)
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
