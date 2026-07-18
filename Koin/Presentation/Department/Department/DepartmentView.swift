//
//  DepartmentView.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentView: ActionBindableView {

    // MARK: - Action
    enum Action {}
    var sendAction: ((Action) -> Void) = { _ in }
    
    // MARK: - Layout
    enum Layout {
        static let horizontalPadding: CGFloat = 22
        static let rowSpacing: CGFloat = 12
    }
    
    // MARK: - Properties
    @State var viewModel: DepartmentViewModel
    
    // MARK: - Initializer
    init(viewModel: DepartmentViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - SpacerHeight
    private func spacerHeight(totalHeight: CGFloat) -> CGFloat {
        let searchViewHeight = DepartmentSearchView.Layout.topPadding
            + DepartmentSearchView.Layout.height
            + DepartmentSearchView.Layout.bottomPadding
        let rowsHeight: CGFloat = viewModel.departments.reduce(0) { result, department in
            return result
            + DepartmentRow.Layout.allPadding * 2
            + DepartmentRow.Layout.titleHeight
            + (department.tasks.count == 1 ?
               DepartmentRow.Layout.titleBottomPadding.singleTask
               : DepartmentRow.Layout.titleBottomPadding.manyTasks)
            + (department.tasks.count == 1 ?
               DepartmentSingleTaskView.Layout.rowHeight
               : (DepartmentManyTasksView.Layout.headerTopPadding + DepartmentManyTasksView.Layout.headerHeight + DepartmentManyTasksView.Layout.rowHeight * CGFloat(department.tasks.count)))
        }
        let rowSpacings = Layout.rowSpacing * CGFloat(viewModel.departments.count - 1)
        let footerHeight = DepartmentFooterView.Layout.height
        
        let spacerHeight = totalHeight
        - searchViewHeight
        - rowsHeight
        - rowSpacings
        - footerHeight
        
        return max(0, spacerHeight)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                
                VStack(spacing: 0) {
                    DepartmentSearchView(
                        searchButtonTapped: { keyword in
                            // TODO: - 검색 시작
                        },
                        resetSearchButtonTapped: {
                            // TODO: - 검색 종료
                        }
                    )
                    
                    Group {
                        VStack(spacing: Layout.rowSpacing) {
                            ForEach(viewModel.departments) { department in
                                DepartmentRow(department: department) {
                                    // TODO: - 전화번호 복사
                                }
                            }
                        }
                        
                        Spacer(minLength: spacerHeight(totalHeight: proxy.size.height))
                        
                        DepartmentFooterView(
                            updatedAt: viewModel.updatedAt,
                            reportButtonTapped: {}
                        )
                    }
                    .hideKeyboardWhenTapAround()
                }
                .padding(.horizontal, 22)
            }
            .background(Color.appColor(.newBackground))
            .onAppear {
                viewModel.execute(.viewDidAppear)
            }
        }
    }
}
