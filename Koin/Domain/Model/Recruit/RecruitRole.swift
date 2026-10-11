//
//  RecruitRole.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitRole: Identifiable, Hashable {
    let id: Int
    let name: String
    let currentParticipants: Int
    let maximumParticipants: Int
    let isClosed: Bool
}
