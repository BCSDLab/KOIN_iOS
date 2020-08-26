//
//  Lecture.swift
//  Koin
//
//  Created by 정태훈 on 2020/07/20.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Lecture: Codable, Hashable, Equatable {
    let id: Int?
    let code: String
    let classTitle: String?
    let name: String?
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
        case name = "name"
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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(Int.self, forKey: .id)
        code = try values.decode(String.self, forKey: .code)
        if ((try? values.decode(String.self, forKey: .name)) != nil) {
            classTitle = try values.decode(String.self, forKey: .name)
            name = try values.decode(String.self, forKey: .name)
        }else {
            classTitle = try values.decode(String.self, forKey: .classTitle)
            name = try values.decode(String.self, forKey: .classTitle)
        }
        classPlace = try? values.decode(String.self, forKey: .classPlace)
        memo = try? values.decode(String.self, forKey: .memo)
        grades = try values.decode(String.self, forKey: .grades)
        lectureClass = try values.decode(String.self, forKey: .lectureClass)
        regularNumber = try values.decode(String.self, forKey: .regularNumber)
        department = try values.decode(String.self, forKey: .department)
        target = try values.decode(String.self, forKey: .target)
        professor = try values.decode(String.self, forKey: .professor)
        designScore = try values.decode(String.self, forKey: .designScore)
        classTime = try values.decode(Array<Int>.self, forKey: .classTime)
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        if (lhs.id != nil && rhs.id != nil) {
            return lhs.id == rhs.id
        } else if (lhs.code == rhs.code && lhs.lectureClass == rhs.lectureClass) {
            return true
        } else {
            return false
        }
    }
}
