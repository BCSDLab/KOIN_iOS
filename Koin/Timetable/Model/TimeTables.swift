//
//  TimeTables.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/12.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct TimeTables: Codable {
    let semester: String
    let timetable: Array<Lecture>
    
    private enum CodingKeys: String, CodingKey {
        case semester
        case timetable
    }
}
