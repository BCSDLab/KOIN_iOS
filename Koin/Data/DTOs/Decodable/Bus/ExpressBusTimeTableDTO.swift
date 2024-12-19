//
//  BusTimeTableDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
// nullable 주민경

import Foundation

// MARK: - BusTimetable
struct ExpressTimetable: Decodable {
    let departure, arrival: String
    let charge: Int
}

struct ExpressTimetableDTO: Decodable {
    let expressTimeTable: [ExpressTimetable]?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case expressTimeTable = "bus_timetables"
        case updatedAt = "updated_at"
    }
    
}

extension ExpressTimetableDTO {
    func toDomain() -> BusTimetableInfo {
        var updatedAtText: String = ""
        var arrivalInfos: [BusArrivalInfo] = []
        if let updatedAt = updatedAt {
            let updatedComponents = updatedAt.components(separatedBy: " ")
            updatedAtText = updatedComponents.first ?? ""
        }
        if let departInfos = expressTimeTable {
            var numberOfMorning: Int = -1
            for idx in 0..<departInfos.count {
                if !isMorning(timeString: departInfos[idx].departure) {
                    numberOfMorning = idx
                    break
                }
            }
            
            let numberOfAfternoon: Int = departInfos.count - numberOfMorning
            let lastMorningAndAfternoonIdx: Int = numberOfAfternoon > numberOfMorning ? numberOfMorning : numberOfAfternoon
            for idx in 0..<lastMorningAndAfternoonIdx {
                let arrivalInfo = BusArrivalInfo(leftNode: departInfos[idx].departure, rightNode: departInfos[idx + lastMorningAndAfternoonIdx].departure)
                arrivalInfos.append(arrivalInfo)
            }
            
            if numberOfAfternoon > numberOfMorning {
                for idx in lastMorningAndAfternoonIdx * 2..<departInfos.count {
                    let arrivalInfo = BusArrivalInfo(leftNode: nil, rightNode: departInfos[idx].departure)
                    arrivalInfos.append(arrivalInfo)
                }
            }
            else if numberOfAfternoon < numberOfMorning {
                for idx in lastMorningAndAfternoonIdx..<departInfos.count {
                    let arrivalInfo = BusArrivalInfo(leftNode: departInfos[idx].departure, rightNode: nil)
                    arrivalInfos.append(arrivalInfo)
                }
            }
        }
        let timetableinfo = BusTimetableInfo(arrivalInfos: arrivalInfos, updatedAt: updatedAtText)
        return timetableinfo
    }
    
    private func isMorning(timeString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let date = dateFormatter.date(from: timeString) else {
            return false
        }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        return hour >= 0 && hour < 12
    }
}
