//
//  EventParameter.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

/// 현행 명세 label: `service__page__feature[__detail]__category`.
/// event_name(team)·screen_view·event_category를 label 구간에서 계산한다.
protocol EventLabelType {
    var rawValue: String { get }
    /// 기본값은 page 구간. 명세의 screen_view가 page 구간과 다른 label만 재정의한다.
    var screenView: String? { get }
}

extension EventLabelType {
    var screenView: String? {
        let parts = segments
        guard (4...5).contains(parts.count), parts.allSatisfy({ !$0.isEmpty }) else {
            assertionFailure("Invalid logging label: \(rawValue)")
            return nil
        }
        return parts[1]
    }

    var team: String {
        let service = segments[0]
        switch service {
        case "shop", "cafeteria", "bus", "timetable", "real_estate", "owner", "ticket", "team_recruit":
            return "DA1"
        case "main", "banner", "board", "account", "callvan", "chat", "department", "facility", "course_practice":
            return "DA2"
        default:
            assertionFailure("Unassigned logging service: \(service)")
            return ""
        }
    }

    /// 마지막 구간. 명세의 category가 마지막 구간과 다르면 호출 시 category를 넘긴다.
    var lastSegment: String {
        segments.last ?? ""
    }

    private var segments: [String] {
        rawValue.components(separatedBy: "__")
    }
}

enum EventParameter {
    enum EventLabel {}
    
    enum EventCategory: String {
        case click
        case scroll
        case swipe
        case signup
        case entry
        case pageView = "page_view"
        case pageExit = "page_exit"
        case update = "update"
        case notification
        case result
        case exposure
        case select
        case toggle
        case submit
        case fail
    }
    
    enum EventLabelNeededDuration: String {
        case shopCategories
        case shopClick
        case shopCall
        case shopDetailViewBack
        case shopDetailViewReviewBackByTab = "shopDetailViewReviewBackByTab"
        case shopDetailViewReviewBackByCall = "shopDetailViewReviewBackByCall"
        case shopDetailViewReviewBackByCategory = "shopDetailViewReviewBackByCategory"
        case shopCategoriesBack
        case shopDetailViewReviewBack = "shop_detail_view_review_back"
    }
}
