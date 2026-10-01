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
                if data.state == .closed {
                    Text("모집완료")
                        .font(.appFont(.pretendardMedium, size: 10))
                        .foregroundStyle(Color.appColor(.new600))
                } else if let dDay = data.dDay {
                    Text(dDay)
                        .font(.appFont(.pretendardMedium, size: 10))
                        .foregroundStyle(Color.appColor(.danger700))
                }
            }
            .frame(minHeight: 18)
            
            Text(data.title)
                .font(.appFont(.pretendardSemiBold, size: 18))
                .foregroundStyle(Color.appColor(.neutral700))
                .frame(height: 29)
        }
    }
}
