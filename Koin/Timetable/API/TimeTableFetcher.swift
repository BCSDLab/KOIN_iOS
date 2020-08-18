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
        .print()
        .map{ $0.data }
        .decode(type: TimeTables.self, decoder: JSONDecoder())
        .print()
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
        .print()
        .map{ $0.data }
        .decode(type: Array<Semester>.self, decoder: JSONDecoder())
        .print()
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
        .print()
        .map{ $0.data }
        .decode(type: Array<Lecture>.self, decoder: JSONDecoder())
        .print()
        .eraseToAnyPublisher()
    }
    
}

