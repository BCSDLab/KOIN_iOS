//
//  NoticeKeywordAllButton.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

struct NoticeKeywordAllButton: View {
    
    // MARK: - Properties
    let onAllButtonTapped: ()->Void
    let isSelected: Bool
    
    var font: Font {
        isSelected ? Font.appFont(.pretendardBold, size: 14) : Font.appFont(.pretendardMedium, size: 14)
    }
    var foregroundStyle: Color {
        isSelected ? Color.appColor(.neutral0) : Color.appColor(.neutral500)
    }
    var backgroundStyle: Color {
        isSelected ? Color.appColor(.new600) : Color.appColor(.neutral100)
    }
    
    // MARK: - Initializer
    init(isSelected: Bool, action onAllButtonTapped: @escaping () -> Void) {
        self.isSelected = isSelected
        self.onAllButtonTapped = onAllButtonTapped
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: onAllButtonTapped) {
            Text("모두보기")
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
