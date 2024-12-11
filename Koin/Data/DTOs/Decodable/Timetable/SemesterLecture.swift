//
//  SemesterLecture.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

struct SemesterLecture: Codable, Equatable {
    let id: Int
    let code, name, grades, lectureClass: String
    let regularNumber, professor: String?
    let department, target: String
    let isEnglish, designScore, isElearning: String
    let classTime: [Int]

    enum CodingKeys: String, CodingKey {
        case id, code, name, grades
        case lectureClass = "lecture_class"
        case regularNumber = "regular_number"
        case department, target, professor
        case isEnglish = "is_english"
        case designScore = "design_score"
        case isElearning = "is_elearning"
        case classTime = "class_time"
    }
}
