//
//  RecruitMyPostEmptyView.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import SwiftUI

struct RecruitMyPostEmptyView: View {

    var body: some View {
        VStack(spacing: 0) {
            Image.appImage(asset: .sleepBcsdSymbol)
                .frame(width: 98, height: 75)

            Text("아직 지원자가 없어요.")
                .font(.appFont(.pretendardMedium, size: 16))
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(height: 26)

            Text("새로운 지원자가 등록되면 이곳에서 확인할 수 있어요.")
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.neutral600))
                .frame(height: 22)
                .padding(.top, 4)
        }
    }
}
