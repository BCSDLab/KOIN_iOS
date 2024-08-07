//
//  LectureDTO.swift
//  koin
//
//  Created by 김나훈 on 3/31/24.
//

import Foundation

struct LectureDTO: Codable {
    let code: String
    let name: String
    let grades: String
    let lectureClass: String
    let regularNumber: String
    let department: String
    let target: String
    let professor: String
    let isEnglish: String
    let designScore: String
    let isElearning: String
    let classTime: [Int]
    
    enum CodingKeys: String, CodingKey {
        case code, name, grades, department, target, professor
        case lectureClass = "lecture_class"
        case regularNumber = "regular_number"
        case isEnglish = "is_english"
        case designScore = "design_score"
        case isElearning = "is_elearning"
        case classTime = "class_time"
    }
}
