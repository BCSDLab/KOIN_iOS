//
//  TimeTableRequest.swift
//  koin
//
//  Created by 김나훈 on 4/3/24.
//

import Foundation

struct TimetableRequest: Encodable {
    let timetable: [TimetablePostRequest]
    let semester: String
}

struct TimetablePostRequest: Codable {
    let code: String
    let name: String 
    let grades: String
    let lectureClass: String
    let regularNumber: String
    let department: String
    let target: String
    let professor: String
    let isEnglish: String?
    let designScore: String
    let isElearning: String?
    let classTime: [Int]
    let classPlace: String? // 추가
    let memo: String? // 추가

    enum CodingKeys: String, CodingKey {
        case code, grades, department, target, professor, classTime = "class_time", classPlace = "class_place", memo
        case name = "class_title" // 수정
        case lectureClass = "lecture_class"
        case regularNumber = "regular_number"
        case isEnglish = "is_english"
        case designScore = "design_score"
        case isElearning = "is_elearning"
    }
}
