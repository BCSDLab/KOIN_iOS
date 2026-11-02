//
//  RecruitProfileActivity.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation

struct RecruitProfileActivity: Identifiable, Equatable {
    let id: Int
    let title: String
    let startedAt: Date
    let endedAt: Date?
    let isOngoing: Bool
    let description: String

    var periodText: String {
        let start = startedAt.string(with: .yearMonthDayDot)
        if isOngoing {
            return "\(start) - 진행 중"
        }
        guard let endedAt else {
            return start
        }

        return "\(start) - \(endedAt.string(with: .yearMonthDayDot))"
    }
}

extension RecruitProfileActivity {
    func toRequest() -> RecruitProfileActivityRequest {
        RecruitProfileActivityRequest(
            title: title,
            startedAt: startedAt,
            endedAt: endedAt,
            isOngoing: isOngoing,
            description: description
        )
    }
}
