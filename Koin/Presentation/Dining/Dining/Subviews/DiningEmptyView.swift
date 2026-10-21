//
//  DiningEmptyView.swift
//  koin
//
//  Created by 홍기정 on 10/21/26.
//

import SwiftUI

struct DiningEmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image.appImage(asset: .sleepBcsdSymbol)
            
            Text("오늘은 식단이 없어요.")
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.neutral500))
                .frame(minHeight: 22)
            
            Text("식단 정보는 운영 상황에 따라 변동될 수 있습니다.")
                .font(.appFont(.pretendardMedium, size: 13))
                .foregroundStyle(Color.appColor(.neutral400))
                .frame(minHeight: 21)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
