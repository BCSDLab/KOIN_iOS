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

struct SemestersDTO: Codable {
    let semesters: [String: [Semester]]
    func toDomain() -> [FrameData] {
            return semesters.map { semester, frames in
                let frameDTOs = frames.map { FrameDTO(id: $0.id, timetableName: $0.timetableName, isMain: $0.isMain) }
                return FrameData(semester: semester, frame: frameDTOs)
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
