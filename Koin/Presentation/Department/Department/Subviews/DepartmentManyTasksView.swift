//
//  DepartmentManyTasksView.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentManyTasksView: View {
    
    // MARK: - Layout
    enum Layout {
        static let headerTopPadding: CGFloat = 2
        static let headerHeight: CGFloat = 31
        static let rowHeight: CGFloat = 31
    }
    
    // MARK: - Properties
    let tasks: [DepartmentTask]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Group {
                    Text("업무")
                    Text("전화번호")
                }
                .frame(maxWidth: .infinity)
                .font(.appFont(.pretendardMedium, size: 14))
                .foregroundStyle(Color.appColor(.neutral600))
            }
            .frame(height: Layout.headerHeight)
            .padding(.top, Layout.headerTopPadding)
            
            
            ForEach(tasks) { task in
                HStack(alignment: .center) {
                    Group {
                        Text(task.name)
                        Text(task.phoneNumber)
                    }
                    .frame(maxWidth: .infinity)
                    .font(.appFont(.pretendardMedium, size: 12))
                    .foregroundStyle(Color.appColor(.neutral500))
                }
                .frame(height: Layout.rowHeight)
                .border(
                    Color.appColor(.neutral300),
                    width: 0.5,
                    edges: [.top]
                )
            }
        }
        .border(
            Color.appColor(.neutral300),
            width: 0.5,
            radius: 20
        )
    }
}
