//
//  RecruitMyPostListEmptyView.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import SwiftUI

struct RecruitMyPostListEmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Spacer()

            Image.appImage(asset: .sleepBcsdSymbol)
                .frame(height: 75)

            Text("작성한 모집글이 없어요.")
                .font(.appFont(.pretendardMedium, size: 16))
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(height: 26)
                .padding(.bottom, 2)

            Text("직접 모집글을 작성하여 팀원을 모집해보세요.")
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.neutral600))
                .frame(height: 22)

            Spacer()
        }
    }
}
