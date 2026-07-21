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
                        
                        Spacer()
                    }
                    .hideKeyboardWhenTapAround()
                    .overlay {
                        if isSearching && viewModel.searchingDepartments.isEmpty && !viewModel.isLoading {
                            DepartmentEmptyView()
                        }
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .frame(minHeight: proxy.size.height)
            }
            .background(Color.appColor(.newBackground))
            .loadingOverlay(viewModel.isLoading)
            .onAppear {
                viewModel.execute(.viewDidAppear)
            }
        }
    }
}
