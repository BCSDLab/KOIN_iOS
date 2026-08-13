//
//  NoticeAISummary.swift
//  koin
//
//  Created by 홍기정 on 8/11/26.
//

import Foundation

struct NoticeAISummary {
    let status: NoticeAISummaryStatus
    let items: [NoticeAISummaryItem]
}

struct NoticeAISummaryItem: Identifiable {
    var id: String {
        icon + text
    }
    
    let icon: String
    let text: String
}

enum NoticeAISummaryStatus {
    case loading
    case success
    case pending
    case unavailable
}

extension NoticeAISummaryItem {
    var attributedString: AttributedString {
        var attributedString = AttributedString("\(icon) \(text)")
        
        if let iconRange = attributedString.range(of: icon) {
            attributedString[iconRange].font = .system(size: 14)
        }
        if let textRange = attributedString.range(of: text) {
            attributedString[textRange].font = .appFont(.pretendardRegular, size: 14)
        }
        
        return attributedString
    }
}
