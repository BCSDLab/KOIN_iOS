//
//  StudentAcademicInfoDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct StudentAcademicInfoDto: Decodable {
    let nickname: String?
    let department: String?
    let studentNumber: String?

    enum CodingKeys: String, CodingKey {
        case nickname, department
        case studentNumber = "student_number"
    }
}

extension StudentAcademicInfoDto {
    func toDomain() -> BasicInfo {
        return BasicInfo(
            nickname: nickname,
            department: department,
            studentNumber: studentNumber
        )
    }
}
