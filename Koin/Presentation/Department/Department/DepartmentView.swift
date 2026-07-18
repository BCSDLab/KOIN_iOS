//
//  DepartmentView.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentView: ActionBindableView {

    // MARK: - Action
    enum Action {
        case showCopyToast
    }
    var sendAction: ((Action) -> Void) = { _ in }
    
    // MARK: - Layout
    enum Layout {
        static let horizontalPadding: CGFloat = 22
        static let textFieldBottomPadding: CGFloat = 40
        static let rowSpacing: CGFloat = 12
    }
    
    // MARK: - Properties
    @State var viewModel: DepartmentViewModel
    @State var isSearching: Bool = false
    
    // MARK: - Initializer
    init(viewModel: DepartmentViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - SpacerHeight
    private func spacerHeight(totalHeight: CGFloat) -> CGFloat {
        let departments = isSearching ? viewModel.searchingDepartments : viewModel.departments
        
        let searchViewHeight = DepartmentSearchView.Layout.topPadding
            + DepartmentSearchView.Layout.height
            + Layout.textFieldBottomPadding
        let rowsHeight: CGFloat = departments.reduce(0) { result, department in
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
        let rowSpacings = Layout.rowSpacing * CGFloat(departments.count - 1)
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
                            isSearching = true
                            viewModel.execute(.search(keyword))
                        },
                        resetSearchButtonTapped: {
                            isSearching = false
                            viewModel.execute(.endSearching)
                        }
                    )
                    
                    VStack(spacing: 0) {
                        Spacer(minLength: Layout.textFieldBottomPadding)
                        
                        VStack(spacing: Layout.rowSpacing) {
                            ForEach(isSearching ? viewModel.searchingDepartments : viewModel.departments) { department in
                                DepartmentRow(department: department) { phoneNumber in
                                    UIPasteboard.general.string = phoneNumber
                                    sendAction(.showCopyToast)
                                }
                            }
                        }
                        
                        Spacer(minLength: spacerHeight(totalHeight: proxy.size.height))
                        
                        DepartmentFooterView(
                            updatedAt: isSearching ? viewModel.searchingUpdatedAt : viewModel.updatedAt,
                            reportButtonTapped: {}
                        )
                    }
                    .hideKeyboardWhenTapAround()
                    .containerShape(.rect)
                    .overlay {
                        if isSearching && viewModel.searchingDepartments.isEmpty && !viewModel.isLoading {
                            DepartmentEmptyView()
                        }
                    }
                }
                .padding(.horizontal, 22)
            }
            .background(Color.appColor(.newBackground))
            .loadingOverlay(viewModel.isLoading)
            .onAppear {
                viewModel.execute(.viewDidAppear)
            }
        }
    }
}
