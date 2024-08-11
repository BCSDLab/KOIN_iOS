//
//  ReportReviewRequest.swift
//  koin
//
//  Created by 김나훈 on 8/11/24.
//

import Foundation

struct ReportReviewRequest: Encodable {
    let reports: Reports
}

struct Reports: Encodable {
    let title: String
    let content: String
}
