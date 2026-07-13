//
//  NoticeKeywordSearchButton.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

struct NoticeKeywordSearchButton: View {
    
    let searchButtonTapped: ()->Void
    
    init(action searchButtonTapped: @escaping () -> Void) {
        self.searchButtonTapped = searchButtonTapped
    }
    
    var body: some View {
        Button(action: searchButtonTapped) {
            Image.appImage(asset: .noticeSearch)
        }
        .buttonStyle(.plain)
    }
}
