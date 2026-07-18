//
//  DepartmentCategoryView.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentCategoryView: ActionBindableView {
    
    // MARK: - Action
    enum Action {
        case showDepartment(category: DepartmentCategory)
        case showCopyToast
    }
    
    // MARK: - Layout
    enum Layout {
        static let horizontalPadding: CGFloat = 22
        static let textFieldBottomPadding: CGFloat = 40
        static let searchingRowSpacing: CGFloat = 12
    }
    
    // MARK: - Properties
    @State var viewModel: DepartmentCategoryViewModel
    @State var isSearching: Bool = false
    var sendAction: (Action) -> Void = { _ in }
    
    // MARK: - Initializer
    init(viewModel: DepartmentCategoryViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - SpacerHeight
    private func spacerHeight(totalHeight: CGFloat) -> CGFloat {
        return isSearching ? searchingSpacerHeight(totalHeight: totalHeight) : notSearhcingSpacerHeight(totalHeight: totalHeight)
    }
    private func notSearhcingSpacerHeight(totalHeight: CGFloat) -> CGFloat {
        let spacerHeight: CGFloat = totalHeight
            - DepartmentSearchView.Layout.topPadding
            - DepartmentSearchView.Layout.height
            - Layout.textFieldBottomPadding
            - DepartmentCategoryRow.Layout.height * CGFloat(viewModel.categorys.count)
            - DepartmentFooterView.Layout.height
        return max(0, spacerHeight)
    }
    private func searchingSpacerHeight(totalHeight: CGFloat) -> CGFloat {
        let searchViewHeight = DepartmentSearchView.Layout.topPadding
            + DepartmentSearchView.Layout.height
            + Layout.textFieldBottomPadding
        let rowsHeight: CGFloat = viewModel.searchingDepartments.reduce(0) { result, department in
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
        let rowSpacings = Layout.searchingRowSpacing * CGFloat(viewModel.searchingDepartments.count - 1)
        let footerHeight = DepartmentFooterView.Layout.height
        
        let spacerHeight = totalHeight
        - searchViewHeight
        - rowsHeight
        - rowSpacings
        - footerHeight
        
        return max(0, spacerHeight)
    }
    
    // MARK: - Body
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
                        
                        if isSearching {
                            VStack(spacing: Layout.searchingRowSpacing) {
                                ForEach(viewModel.searchingDepartments) { department in
                                    DepartmentRow(department: department) { phoneNumber in
                                        UIPasteboard.general.string = phoneNumber
                                        sendAction(.showCopyToast)
                                    }
                                }
                            }
                        } else {
                            VStack(spacing: 0) {
                                ForEach(viewModel.categorys) { category in
                                    DepartmentCategoryRow(category: category) { category in
                                        sendAction(.showDepartment(category: category))
                                    }
                                }
                            }
                            .background(Color.appColor(.neutral0))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        
                        Spacer(minLength: spacerHeight(totalHeight: proxy.size.height))
                        
                        DepartmentFooterView(updatedAt: viewModel.updatedAt) {
                            // TODO: - 제보하기
                        }
                    }
                    .hideKeyboardWhenTapAround()
                    .overlay {
                        if isSearching && viewModel.searchingDepartments.isEmpty && !viewModel.isLoading {
                            DepartmentEmptyView()
                        }
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
            }
            .background(Color.appColor(.newBackground))
            .loadingOverlay(viewModel.isLoading)
            .onAppear {
                viewModel.execute(.viewDidAppear)
            }
        }
    }
}
