//
//  RecruitProfileActionCardView.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import SwiftUI

struct RecruitProfileActionCardView: View {
    
    let icon: ImageAsset
    let title: String
    let description: String
    let action: ()->Void
    
    init(
        icon: ImageAsset,
        title: String,
        description: String,
        action: @escaping ()->Void
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image.appImage(asset: icon)
                    .frame(width: 40, height: 40, alignment: .center)
                    .border(.appColor(.neutral400), width: 1, radius: 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.appFont(.pretendardSemiBold, size: 14))
                        .foregroundStyle(Color.appColor(.neutral800))
                        .frame(minHeight: 22)
                    
                    Text(description)
                        .font(.appFont(.pretendardRegular, size: 12))
                        .foregroundStyle(Color.appColor(.neutral500))
                        .multilineTextAlignment(.leading)
                        .linespacing(fontSize: 12, percent: 160)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image.appImage(asset: .newChevronRight)
                    .frame(width: 24, height: 24)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 108)
            .background(Color.appColor(.neutral0))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
