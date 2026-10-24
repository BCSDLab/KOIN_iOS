//
//  NoticeKeywordManageButton.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

struct NoticeKeywordManageButton: View {
    
    let onManageButtonTapped: ()->Void
    
    init(action onManageButtonTapped: @escaping () -> Void) {
        self.onManageButtonTapped = onManageButtonTapped
    }
    
    var body: some View {
        Button(action: onManageButtonTapped) {
            Image.appImage(asset: .noticeManageKeyword)
        }
        .buttonStyle(.plain)
    }
}
