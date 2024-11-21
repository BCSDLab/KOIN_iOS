//
//  SemesterDTO.swift
//  koin
//
//  Created by 김나훈 on 3/31/24.
//

import Foundation

struct SemesterDTO: Decodable {
    let id: Int
    let semester: String
}


struct MySemesterDTO: Codable {
    let userID: Int
    let semesters: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case semesters
    }
}
