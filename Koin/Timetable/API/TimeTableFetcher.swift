//
//  TimeTableFetcher.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class TimeTableFetcher {
    let isStage: Bool = CommonVariables.isStage
    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct TimeTableAPI {
        static let scheme = "https"
        static let stageScheme = "http"
        static let productionHost = "api.koreatech.in"
        static let stageHost = "stage.api.koreatech.in"
        //static let path = "/circles"
    }
    
    func getTimeTables(semester: String, token: String) -> AnyPublisher<TimeTables, Error> {
        var components = URLComponents()
        components.scheme = isStage ? TimeTableAPI.stageScheme : TimeTableAPI.scheme
        components.host = isStage ? TimeTableAPI.stageHost : TimeTableAPI.productionHost
        components.path = "/timetables"
        components.queryItems = [
            URLQueryItem(name: "semester", value: semester),
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map{ $0.data }
        .decode(type: TimeTables.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func getSemesters() -> AnyPublisher<Array<Semester>, Error> {
        var components = URLComponents()
        components.scheme = isStage ? TimeTableAPI.stageScheme : TimeTableAPI.scheme
        components.host = isStage ? TimeTableAPI.stageHost : TimeTableAPI.productionHost
        components.path = "/semesters"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map{ $0.data }
        .decode(type: Array<Semester>.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func getLectures(semester: String) -> AnyPublisher<Array<Lecture>, Error> {
        var components = URLComponents()
        components.scheme = isStage ? TimeTableAPI.stageScheme : TimeTableAPI.scheme
        components.host = isStage ? TimeTableAPI.stageHost : TimeTableAPI.productionHost
        components.path = "/lectures"
        components.queryItems = [
            URLQueryItem(name: "semester_date", value: semester),
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map{ $0.data }
        .decode(type: Array<Lecture>.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    /*
     {
     "success": true
     }
     */
    func deleteLecture(id: Int, token: String) -> AnyPublisher<TimeTableResult, Error> {
        var components = URLComponents()
        components.scheme = isStage ? TimeTableAPI.stageScheme : TimeTableAPI.scheme
        components.host = isStage ? TimeTableAPI.stageHost : TimeTableAPI.productionHost
        components.path = "/timetable"
        components.queryItems = [
            URLQueryItem(name: "id", value: String(id)),
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map{ $0.data }
        .decode(type: TimeTableResult.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func addLecture(semester: String, lecture: Lecture, token: String) -> AnyPublisher<TimeTables, Error> {
        var components = URLComponents()
        components.scheme = isStage ? TimeTableAPI.stageScheme : TimeTableAPI.scheme
        components.host = isStage ? TimeTableAPI.stageHost : TimeTableAPI.productionHost
        components.path = "/timetables"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let timetableData = TimeTables(semester: semester, timetable: [
            lecture
        ])
        
        
        do {
            request.httpBody = try JSONEncoder().encode(timetableData)
        } catch let error {
            print(error)
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map{ $0.data }
        .decode(type: TimeTables.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
}

