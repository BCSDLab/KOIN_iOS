//
//  Semester.swift
//  Koin
//
//  Created by 정태훈 on 2020/07/20.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Semester: Codable, Hashable {
    let id: Int
    let semester: String
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case semester = "samester"
    }
}
