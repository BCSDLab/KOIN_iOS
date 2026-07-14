//
//  CategoryRow.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct CategoryRow: View {
    let item: HomeCategoryItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image.appImage(asset: item.imageAsset)
                    .frame(width: 40, height: 40)
                    .background(Color.ColorSystem.Neutral.gray100)
                    .clipShape(.rect(cornerRadius: 10))

                Text(item.title)
                    .font(.appFont(.pretendardSemiBold, size: 15))
                    .foregroundStyle(Color.appColor(.neutral800))
                    .lineLimit(1)

                Spacer()

                Image.appImage(asset: .chevronRightRounded)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.appColor(.neutral0))
        }
        .buttonStyle(.plain)
    }
}
