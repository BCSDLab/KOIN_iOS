//
//  RecruitProfileActionButton.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import SwiftUI

struct RecruitProfileActionButton: View {
    
    let title: String
    let action: ()->Void
    
    init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.new500))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .border(.appColor(.new500), width: 1, radius: 16)
                .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
