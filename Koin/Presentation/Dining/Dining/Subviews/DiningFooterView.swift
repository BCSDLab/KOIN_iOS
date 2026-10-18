//
//  DiningFooterView.swift
//  koin
//
//  Created by 홍기정 on 10/8/26.
//

import SwiftUI

struct DiningFooterView: View {
    var body: some View {
        Text("식단 정보는 운영 상황 따라 변동될 수 있습니다.")
            .font(.appFont(.pretendardMedium, size: 13))
            .foregroundStyle(Color.appColor(.neutral400))
            .padding(.leading, 4)
    }
}
