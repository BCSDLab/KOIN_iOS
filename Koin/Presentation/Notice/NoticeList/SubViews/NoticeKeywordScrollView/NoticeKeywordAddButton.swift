//
//  NoticeKeywordAddButton.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

struct NoticeKeywordAddButton: View {
    
    let addButtonTapped: ()->Void
    
    init(action addButtonTapped: @escaping () -> Void) {
        self.addButtonTapped = addButtonTapped
    }
    
    var body: some View {
        Button(action: addButtonTapped) {
            Text("새 키워드 추가")
                .font(.appFont(.pretendardMedium, size: 14))
                .foregroundStyle(Color.appColor(.neutral500))
                .frame(width: 112, height: 34, alignment: .center)
                .background(Color.appColor(.neutral100))
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}
