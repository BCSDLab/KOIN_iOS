//
//  CityBusTimetableDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/29/24.
//

import Foundation

struct CityBusTimetableDTO: Decodable {
    let updatedAt: String?
    let busInfo: CityBusInfo
    let busTimetables: [CityBusTimetable]?

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case busInfo = "bus_info"
        case busTimetables = "bus_timetables"
    }
}

struct CityBusInfo: Decodable {
    let number: BusNumber?
    let departNode, arrivalNode: CityBusDirection?

    enum CodingKeys: String, CodingKey {
        case number
        case departNode = "depart_node"
        case arrivalNode = "arrival_node"
    }
}

struct CityBusTimetable: Decodable {
    let dayOfWeek: String?
    let departInfo: [String]?

    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case departInfo = "depart_info"
    }
}

extension CityBusTimetableDTO {
    func toDomain() -> BusTimetableInfo {
        var arrivalInfos: [BusArrivalInfo] = []
        var updatedAtText: String = ""
        if let updatedAt = updatedAt {
            let updatedComponents = updatedAt.components(separatedBy: " ")
            updatedAtText = updatedComponents.first ?? ""
        }
        
        if let busTimetable = busTimetables?.first,
           let departInfos = busTimetable.departInfo {
            var numberOfMorning: Int = -1
            for idx in 0..<departInfos.count {
                if !isMorning(timeString: departInfos[idx]) {
                    numberOfMorning = idx
                    print(numberOfMorning)
                    break
                }
            }
            
            let numberOfAfternoon: Int = departInfos.count - numberOfMorning
            let lastMorningAndAfternoonIdx: Int = numberOfAfternoon > numberOfMorning ? numberOfMorning : numberOfAfternoon
            for idx in 0..<lastMorningAndAfternoonIdx {
                let arrivalInfo = BusArrivalInfo(leftNode: departInfos[idx], rightNode: departInfos[idx + lastMorningAndAfternoonIdx])
                arrivalInfos.append(arrivalInfo)
            }
            
            if numberOfAfternoon > numberOfMorning {
                for idx in lastMorningAndAfternoonIdx * 2..<departInfos.count {
                    let arrivalInfo = BusArrivalInfo(leftNode: nil, rightNode: departInfos[idx])
                    arrivalInfos.append(arrivalInfo)
                }
            }
            else if numberOfAfternoon < numberOfMorning {
                for idx in lastMorningAndAfternoonIdx..<departInfos.count {
                    let arrivalInfo = BusArrivalInfo(leftNode: departInfos[idx], rightNode: nil)
                    arrivalInfos.append(arrivalInfo)
                }
            }
        }
        return BusTimetableInfo(arrivalInfos: arrivalInfos, updatedAt: updatedAtText)
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
