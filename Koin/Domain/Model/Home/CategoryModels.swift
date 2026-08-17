//
//  CategoryModels.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import Foundation

enum HomeCategoryItem: Identifiable {
    case timetable
    case lostItem
    case facility
    case dining
    case shop
    case busTimetable
    case busRoute
    case callVan
    case chat
    case land
    case business
    case department

    var id: String { title }

    var title: String {
        switch self {
        case .timetable:
            return "시간표"
        case .lostItem:
            return "분실물"
        case .facility:
            return "교내 시설물 정보"
        case .department:
            return "학교 부서정보"
        case .dining:
            return "식단"
        case .shop:
            return "주변상점"
        case .busTimetable:
            return "버스 시간표"
        case .busRoute:
            return "교통편 조회하기"
        case .callVan:
            return "콜밴팟 모집"
        case .chat:
            return "채팅"
        case .land:
            return "복덕방"
        case .business:
            return "코인 for Business"
        }
    }

    var subtitle: String? {
        switch self {
        case .timetable:
            return "내 강의 정보 확인하기"
        case .lostItem:
            return "분실물 신고 / 조회하기"
        default:
            return nil
        }
    }

    var imageAsset: ImageAsset {
        switch self {
        case .timetable:
            return .categoryTimetable
        case .lostItem:
            return .categoryLostitem
        case .facility:
            return .categoryFacility
        case .department:
            return .categoryDepartment
        case .dining:
            return .categoryDining
        case .shop:
            return .categoryShop
        case .busTimetable:
            return .categoryBusTimetable
        case .busRoute:
            return .categoryBusSearch
        case .callVan:
            return .categoryCallVan
        case .chat:
            return .categoryChat
        case .land:
            return .categoryLand
        case .business:
            return .categoryBusiness
        }
    }
}
