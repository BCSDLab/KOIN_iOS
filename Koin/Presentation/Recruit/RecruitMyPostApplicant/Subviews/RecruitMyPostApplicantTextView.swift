//
//  RecruitMyPostApplicantTextView.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import SwiftUI

struct RecruitMyPostApplicantTextView: View {

    let text: String

    var body: some View {
        Text(text)
            .linespacing(fontSize: 14, percent: 160)
            .font(.appFont(.pretendardRegular, size: 14))
            .foregroundStyle(Color.appColor(.neutral500))
            .frame(maxWidth: .infinity, minHeight: 22, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appColor(.neutral0))
            .clipShape(.rect(cornerRadius: 16))
    }
}
