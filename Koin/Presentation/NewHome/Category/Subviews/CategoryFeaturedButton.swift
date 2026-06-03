//
//  CategoryFeaturedButton.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct CategoryFeaturedButton: View {
    let item: NewHomeCategoryItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Image.appImage(asset: item.imageAsset)
                    .frame(width: 40, height: 40)
                    .background(Color.ColorSystem.Neutral.gray100)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(.bottom, 8)
                
                Text(item.title)
                    .font(.appFont(.pretendardSemiBold, size: 14))
                    .foregroundStyle(Color.appColor(.neutral800))
                    .lineLimit(1)
                    .frame(height: 22)
                
                Text(item.subtitle ?? "")
                    .font(.appFont(.pretendardRegular, size: 12))
                    .foregroundStyle(Color.appColor(.neutral500))
                    .lineLimit(1)
                    .frame(height: 19)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appColor(.neutral0))
            .clipShape(.rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}
