//
//  DepartmentRow.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentRow: View {
    
    // MARK: - Layout
    enum Layout {
        static let allPadding: CGFloat = 20
        static let titleHeight: CGFloat = 26
        enum titleBottomPadding {
            static let singleTask: CGFloat = 12
            static let manyTasks: CGFloat = 8
        }
    }
    
    // MARK: - Properties
    let department: Department
    let copyButtonTapped: ()->Void
    
    // MARK: - Initializer
    init(
        department: Department,
        copyButtonTapped: @escaping () -> Void
    ) {
        self.department = department
        self.copyButtonTapped = copyButtonTapped
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Text(department.name)
                .font(.appFont(.pretendardSemiBold, size: 16))
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(height: Layout.titleHeight, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if department.tasks.count == 1,
               let task = department.tasks.first {
                DepartmentSingleTaskView(
                    copyButtonTapped: copyButtonTapped,
                    task: task
                )
                .padding(.top, Layout.titleBottomPadding.singleTask)
            } else {
                DepartmentManyTasksView(tasks: department.tasks)
                    .padding(.top, Layout.titleBottomPadding.manyTasks)
            }
        }
        .padding(.all, Layout.allPadding)
        .background(Color.appColor(.neutral0))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
