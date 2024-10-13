//
//  NoticeListType.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

enum NoticeListType: Int, Decodable, CaseIterable {
    case all = 4
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(Int.self)
        self = NoticeListType(rawValue: rawValue ?? 1) ?? .all
    }
}
