//
//  NoticeListType.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

enum NoticeListType: Int, Decodable, CaseIterable {
    case 전체공지 = 4
    case 일반 = 5
    case 장학 = 6
    case 학사 = 7
    case 취업 = 8
    
    var displayName: String {
        switch self {
        case .전체공지:
            return "전체공지"
        case .일반:
            return "일반"
        case .장학:
            return "장학"
        case .학사:
            return "학사"
        case .취업:
            return "취업"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(Int.self)
        self = NoticeListType(rawValue: rawValue ?? 1) ?? .전체공지
    }
}
