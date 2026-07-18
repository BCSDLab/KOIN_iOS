//
//  DepartmentFooterView.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentFooterView: View {
    
    // MARK: - Layout
    enum Layout {
        static let height: CGFloat = 70
        static let heightUpdatedAt: CGFloat = 19
        static let heightReport: CGFloat = 16
    }
    
    // MARK: - Properties
    private let updatedAt: String
    private let reportButtonTapped: ()->Void = {
        if let url = URL(string: "https://docs.google.com/forms/d/1GR4t8IfTOrYY4jxq5YAS7YiCS8QIFtHaWu_kE-SdDKY"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Initializer
    init(updatedAt: String) {
        self.updatedAt = updatedAt
    }
    
    // MARK: - Body
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {
            Text("업데이트일: \(updatedAt)")
                .font(.appFont(.pretendardRegular, size: 12))
                .foregroundStyle(Color.appColor(.neutral400))
                .frame(height: Layout.heightUpdatedAt)
            
            Button(action: reportButtonTapped) {
                HStack(alignment: .center, spacing: 4) {
                    Image.appImage(asset: .departmentAlert)
                    
                    Text("정보가 정확하지 않나요?")
                        .font(.appFont(.pretendardRegular, size: 10))
                        .foregroundStyle(Color.appColor(.neutral400))
                }
                .frame(height: Layout.heightReport)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Layout.height)
    }
}
