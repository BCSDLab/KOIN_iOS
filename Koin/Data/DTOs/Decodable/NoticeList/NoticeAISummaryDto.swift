//
//  NoticeAISummaryDto.swift
//  koin
//
//  Created by 홍기정 on 8/13/26.
//

import Foundation

struct NoticeAISummaryDto: Decodable {
    let status: NoticeAISummaryStatusDto
    let items: [NoticeAISummaryItemDto]
}

struct NoticeAISummaryItemDto: Decodable {
    let icon: String
    let text: String
}

enum NoticeAISummaryStatusDto: String, Decodable {
    case success = "SUCCESS"
    case pending = "PENDING"
    case unavailable = "UNAVAILABLE"
}

extension NoticeAISummaryDto {
    func toDomain() -> NoticeAISummary {
        NoticeAISummary(
            status: status.toDomain(),
            items: items.map { $0.toDomain() }
        )
    }
}

extension NoticeAISummaryItemDto {
    func toDomain() -> NoticeAISummaryItem {
        NoticeAISummaryItem(
            icon: icon,
            text: text
        )
    }
}

extension NoticeAISummaryStatusDto {
    func toDomain() -> NoticeAISummaryStatus {
        switch self {
        case .success: .success
        case .pending: .pending
        case .unavailable: .unavailable
        }
    }
}
