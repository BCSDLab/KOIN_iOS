//
//  DepartmentCategoryRow.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentCategoryRow: View {
    
    // MARK: - Layout
    enum Layout {
        static let height: CGFloat = 64
    }
    
    // MARK: - Properties
    let category: DepartmentCategory
    let categoryTapped: (DepartmentCategory)->Void
    
    // MARK: - Body
    var body: some View {
        Button(action: { categoryTapped(category) }) {
            HStack(alignment: .center) {
                Image.appImage(asset: category.icon)
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(Color.ColorSystem.Neutral.gray100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 14)
                
                Text(category.name)
                    .font(.appFont(.pretendardSemiBold, size: 15))
                    .foregroundStyle(Color.appColor(.neutral800))
                
                Spacer()
                
                Image.appImage(asset: .chevronRightRounded)
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: Layout.height)
        }
        .buttonStyle(.plain)
    }
}
