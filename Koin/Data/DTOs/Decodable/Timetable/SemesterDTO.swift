//
//  SemesterDto.swift
//  koin
//
//  Created by 김나훈 on 3/31/24.
//

import Foundation

struct SemesterDto: Decodable {
    let id: Int
    let semester: String
}


struct MySemesterDto: Codable {
    let userID: Int
    let semesters: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case semesters
    }
}

struct SemestersDto: Codable {
    let semesters: [String: [Semester]]
    func toDomain() -> [FrameData] {
            return semesters.map { semester, frames in
                let frameDtos = frames.map { FrameDto(id: $0.id, timetableName: $0.timetableName, isMain: $0.isMain) }
                return FrameData(semester: semester, frame: frameDtos)
            }
        }
}

struct Semester: Codable {
    let id: Int
    let timetableName: String
    let isMain: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case timetableName = "timetable_name"
        case isMain = "is_main"
    }
}
