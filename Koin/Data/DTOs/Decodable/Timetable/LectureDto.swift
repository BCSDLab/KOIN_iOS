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
        timetable?.map { timetable in
            let times = timetable.classInfos?.flatMap { $0.classTime ?? [] } ?? []
            return LectureData(
                id: timetable.id,
                name: timetable.classTitle,
                professor: timetable.professor ?? "",
                classTime: Array(Set(times)).sorted(),
                grades: timetable.grades,
                lectureId: timetable.lectureID,
                code: timetable.code,
                lectureClass: timetable.lectureClass,
                classInfos: timetable.classInfos?.map {
                    LectureClassInfo(classTime: $0.classTime ?? [], classPlace: $0.classPlace ?? "")
                },
                memo: timetable.memo
            )
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
