//
//  CategorySection.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct CategorySection: View {
    let title: String
    let items: [NewHomeCategoryItem]
    let action: (NewHomeCategoryItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appFont(.pretendardSemiBold, size: 15))
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(height: 24, alignment: .center)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    CategoryRow(item: item) {
                        action(item)
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 20))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
