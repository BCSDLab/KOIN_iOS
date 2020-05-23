//
//  CircleAPI.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine


class CircleFetcher {
    let isStage: Bool = true
    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct CircleAPI {
        static let scheme = "https"
        static let stageScheme = "http"
        static let productionHost = "api.koreatech.in"
        static let stageHost = "stage.api.koreatech.in"
        static let path = "/circles"
    }
    
    func getCircle(page: Int) -> AnyPublisher<Circles, Error> {
        var components = URLComponents()
        components.scheme = isStage ? CircleAPI.stageScheme : CircleAPI.scheme
        components.host = isStage ? CircleAPI.stageHost : CircleAPI.productionHost
        components.path = CircleAPI.path
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(10))
        ]
        
        var request = URLRequest(url: components.url!)
        print(components.url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
            }
            .print()
            .map{ $0.data }
            .decode(type: Circles.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getDetailCircle(id: Int) -> AnyPublisher<CircleDetail, Error> {
        var components = URLComponents()
        components.scheme = isStage ? CircleAPI.stageScheme : CircleAPI.scheme
        components.host = isStage ? CircleAPI.stageHost : CircleAPI.productionHost
        components.path = CircleAPI.path + "/\(id)"
        
        var request = URLRequest(url: components.url!)
        print(components.url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map{ $0.data }
        .decode(type: CircleDetail.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
}
