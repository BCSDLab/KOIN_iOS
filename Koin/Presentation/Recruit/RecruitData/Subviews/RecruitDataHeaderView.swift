//
//  RecruitDataHeaderView.swift
//  koin
//

import SwiftUI

struct RecruitDataHeaderView: View {
    let data: RecruitData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(data.category.rawValue)
                    .font(.appFont(.pretendardMedium, size: 10))
                    .foregroundStyle(Color.appColor(data.category.foregroundColor))
                    .padding(.horizontal, 8)
                    .frame(height: 18)
                    .background(Color.appColor(data.category.backgroundColor), in: Capsule())
                Text(data.dDay)
                    .font(.appFont(.pretendardMedium, size: 10))
                    .foregroundStyle(Color.appColor(.danger700))
            }
            .frame(minHeight: 18)
            
            Text(data.title)
                .font(.appFont(.pretendardSemiBold, size: 18))
                .foregroundStyle(Color.appColor(.neutral700))
                .frame(height: 29)
        }
    }
}
