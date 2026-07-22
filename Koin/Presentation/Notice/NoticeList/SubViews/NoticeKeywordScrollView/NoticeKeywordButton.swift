//
//  NoticeKeywordButton.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

struct NoticeKeywordButton: View {
    
    let keywordButtonTapped: ()->Void
    let isSelected: Bool
    let keyword: String
    
    init(action keywordButtonTapped: @escaping () -> Void, isSelected: Bool, keyword: String) {
        self.keywordButtonTapped = keywordButtonTapped
        self.isSelected = isSelected
        self.keyword = keyword
    }
    
    var font: Font {
        isSelected ? Font.appFont(.pretendardBold, size: 14) : Font.appFont(.pretendardMedium, size: 14)
    }
    var foregroundStyle: Color {
        isSelected ? Color.appColor(.neutral0) : Color.appColor(.neutral500)
    }
    var backgroundStyle: Color {
        isSelected ? Color.appColor(.new600) : Color.appColor(.neutral100)
    }

    var body: some View {
        Button(action: keywordButtonTapped) {
            Text("#\(keyword)")
                .font(font)
                .foregroundStyle(foregroundStyle)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .frame(height: 34, alignment: .center)
                .background(backgroundStyle)
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}
