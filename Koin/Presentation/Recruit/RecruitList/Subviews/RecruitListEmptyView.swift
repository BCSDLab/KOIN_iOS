//
//  RecruitListEmptyView.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import SwiftUI

struct RecruitListEmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Spacer()
            
            Image.appImage(asset: .sleepBcsdSymbol)
                .frame(height: 75)
            
            Text("조건에 맞는 모집글이 없어요.")
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.neutral500))
            
            Spacer()
        }
    }
}
