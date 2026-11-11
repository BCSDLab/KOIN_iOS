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
              let description,
              !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return RecruitActivityPeriod(start: startedAt, end: endedAt, isOngoing: isOngoing).isValid(today: Date())
    }
}
