//
//  ForceUpdateResponse.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Foundation

struct ForceUpdateResponse: Decodable {
    let id: Int
    let type: String
    let version: String
    let title: String?
    let content: String?
    let createdAt: String?
    let updatedAt: String?
}
