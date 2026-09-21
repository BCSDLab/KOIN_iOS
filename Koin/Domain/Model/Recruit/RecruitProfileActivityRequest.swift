//
//  RecruitProfileActivityRequest.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation

struct RecruitProfileActivityRequest {
    var title: String? = nil
    var startedAt: Date? = nil
    var endedAt: Date? = nil
    var isOngoing: Bool = false
    var description: String? = nil
}

extension RecruitProfileActivityRequest {
    var isValid: Bool {
        guard let title,
              !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let startedAt,
              let description,
              !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: startedAt)
        let today = calendar.startOfDay(for: Date())
        guard startDay <= today else { return false }

        if isOngoing {
            return true
        }

        guard let endedAt else { return false }
        let endDay = calendar.startOfDay(for: endedAt)
        return startDay <= endDay
    }
}
