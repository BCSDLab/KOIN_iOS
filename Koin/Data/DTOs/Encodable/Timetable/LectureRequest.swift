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
    let lectureID: Int?
    let classTitle: String
    let classInfos: [ClassInfo]
    let professor: String?
    let grades: String
    let memo: String

    enum CodingKeys: String, CodingKey {
        case lectureID = "lecture_id"
        case classTitle = "class_title"
        case classInfos = "class_infos"
        case professor, grades, memo
    }
}

// MARK: - ClassInfo
struct ClassInfo: Codable {
    let classTime: [Int]?
    let classPlace: String?

    enum CodingKeys: String, CodingKey {
        case classTime = "class_time"
        case classPlace = "class_place"
    }
}
