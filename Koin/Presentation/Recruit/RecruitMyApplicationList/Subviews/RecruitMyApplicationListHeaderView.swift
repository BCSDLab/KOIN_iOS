//
//  RecruitMyApplicationListHeaderView.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import SwiftUI

struct RecruitMyApplicationListHeaderView: View {

    let totalCount: Int
    let onFilterButtonTapped: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("전체(\(totalCount))")
                .font(.appFont(.pretendardRegular, size: 12))
                .foregroundStyle(Color.appColor(.neutral500))

            Spacer()

            Button(action: onFilterButtonTapped) {
                HStack(alignment: .center, spacing: 4) {
                    Text("필터")
                        .font(.appFont(.pretendardRegular, size: 12))
                        .foregroundStyle(Color.appColor(.neutral600))

                    Image.appImage(asset: .recruitFilter)
                }
                .padding(.horizontal, 15)
                .frame(height: 36)
                .background(Color.appColor(.neutral0))
                .clipShape(.capsule)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
    }
}
