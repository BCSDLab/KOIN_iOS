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
    let copyButtonTapped: (String)->Void
    let tasks: [DepartmentTask]
    
    // MARK: - Initializer
    init(
        copyButtonTapped: @escaping (String) -> Void,
        tasks: [DepartmentTask]
    ) {
        self.copyButtonTapped = copyButtonTapped
        self.tasks = tasks
    }
    
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
                    Text(task.name)
                        .font(.appFont(.pretendardMedium, size: 12))
                        .foregroundStyle(Color.appColor(.neutral500))
                        .frame(maxWidth: .infinity)
                    
                    Button {
                        copyButtonTapped(task.phoneNumber)
                    } label: {
                        Text(task.phoneNumber)
                            .font(.appFont(.pretendardMedium, size: 12))
                            .foregroundStyle(Color.appColor(.neutral500))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
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
