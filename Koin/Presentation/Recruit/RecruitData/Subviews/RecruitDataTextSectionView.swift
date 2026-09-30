//
//  RecruitDataTextSectionView.swift
//  koin
//

import SwiftUI

struct RecruitDataTextSectionView: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appFont(.pretendardSemiBold, size: 14))
                .foregroundStyle(Color.appColor(.neutral700))
                .frame(minHeight: 22)
            
            Text(text)
                .font(.appFont(.pretendardMedium, size: 12))
                .foregroundStyle(Color.appColor(.neutral800))
                .linespacing(fontSize: 12, percent: 160)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
