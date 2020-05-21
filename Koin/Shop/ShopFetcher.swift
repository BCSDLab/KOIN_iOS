//
//  ShopFetcher.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/04.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class StoreFetcher {
    let isStage: Bool = CommonVariables.isStage
    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct StoreAPI {
        static let scheme = "https"
        static let stageScheme = "http"
        static let productionHost = "api.koreatech.in"
        static let stageHost = "stage.api.koreatech.in"
        static let path = "/shops"
    }
    
    func getStore() -> AnyPublisher<Shops, Error> {
        var components = URLComponents()
        components.scheme = isStage ? StoreAPI.stageScheme : StoreAPI.scheme
        components.host = isStage ? StoreAPI.stageHost : StoreAPI.productionHost
        components.path = StoreAPI.path
        
        var request = URLRequest(url: components.url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .print()
        .map{ $0.data }
        .decode(type: Shops.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func getDetailStore(id: Int) -> AnyPublisher<Store, Error> {
        var components = URLComponents()
        components.scheme = isStage ? StoreAPI.stageScheme : StoreAPI.scheme
        components.host = isStage ? StoreAPI.stageHost : StoreAPI.productionHost
        components.path = StoreAPI.path + "/\(id)"
        
        var request = URLRequest(url: components.url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
                return error
        }
        .map{ $0.data }
        .decode(type: Store.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
}

