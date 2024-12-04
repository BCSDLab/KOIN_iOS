//
//  FrameDTO.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Foundation

struct FrameDTO: Decodable {
    let id: Int
    var timetableName: String
    var isMain: Bool
    enum CodingKeys: String, CodingKey {
        case id
        case timetableName = "timetable_name"
        case isMain = "is_main"
    }
}
