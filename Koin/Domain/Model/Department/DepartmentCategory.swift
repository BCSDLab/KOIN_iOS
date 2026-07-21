//
//  DepartmentCategory.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import Foundation

enum DepartmentCategory: String, CaseIterable, Identifiable {
    case academic = "학사 / 수업"
    case studentSupport = "학생지원 / 행정"
    case employment = "취업 / 현장실습"
    case international = "국제 / 교환학생"
    case facility = "시설 / 생활"
    case other = "기타 기관"
    
    var id: String {
        rawValue
    }
    
    var icon: ImageAsset {
        switch self {
        case .academic:
            return .departmentAcademic
        case .studentSupport:
            return .departmentStudentSupport
        case .employment:
            return .departmentEmployment
        case .international:
            return .departmentInternational
        case .facility:
            return .departmentFacility
        case .other:
            return .departmentOther
        }
    }
}
