//
//  LectureDto.swift
//  koin
//
//  Created by 김나훈 on 3/31/24.
//

import Foundation

struct LectureDto: Codable {
    let timetableFrameID: Int?
    let timetable: [Timetable]?
    let grades: Int?
    let totalGrades: Int?

    enum CodingKeys: String, CodingKey {
        case timetableFrameID = "timetable_frame_id"
        case timetable, grades
        case totalGrades = "total_grades"
    }
}

extension LectureDto {
    func toDomain() -> [LectureData] {
           return timetable?.map { timetable in
               LectureData(id: timetable.id, name: timetable.classTitle, professor: timetable.professor ?? "", classTime: timetable.classInfos?.first?.classTime ?? [], grades: timetable.grades)
           } ?? []
       }
}

struct Timetable: Codable {
    let id: Int
    let lectureID: Int?
    let regularNumber: String?
    let code: String?
    let designScore: String?
    let classInfos: [ClassInfo]?
    let memo: String?
    let grades: String
    let classTitle: String
    let lectureClass: String?
    let target: String?
    let professor: String?
    let department: String?

    enum CodingKeys: String, CodingKey {
        case id
        case lectureID = "lecture_id"
        case regularNumber = "regular_number"
        case code
        case classInfos = "class_infos"
        case designScore = "design_score"
        case memo, grades
        case classTitle = "class_title"
        case lectureClass = "lecture_class"
        case target, professor, department
    }
}
