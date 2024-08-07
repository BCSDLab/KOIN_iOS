//
//  SemesterDTO.swift
//  koin
//
//  Created by 김나훈 on 3/31/24.
//

import Foundation

struct SemesterDTO: Decodable {
    let id: Int
    let semester: String
}

extension SemesterDTO {
    var formattedSemester: String {

        let yearIndex = semester.index(semester.startIndex, offsetBy: 4)
        let yearPart = semester[..<yearIndex]
        let semesterPart = semester[yearIndex...]
        
        let semesterNumber = semesterPart == "1" ? "1학기" : "2학기"
        
        return "\(yearPart)년 \(semesterNumber)" 
    }
}
