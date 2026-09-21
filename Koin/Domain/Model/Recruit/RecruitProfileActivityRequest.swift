//
//  RecruitProfileActivityRequest.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation

struct RecruitProfileActivityRequest {
    var title: String?
    var startedAt: Date?
    var endedAt: Date?
    var isOngoing: Bool
    var description: String?
}

extension RecruitProfileActivityRequest {
    var isValid: Bool {
        guard let title,
              !title.isEmpty,
              let startedAt,
              let description,
              !description.isEmpty else {
            return false
        }
        if isOngoing {
            return true
        } else {
            guard let endedAt,
                  startedAt < endedAt else {
                return false
            }
            return true
        }
    }
}
