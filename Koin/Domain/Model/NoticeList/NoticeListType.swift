//
//  NoticeListTab.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

enum NoticeListType: Int, Decodable, CaseIterable {
    case 자유게시판 = 1
    case 취업게시판 = 2
    case 익명게시판 = 3
    case 전체공지 = 4
    case 일반 = 5
    case 장학 = 6
    case 학사 = 7
    case 취업 = 8
    case 코인 = 9
    case 질문게시판 = 10
    case 홍보게시판 = 11
    
    var displayName: String {
        switch self {
        case .자유게시판:
            return "자유게시판"
        case .취업게시판:
            return "취업게시판"
        case .익명게시판:
            return "익명게시판"
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
        case .코인:
            return "코인"
        case .질문게시판:
            return "질문 게시판"
        case .홍보게시판:
            return "홍보 게시판"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(Int.self)
        self = NoticeListType(rawValue: rawValue ?? 1) ?? .익명게시판
    }
}
