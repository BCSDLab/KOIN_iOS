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
}
