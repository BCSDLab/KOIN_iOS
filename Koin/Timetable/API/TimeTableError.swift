//
//  TimeTableError.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

enum TimeTableError: Error {
    case parsing(description: String)
    case network(description: String)
}
