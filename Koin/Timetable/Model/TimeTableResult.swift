//
//  TimeTableResult.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/20.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct TimeTableResult: Codable, Hashable {
    let success: Bool
    private enum CodingKeys: String, CodingKey {
        case success = "success"

    }
}

