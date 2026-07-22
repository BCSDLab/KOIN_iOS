//
//  NoticeKeywordManageButton.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

struct NoticeKeywordManageButton: View {
    
    let manageButtonTapped: ()->Void
    
    init(action manageButtonTapped: @escaping () -> Void) {
        self.manageButtonTapped = manageButtonTapped
    }
    
    var body: some View {
        Button(action: manageButtonTapped) {
            Image.appImage(asset: .noticeManageKeyword)
        }
        .buttonStyle(.plain)
    }
}
