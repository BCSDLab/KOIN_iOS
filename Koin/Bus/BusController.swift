//
//  BusController.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/08.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

class BusController {
    /*
    let expressFromKoreatechToTerminal:[String] = [
            "08:00",
            "09:35",
            "10:30",
            "11:45",
            "12:35",
            "14:00",
            "15:05",
            "16:00",
            "16:55",
            "18:05",
            "18:55",
            "20:00",
            "21:05",
            "21:55"
    ]*/
    let expressFromKoreatechToTerminal:[String] = [
            "08:35",
            "10:35",
            "12:35",
            "14:35",
            "16:35",
            "18:35",
            "20:35"
    ]
    let objectWillChange = PassthroughSubject<BusController, Never>()
    /*
    let expressFromTerminalToKoreatech:[String]  = [
            "07:00",
            "07:30",
            "09:00",
            "10:00",
            "10:30",
            "11:00",
            "12:00",
            "13:00",
            "14:00",
            "14:30",
            "15:00",
            "16:00",
            "17:00",
            "17:50",
            "19:30",
            "20:30",
            "21:00"
    ]*/
    let expressFromTerminalToKoreatech:[String]  = [
            "08:00",
            "10:00",
            "12:00",
            "14:00",
            "16:00",
            "18:00",
            "20:30"
    ]
    
    let shuttleFromKoreatech:[[String]]  = [
            [ // 월요일
                    
                        "09:10",
                        "11:00",
                        "14:00",
                        "15:00",
                        "16:00",
                        "16:30",
                        "17:00",
                        "19:30",
                        "21:00",
                        "22:40"
                     
                    // 2019-동계방학
                    //"14:00"
            ],
            [ // 화요일
                    
                        "09:10",
                        "11:00",
                        "14:00",
                        "15:00",
                        "16:00",
                        "16:30",
                        "17:00",
                        "19:30",
                        "21:00",
                        "22:40"
                     
                    // 2019-동계방학
                    //"14:00"
            ],
            [ // 수요일
                    
                        "09:10",
                        "11:00",
                        "14:00",
                        "15:00",
                        "16:00",
                        "16:30",
                        "17:00",
                        "19:30",
                        "21:00",
                        "22:40"
                     
                    // 2019-동계방학
                    //"14:00"
            ],
            [ // 목요일
                    
                        "09:10",
                        "11:00",
                        "14:00",
                        "15:00",
                        "16:00",
                        "16:30",
                        "17:00",
                        "19:30",
                        "21:00",
                        "22:40"
                     
                    // 2019-동계방학
                    //"14:00"
            ],
            [ // 금요일
                    
                        "09:10",
                        "11:00",
                        "14:00",
                        "14:30",
                        "15:00",
                        "16:00",
                        "16:30",
                        "17:00",
                        "19:30",
                        "21:00",
                        "22:40"
                     
                    // 2019-동계방학
                    //"14:00"
            ],
            [ // 토요일
                    
                        "14:00"
                     
            ],
            [ // 일요일
                    
                        "17:00"
                     
            ]
    ]
    
    let shuttleFromTerminal:[[String]] = [
            [ // 월요일
                    
                        "08:00",
                        "10:10",
                        "11:25",
                        "14:25",
                        "16:05",
                        "16:25",
                        "16:55",
                        "17:25",
                        "18:45",
                        "19:55",
                        "22:00"
                     
                    // 2019-동계방학
                    //"08:00",
                    //"14:25"
            ],
            [ // 화요일
                    
                        "08:00",
                        "10:10",
                        "11:25",
                        "14:25",
                        "16:05",
                        "16:25",
                        "16:55",
                        "17:25",
                        "18:45",
                        "19:55",
                        "22:00"
                     
                    // 2019-동계방학
                    //"08:00",
                    //"14:25"
            ],
            [ // 수요일
                    
                        "08:00",
                        "10:10",
                        "11:25",
                        "14:25",
                        "16:05",
                        "16:25",
                        "16:55",
                        "17:25",
                        "18:45",
                        "19:55",
                        "22:00"
                     
                    // 2019-동계방학
                    //"08:00",
                    //"14:25"
            ],
            [ // 목요일
                    
                        "08:00",
                        "10:10",
                        "11:25",
                        "14:25",
                        "16:05",
                        "16:25",
                        "16:55",
                        "17:25",
                        "18:45",
                        "19:55",
                        "22:00"
                     
                    // 2019-동계방학
                    //"08:00",
                    //"14:25"
            ],
            [ // 금요일
                    
                        "08:00",
                        "10:10",
                        "11:25",
                        "14:25",
                        "16:05",
                        "16:25",
                        "16:55",
                        "17:25",
                        "18:45",
                        "19:55",
                        "22:00"
                     
                    // 2019-동계방학
                    //"08:00",
                    //"14:25"
            ],
            [ // 토요일
                    
                        "14:25",
                        "18:45"
                     
            ],
            [ // 일요일
                    
                        "17:30",
                        "21:15",
                        "21:30"
                     
            ]
    ]
    
    let shuttleFromStationToKoreatech:[[String]] = [
            [ // 월요일
                    
                        "08:05",
                        "10:15",
                        "11:30",
                        "14:30",
                        "16:10",
                        "16:30",
                        "17:00",
                        "17:30",
                        "18:50",
                        "20:00",
                        "22:05"
                     
                    // 2019-동계방학
                    //"08:05",
                    //"14:30"
            ],
            [ // 화요일
                    
                        "08:05",
                        "10:15",
                        "11:30",
                        "14:30",
                        "16:10",
                        "16:30",
                        "17:00",
                        "17:30",
                        "18:50",
                        "20:00",
                        "22:05"
                     
                    // 2019-동계방학
                    //"08:05",
                    //"14:30"
            ],
            [ // 수요일
                    
                        "08:05",
                        "10:15",
                        "11:30",
                        "14:30",
                        "16:10",
                        "16:30",
                        "17:00",
                        "17:30",
                        "18:50",
                        "20:00",
                        "22:05"
                     
                    // 2019-동계방학
                    //"08:05",
                    //"14:30"
            ],
            [ // 목요일
                    
                        "08:05",
                        "10:15",
                        "11:30",
                        "14:30",
                        "16:10",
                        "16:30",
                        "17:00",
                        "17:30",
                        "18:50",
                        "20:00",
                        "22:05"
                     
                    // 2019-동계방학
                    //"08:05",
                    //"14:30"
            ],
            [ // 금요일
                    
                        "08:05",
                        "10:15",
                        "11:30",
                        "14:30",
                        "16:10",
                        "16:30",
                        "17:00",
                        "17:30",
                        "18:50",
                        "20:00",
                        "22:05"
                     
                    // 2019-동계방학
                    //"08:05",
                    //"14:30"
            ],
            [ // 토요일
                    
                        "14:30",
                        "18:50"
                     
            ],
            [ // 일요일
                    
                        "17:35",
                        "21:20",
                        "21:35"
                     
            ]
    ]
    
    let shuttleFromStationToTerminal:[[String]] = [
            [ // 월요일
                    
                        "09:30",
                        "15:20"
                     
            ],
            [ // 화요일
                    
                        "09:30",
                        "15:20"
                     
            ],
            [ // 수요일
                    
                        "09:30",
                        "15:20"
                     
            ],
            [ // 목요일
                    
                        "09:30",
                        "15:20"
                     
            ],
            [ // 금요일
                    
                        "09:30",
                        "15:20"
                     
            ],
            [ // 토요일
            ],
            [ // 일요일
            ]
    ]
    
    let shuttleTimeTables: Dictionary<String, [[String]]>
    
    init() {
        shuttleTimeTables = [
            "koreatech": shuttleFromKoreatech,
            "terminal": shuttleFromTerminal
        ]
    }
    
    func getRemainTimeToDate(timetable: [String], startIndex: Int) -> Date {
        let date = DateFormatter()
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST")
        
        if timetable.count == 0 {
            return Date()
        }
        
        for i in startIndex..<timetable.count {
            let time = timetable[i].split(separator: ":")
            let timetableDate = Calendar.current.date(bySettingHour: Int(time[0])!, minute: Int(time[1])!, second: 0, of: Date())!
            let interval = timetableDate.timeIntervalSince(Date())
            if interval > 0 {
                return timetableDate
            }
        }
        return Date()
    }
    
    func getBusTimeIndex(timetable: [String], startIndex: Int) -> Int {
        
        if timetable.count == 0 {
            return -1
        }
        
        for i in startIndex..<timetable.count {
            let time = timetable[i].split(separator: ":")
            if let timetableDate = Calendar.current.date(bySettingHour: Int(time[0])!, minute: Int(time[1])!, second: 0, of: Date()) {
                let interval = timetableDate.timeIntervalSince(Date())
                if interval > 0 {
                    return i
                }
            }
            
        }
        return -1
    }
    
    func getBusTimeIndex(timetable: [String], hour: Int, min: Int) -> Int {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_kr")
        dateformatter.timeZone = TimeZone(abbreviation: "KST")
        dateformatter.dateFormat = "HH:mm"
        
        let stringTime = String(format: "%02d", hour) + ":" + String(format: "%02d", min)
        let endDate = dateformatter.date(from: stringTime)!

        
        if timetable.count == 0 {
            return -1
        }
        for i in 0..<timetable.count {
            let timetableDate = dateformatter.date(from: timetable[i])
            let interval = timetableDate!.timeIntervalSince(endDate)
            if interval > 0 {
                return i
            }
        }
        return -1
    }
    
    func getRemainCityBusTimeToDate(depart: String, arrival: String) -> Date{
        var remainTime: Int = 0
       AF.request("http://api.koreatech.in/buses?depart=\(depart)&arrival=\(arrival)", method: .get, encoding: JSONEncoding.prettyPrinted)
        .response { response in
            guard let data = response.data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let cityBusRequest = try decoder.decode(CityBus.self, from: data)
                if let remain = cityBusRequest.remainTime {
                    remainTime = remain
                } else {
                    remainTime = 0
                }
                
            } catch let error {
                remainTime = 0
            }

        }
        return Date(timeIntervalSinceNow: TimeInterval(remainTime))
    }
    
    func getRemainCityBusTimeToString(depart: String, arrival: String) -> String {
        let remainDate = getRemainCityBusTimeToDate(depart: depart, arrival: arrival)
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_kr")
        dateformatter.timeZone = TimeZone(abbreviation: "KST")
        dateformatter.dateFormat = "hh:mm"
        
        return dateformatter.string(from: remainDate)
    }
    func getNextCityBusTimeToString(depart: String, arrival: String) -> String {
        let nextDate = getNextCityBusTimeToDate(depart: depart, arrival: arrival)
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_kr")
        dateformatter.timeZone = TimeZone(abbreviation: "KST")
        dateformatter.dateFormat = "hh:mm"
        
        return dateformatter.string(from: nextDate)
    }
    
    func getNextCityBusTimeToDate(depart: String, arrival: String) -> Date{
        var nextRemainTime: Int = 0
       AF.request("https://api.koreatech.in/buses?depart=\(depart)&arrival=\(arrival)", method: .get, encoding: JSONEncoding.prettyPrinted)
        .response { response in
            guard let data = response.data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let cityBusRequest = try decoder.decode(CityBus.self, from: data)
                if let remain = cityBusRequest.nextRemainTime {
                    nextRemainTime = remain
                } else {
                    nextRemainTime = 0
                }
            } catch let error {
                nextRemainTime = 0
            }

        }
        return Date(timeIntervalSinceNow: TimeInterval(nextRemainTime))
    }
    
    func getRemainShuttleTimeToDate(depart: String, arrival: String, isNow: Bool) -> Date {
        let shuttleTimeTable = getCurrentDayShuttleDayStringArray(depart: depart, arrival: arrival)
        var resultNowIndex: Int
        
        if (shuttleTimeTable.isEmpty) {
            return Date()
        }
        resultNowIndex = getBusTimeIndex(timetable: shuttleTimeTable, startIndex: 0)
        if (resultNowIndex == -1 || resultNowIndex >= shuttleTimeTable.count) {
            return Date()
        }
        if (isNow) {
            return getRemainTimeToDate(timetable: shuttleTimeTable, startIndex: 0)
        } else if (resultNowIndex + 1 >= shuttleTimeTable.count) {
            return Date()
        } else {
            return getRemainTimeToDate(timetable: shuttleTimeTable, startIndex: resultNowIndex + 1)
        }
    }
    
    func getRemainExpressTimeToDate(depart: String, arrival: String, isNow: Bool) -> Date {
        let expressTimeTable = getCurrentDayExpressDayStringArray(depart: depart, arrival: arrival)
        var resultNowIndex: Int
        
        if (expressTimeTable.isEmpty) {
            return Date()
        }
        resultNowIndex = getBusTimeIndex(timetable: expressTimeTable, startIndex: 0)

        if (resultNowIndex == -1 || resultNowIndex >= expressTimeTable.count) {
            return Date()
        }
        if (isNow) {
            return getRemainTimeToDate(timetable: expressTimeTable, startIndex: 0)
        } else if (resultNowIndex + 1 >= expressTimeTable.count) {
            return Date()
        } else {
            return getRemainTimeToDate(timetable: expressTimeTable, startIndex: resultNowIndex + 1)
        }
    }
    
    func getNearShuttleTimeToString(depart: String, arrival: String, isNow: Bool) -> String {
        let shuttleTimeTable = getCurrentDayShuttleDayStringArray(depart: depart, arrival: arrival)
        var resultNowIndex: Int
        
        if shuttleTimeTable.isEmpty {
            return ""
        }
        resultNowIndex = getBusTimeIndex(timetable: shuttleTimeTable, startIndex: 0)
        if (resultNowIndex == -1 || resultNowIndex >= shuttleTimeTable.count) {
            return ""
        }
        
        if (isNow) {
            return shuttleTimeTable[resultNowIndex]
        } else if (resultNowIndex + 1 >= shuttleTimeTable.count) {
            return ""
        } else {
            return shuttleTimeTable[resultNowIndex+1]
        }
    }
    
    func getNearShuttleTimeToString(depart: String, arrival: String, year:Int,month:Int, day:Int, hour: Int, min: Int) -> String {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_kr")
        dateformatter.timeZone = TimeZone(abbreviation: "KST")
        dateformatter.dateFormat = "yyyyMMdd"
        
        let stringDate = String(format: "%04d", year) + String(format: "%02d", month) + String(format: "%02d", day)
        let endDate = dateformatter.date(from: stringDate)!
        let weekday = (Calendar.current.component(.weekday, from: endDate) + 6) % 7
        
        let shuttleTimeTable = getCurrentDayShuttleDayStringArray(depart: depart, arrival: arrival, dayType: weekday)
        var resultNowIndex: Int
        
        if shuttleTimeTable.isEmpty {
            return ""
        }
        resultNowIndex = getBusTimeIndex(timetable: shuttleTimeTable, hour: hour, min: min)
        if (resultNowIndex == -1 || resultNowIndex >= shuttleTimeTable.count) {
            return ""
        }
        return shuttleTimeTable[resultNowIndex]
        
    }
    
    func getNearExpressTimeToString(depart: String, arrival: String, isNow:Bool) -> String {
        let expressTimeTable = getCurrentDayExpressDayStringArray(depart: depart, arrival: arrival)
        
        
        
        var resultNowIndex: Int
        
        if (expressTimeTable.isEmpty) {
            return ""
        }
        resultNowIndex = getBusTimeIndex(timetable: expressTimeTable, startIndex: 0)
        if (resultNowIndex == -1 || resultNowIndex >= expressTimeTable.count) {
            return ""
        }
        if (isNow) {
            return expressTimeTable[resultNowIndex]
        } else if (resultNowIndex + 1 >= expressTimeTable.count) {
            return ""
        } else {
            return expressTimeTable[resultNowIndex+1]
        }
        
    }
    
    func getNearExpressTimeToString(depart: String, arrival: String, hour: Int, min: Int) -> String {
        let expressTimeTable = getCurrentDayExpressDayStringArray(depart: depart, arrival: arrival)
        var resultNowIndex: Int
        
        if (expressTimeTable.isEmpty) {
            return ""
        }
        resultNowIndex = getBusTimeIndex(timetable: expressTimeTable, hour: hour, min: min)
        if (resultNowIndex == -1 || resultNowIndex >= expressTimeTable.count) {
            return ""
        }
        return expressTimeTable[resultNowIndex]
    }
    
    func getCurrentDayShuttleDayStringArray(depart: String, arrival: String) -> [String] {
        var shuttleTimeTable: [String]
        let weekday = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        if depart == "station" {
            shuttleTimeTable = (arrival == "koreatech") ? shuttleFromStationToKoreatech[weekday] : shuttleFromStationToTerminal[weekday]
        } else {
            let timeTable = shuttleTimeTables[depart]!
            shuttleTimeTable = timeTable[weekday]
        }
        return shuttleTimeTable
    }
    
    func getCurrentDayShuttleDayStringArray(depart: String, arrival: String, dayType: Int) -> [String] {
        var shuttleTimeTable: [String]
        let weekday = dayType % 7
        
        if (depart == "station") {
            shuttleTimeTable = arrival == "koreatech" ? shuttleFromStationToKoreatech[weekday] : shuttleFromStationToTerminal[weekday]
        } else {
            let timeTable = shuttleTimeTables[depart]
            shuttleTimeTable = timeTable![weekday]
        }
        
        return shuttleTimeTable
        
    }
    
    func getCurrentDayExpressDayStringArray(depart: String, arrival: String) -> [String] {
        var expressTimeTable: [String] = []
        if (depart == "koreatech" && arrival == "terminal") {
            expressTimeTable = expressFromKoreatechToTerminal
        } else if (depart == "terminal" && arrival == "koreatech") {
            expressTimeTable = expressFromTerminalToKoreatech
        }
        return expressTimeTable
    }
    
    
}
