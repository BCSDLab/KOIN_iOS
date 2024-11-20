//
//  LectureRequest.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

struct LectureRequest: Codable {
    let timetableFrameID: Int
    let timetableLecture: [TimetableLecture]

    enum CodingKeys: String, CodingKey {
        case timetableFrameID = "timetable_frame_id"
        case timetableLecture = "timetable_lecture"
    }
}

// MARK: - TimetableLecture
struct TimetableLecture: Codable {
    let id: Int?
    let lectureID: Int
    let classTitle: String
    let classTime: [Int]
    let classPlace, professor, grades, memo: String

    enum CodingKeys: String, CodingKey {
        case id
        case lectureID = "lecture_id"
        case classTitle = "class_title"
        case classTime = "class_time"
        case classPlace = "class_place"
        case professor, grades, memo
    }
}
