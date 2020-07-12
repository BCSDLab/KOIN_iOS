//
//  Parsing.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/05.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, KoinCommunityError> {
    let decoder = JSONDecoder()

    return Just(data)
        .decode(type: T.self, decoder: decoder)
        .mapError { error in
            .parsing(description: error.localizedDescription)
    }
    .eraseToAnyPublisher()
}

func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, UserError> {
    let decoder = JSONDecoder()
    
    return Just(data)
        .decode(type: T.self, decoder: decoder)
        .mapError { error in
            return UserError.parsing(description: error.localizedDescription)
    }
    .eraseToAnyPublisher()
}

func errorDecode<T: Decodable>(_ data: Data) -> AnyPublisher<T, UserError> {
    let decoder = JSONDecoder()
    
    return Just(data)
        .decode(type: T.self, decoder: decoder)
        .mapError { error in
            return UserError.parsing(description: error.localizedDescription)
    }
    .eraseToAnyPublisher()
}
