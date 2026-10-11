//
//  StudentAcademicInfoRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct StudentAcademicInfoRequestDto: Encodable {
    let studentNumber: String
    let department: String
    let major: String?

    enum CodingKeys: String, CodingKey {
        case studentNumber = "student_number"
        case department, major
    }
}

extension StudentAcademicInfoRequestDto {
    init?(from basicInfo: BasicInfo) {
        guard let studentNumber = basicInfo.studentNumber,
              let department = basicInfo.department else {
            return nil
        }
        self.studentNumber = studentNumber
        self.department = department
        self.major = nil
    }
}
