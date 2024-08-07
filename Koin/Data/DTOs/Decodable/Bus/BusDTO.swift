//
//  BusResponse.swift
//  koin
//
//  Created by p on 3/18/24.
// nullable 주민경 2024/05/02

import Foundation

struct BusDTO: Decodable {
    let busType: BusType?
    let nowBus: BusDetailDTO?
    let nextBus: BusDetailDTO?

    enum CodingKeys: String, CodingKey {
        case busType = "bus_type"
        case nowBus = "now_bus"
        case nextBus = "next_bus"
    }
}

struct BusDetailDTO: Decodable {
    let busNumber: Int?
    let remainTime: Int?
    enum CodingKeys: String, CodingKey {
        case busNumber = "bus_number"
        case remainTime = "remain_time"
    }
}

extension BusDTO {
    func toEntity(departedPlace: BusPlace, arrivedPlace: BusPlace) -> BusCardInformation {
        var remainTimeText: String
        var departedTimeText: String?
        
        if let remainTime = nowBus?.remainTime {
            remainTimeText = calculateRemainTimeToDate(remainTime: remainTime)
            departedTimeText = calculateDepatureTimeToDate(remainTime: remainTime)
        }
        else {
            remainTimeText = "운행정보없음"
            departedTimeText = nil
        }

        var nextRemainTimeText: String
        var nextDepartedTimeText: String?
        
        if let nextRemainTime = nextBus?.remainTime {
            nextRemainTimeText = calculateRemainTimeToDate(remainTime: nextRemainTime)
            nextDepartedTimeText = calculateDepatureTimeToDate(remainTime: nextRemainTime)
        }
        else {
            nextRemainTimeText = "운행정보없음"
            nextDepartedTimeText = nil
        }
        
        var busNumberText: String?
        var nextBusNumberText: String?
        
        if let busNumber = nowBus?.busNumber {
            busNumberText = "\(busNumber)번 버스"
        }
        
        if let nextBusNumber = nextBus?.busNumber {
            nextBusNumberText = "\(nextBusNumber)번 버스"
        }
        
        let nextBus = NextBusInformation(departedTime: nextDepartedTimeText, remainTime: nextRemainTimeText, busNumber: nextBusNumberText)
        return BusCardInformation(busTitle: busType ?? .shuttleBus, departedPlace: departedPlace, arrivedPlace: arrivedPlace, remainTime: remainTimeText, departedTime: departedTimeText, busNumber: busNumberText, nextBusInfo: nextBus)
    }
    
    func calculateDepatureTimeToDate(remainTime: Int) -> String {
        let departureDate = Date().addingTimeInterval(TimeInterval(remainTime + 60))
        return "\(departureDate.formatDateToHHMM(isHH: true)) 출발"
    }
    
    func calculateRemainTimeToDate(remainTime: Int) -> String {
        let hours = remainTime / 3600
        let minutes = (remainTime % 3600) / 60
        return "\(hours)시간 \(minutes)분 남음"
    }
}
