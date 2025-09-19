//
//  TimeTableDto.swift
//  koin
//
//  Created by 김나훈 on 4/1/24.
//

import Foundation

struct TimetablesDto: Decodable {
    let totalGrades: Int?
    let semester: String
    let grades: Int?
    let timetable: [TimetableDto]
    
    enum CodingKeys: String, CodingKey {
        case totalGrades = "total_grades"
        case semester, grades, timetable
    }
}

struct TimetableDto: Codable {
    let regularNumber, code, designScore: String
    let classTime: [Int]
    let grades, classTitle: String
    let lectureClass, target, professor: String
    let id: Int
    let department: String
    let memo, classPlace: String?
    
    enum CodingKeys: String, CodingKey {
        case regularNumber = "regular_number"
        case code
        case designScore = "design_score"
        case classTime = "class_time"
        case classPlace = "class_place"
        case memo, grades
        case classTitle = "class_title"
        case lectureClass = "lecture_class"
        case target, professor, id, department
    }
}
