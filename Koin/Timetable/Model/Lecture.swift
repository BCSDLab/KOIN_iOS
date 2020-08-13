//
//  Lecture.swift
//  Koin
//
//  Created by 정태훈 on 2020/07/20.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Lecture: Codable, Hashable {
    let id: Int
    let code: String
    let classTitle: String
    let classPlace: String?
    let memo: String?
    let grades: String
    let lectureClass: String
    let regularNumber: String
    let department: String
    let target: String
    let professor: String
    let designScore: String
    let classTime: Array<Int>
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case code = "code"
        case classTitle = "class_title"
        case classPlace = "class_place"
        case memo = "memo"
        case grades = "grades"
        case lectureClass = "lecture_class"
        case regularNumber = "regular_number"
        case department = "department"
        case target = "target"
        case professor = "professor"
        case designScore = "design_score"
        case classTime = "class_time"
    }
}
