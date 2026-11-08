//
//  LectureData.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Foundation

struct LectureData: Hashable {
    let id: Int
    let name: String
    let professor: String
    var classTime: [Int]
    let grades: String
    let lectureId: Int?
    let code: String?
    let lectureClass: String?
    let classInfos: [LectureClassInfo]?
    let memo: String?

    init(
        id: Int,
        name: String,
        professor: String,
        classTime: [Int],
        grades: String,
        lectureId: Int? = nil,
        code: String? = nil,
        lectureClass: String? = nil,
        classInfos: [LectureClassInfo]? = nil,
        memo: String? = nil
    ) {
        self.id = id
        self.name = name
        self.professor = professor
        self.classTime = classTime
        self.grades = grades
        self.lectureId = lectureId
        self.code = code
        self.lectureClass = lectureClass
        self.classInfos = classInfos
        self.memo = memo
    }
}


struct LectureClassInfo: Hashable {
    let classTime: [Int]
    let classPlace: String
}
