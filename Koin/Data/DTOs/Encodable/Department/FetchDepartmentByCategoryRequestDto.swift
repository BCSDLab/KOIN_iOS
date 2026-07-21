//
//  FetchDepartmentByCategoryRequestDto.swift
//  koin
//
//  Created by 홍기정 on 7/21/26.
//

import Foundation

struct FetchDepartmentByCategoryRequestDto: Encodable {
    let category: DepartmentCategoryRequestDto
    let keyword: FetchDepartmentRequestDto?
}

extension FetchDepartmentByCategoryRequestDto {
    init(category: DepartmentCategory, keyword: String?) {
        self.category = DepartmentCategoryRequestDto(from: category)
        self.keyword = FetchDepartmentRequestDto(keyword: keyword)
    }
}

enum DepartmentCategoryRequestDto: String, Encodable {
    case academic = "ACADEMIC"
    case studentSupport = "STUDENT_SUPPORT"
    case employment = "EMPLOYMENT"
    case international = "INTERNATIONAL"
    case facility = "FACILITY"
    case other = "OTHER"
    
    init(from model: DepartmentCategory) {
        switch model {
        case .academic:
            self = .academic
        case .studentSupport:
            self = .studentSupport
        case .employment:
            self = .employment
        case .international:
            self = .international
        case .facility:
            self = .facility
        case .other:
            self = .other
        }
    }
}
