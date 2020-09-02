//
//  HomeFetcher.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/31.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class HomeFetcher {
    let isStage: Bool = CommonVariables.isStage
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
        shuttleTimeTables = [
            "koreatech": shuttleFromKoreatech,
            "terminal": shuttleFromTerminal
        ]
    }
    
    struct HomeAPI {
        static let scheme = "https"
        static let stageScheme = "http"
        static let productionHost = "api.koreatech.in"
        static let stageHost = "stage.api.koreatech.in"
        //static let path = "/shops"
    }
    
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
    
    let expressFromTerminalToKoreatech:[String]  = [
        "07:00",
        "08:00",
        "09:00",
        "10:00",
        "11:00",
        "12:00",
        "13:00",
        "14:00",
        "15:00",
        "16:00",
        "17:00",
        "18:00",
        "19:00",
        "20:30"
    ]
    
    let expressFromKoreatechToTerminal:[String] = [
        "08:35",
        "09:35",
        "10:35",
        "11:35",
        "12:35",
        "13:35",
        "14:35",
        "15:30",
        "16:35",
        "17:35",
        "18:35",
        "19:35",
        "20:35",
        "22:05"
    ]
    
    let shuttleTimeTables: Dictionary<String, [[String]]>
    
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
    
    func getShuttle(depart: String, arrival: String) -> Date {
        let shuttleTimeTable = getCurrentDayShuttleDayStringArray(depart: depart, arrival: arrival)
        var resultNowIndex: Int
        
        if (shuttleTimeTable.isEmpty) {
            return Date()
        }
        resultNowIndex = getBusTimeIndex(timetable: shuttleTimeTable, startIndex: 0)
        if (resultNowIndex == -1 || resultNowIndex >= shuttleTimeTable.count) {
            return Date()
        }
        return getRemainTimeToDate(timetable: shuttleTimeTable, startIndex: 0)
    }
    
    func getExpress(depart: String, arrival: String) -> Date {
        let expressTimeTable = getCurrentDayExpressDayStringArray(depart: depart, arrival: arrival)
        var resultNowIndex: Int
        
        if (expressTimeTable.isEmpty) {
            return Date()
        }
        resultNowIndex = getBusTimeIndex(timetable: expressTimeTable, startIndex: 0)
        
        if (resultNowIndex == -1 || resultNowIndex >= expressTimeTable.count) {
            return Date()
        }
        return getRemainTimeToDate(timetable: expressTimeTable, startIndex: 0)
    }
    
    func getCurrentDayShuttleDayStringArray(depart: String, arrival: String) -> [String] {
        var shuttleTimeTable: [String]
        let weekday = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        let timeTable = shuttleTimeTables[depart]!
        shuttleTimeTable = timeTable[weekday]
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
    
    func getCityBus(depart: String, arrival: String) -> AnyPublisher<CityBus, Error> {
        
        var components = URLComponents()
        components.scheme = isStage ? HomeAPI.stageScheme : HomeAPI.scheme
        components.host = isStage ? HomeAPI.stageHost : HomeAPI.productionHost
        components.path = "/buses"
        components.queryItems = [
            URLQueryItem(name: "depart", value: depart),
            URLQueryItem(name: "arrival", value: arrival)
        ]
        
        var request = URLRequest(url: components.url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map {
            $0.data
        }
        .print()
        .decode(type: CityBus.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func getMeal() -> AnyPublisher<Array<DiningRequest>, Error> {
        var date = Date()
        
        let hour = Calendar.current.component(.hour, from: date)
        // 현재 분
        let minute = Calendar.current.component(.minute, from: date)
        
        if (hour >= 14 && hour < 19) { // 14시부터 18시 반까지 저녁
            if (hour == 18 && minute > 30) { // 18시 반을 넘으면 다음 날로 이동해서 아침
                date = Date(timeInterval: 86400, since: date)
            }
        } else if (hour >= 19 && hour < 24) { // 19시부터 24시까지 다음날로 이동해서 아침
            date = Date(timeInterval: 86400, since: date)
        }
        
        //date 포맷 설정하는 오브젝트 불러오기
        let dateFormatter = DateFormatter()
        // 시간대 설정
        dateFormatter.locale = Locale(identifier: "ko_kr")
        // date 포맷 설정
        dateFormatter.dateFormat = "yyMMdd"
        // date 포맷에 맞춰 Date에서 String으로 변경
        let dateString: String = dateFormatter.string(from: date)
        
        print(dateString)
        
        var components = URLComponents()
        components.scheme = isStage ? HomeAPI.stageScheme : HomeAPI.scheme
        components.host = isStage ? HomeAPI.stageHost : HomeAPI.productionHost
        components.path = "/dinings"
        components.queryItems = [
            URLQueryItem(name: "date", value: dateString),
        ]
        
        var request = URLRequest(url: components.url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map {
            $0.data
        }
            .print()
        .decode(type: Array<DiningRequest>.self, decoder: JSONDecoder())
    
        .eraseToAnyPublisher()
    }
    
}
