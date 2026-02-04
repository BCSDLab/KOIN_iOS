//
//  ReportLostItemRequest.swift
//  koin
//
//  Created by 김나훈 on 2/17/25.
//

import Foundation

struct ReportLostItemRequest: Encodable {
    let reports: [ReportLostItem]
}

struct ReportLostItem: Encodable {
    let title: String
    let content: String
}
