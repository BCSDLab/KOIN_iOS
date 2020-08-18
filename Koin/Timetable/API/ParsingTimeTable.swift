//
//  ParsingTimeTable.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

func decode(_ data: Data) -> AnyPublisher<TimeTables, TimeTableError> {
    let decoder = JSONDecoder()
    
    return Just(data)
        .print()
        .decode(type: TimeTables.self, decoder: decoder)
        .print()
        .mapError { error in
            .parsing(description: error.localizedDescription)
    }
    .eraseToAnyPublisher()
}
