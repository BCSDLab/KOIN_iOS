//
//  NoticeKeywordSearchButton.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

struct NoticeKeywordSearchButton: View {
    
    let onSearchButtonTapped: ()->Void
    
    init(action onSearchButtonTapped: @escaping () -> Void) {
        self.onSearchButtonTapped = onSearchButtonTapped
    }
    
    var body: some View {
        Button(action: onSearchButtonTapped) {
            Image.appImage(asset: .noticeSearch)
                .renderingMode(.template)
                .foregroundStyle(Color.appColor(.neutral500))
                .frame(alignment: .center)
                .frame(width: 32, height: 32)
                .background(Color.appColor(.neutral100))
                .clipShape(.circle)
        }
        .buttonStyle(.plain)
    }
}
