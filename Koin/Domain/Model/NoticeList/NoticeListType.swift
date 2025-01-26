//
//  NoticeListType.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

enum NoticeListType: Int, Decodable, CaseIterable {
    case all = 4
    case lostItem = 14
    case general = 5
    case scholarship = 6
    case university = 7
    case job = 8
    case ipp = 12
    case student = 13
    case koin = 9
    
    
    var displayName: String {
        switch self {
        case .all:
            return "전체공지"
        case .lostItem:
            return "분실물"
        case .general:
            return "일반"
        case .scholarship:
            return "장학"
        case .university:
            return "학사"
        case .job:
            return "취업"
        case .ipp:
            return "현장실습"
        case .student:
            return "학생생활"
        case .koin:
            return "코인"
        }
    }
    
    var index: Int {
        switch self {
        case .all: return 0
        case .lostItem: return 1
        case .general: return 2
        case .scholarship: return 3
        case .university: return 4
        case .job: return 5
        case .ipp: return 6
        case .student: return 7
        case .koin: return 8
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(Int.self)
        self = NoticeListType(rawValue: rawValue ?? 1) ?? .all
    }
}
