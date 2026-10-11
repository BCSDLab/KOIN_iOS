//
//  RecruitDataRelatedUrlView.swift
//  koin
//
//  Created by 홍기정 on 9/12/26.
//

import SwiftUI

struct RecruitDataRelatedUrlView: View {
    let url: URL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("관련 링크")
                .font(.appFont(.pretendardSemiBold, size: 14))
                .foregroundStyle(Color.appColor(.neutral700))
                .frame(minHeight: 22)
            
            Link(
                url.absoluteString,
                destination: url
            )
            .font(.appFont(.pretendardMedium, size: 12))
            .foregroundStyle(Color.appColor(.neutral800))
            .multilineTextAlignment(.leading)
        }
    }
}
