//
//  EmptyDiningCard.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI

struct EmptyDiningCard: View {
    var body: some View {
        Text("오늘은 식단이 없어요")
            .font(.appFont(.pretendardMedium, size: 13))
            .foregroundStyle(Color.ColorSystem.Neutral.gray500)
            .frame(width: 312, height: 171)
            .background(Color.ColorSystem.Neutral.gray0)
            .clipShape(.rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.ColorSystem.Neutral.gray300, lineWidth: 0.5)
            }
    }
}
