//
//  DepartmentEmptyView.swift
//  koin
//
//  Created by 홍기정 on 7/19/26.
//

import SwiftUI

struct DepartmentEmptyView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image.appImage(asset: .sleepBcsdSymbol)
                .padding(.bottom, 12)
            
            Text("검색결과가 없습니다.\n다른 검색어로 다시 검색해주세요.")
                .linespacing(fontSize: 14, percent: 160)
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.neutral500))
                .multilineTextAlignment(.center)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
        .background(Color.appColor(.newBackground))
        .hideKeyboardWhenTapAround()
    }
}
