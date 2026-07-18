//
//  DepartmentSingleTaskView.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentSingleTaskView: View {
    
    // MARK: - Layout
    enum Layout {
        static let rowHeight: CGFloat = 22
    }
    
    // MARK: - Properties
    let copyButtonTapped: ()->Void
    let task: DepartmentTask
    
    // MARK: - Body
    var body: some View {
        HStack(alignment: .center) {
            Text("전화번호 : \(task.phoneNumber)")
                .font(.appFont(.pretendardMedium, size: 14))
                .foregroundStyle(Color.appColor(.neutral500))
            
            Spacer()
            
            Button(action: copyButtonTapped) {
                HStack(
                    alignment: .center,
                    spacing: 4
                ) {
                    Text("전화번호 복사")
                        .foregroundStyle(Color.appColor(.neutral400))
                        .font(.appFont(.pretendardRegular, size: 12))
                    Image.appImage(asset: .departmentCopy)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(height: Layout.rowHeight)
        .frame(maxWidth: .infinity)
    }
}
