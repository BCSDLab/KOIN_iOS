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
        static let rowSpacing: CGFloat = 12
    }
    
    // MARK: - Properties
    @State var viewModel: DepartmentViewModel
    @State var isSearching: Bool = false
    
    // MARK: - Initializer
    init(viewModel: DepartmentViewModel) {
        self.viewModel = viewModel
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
                        
                        VStack(spacing: Layout.rowSpacing) {
                            ForEach(isSearching ? viewModel.searchingDepartments : viewModel.departments) { department in
                                DepartmentRow(department: department) { phoneNumber in
                                    UIPasteboard.general.string = phoneNumber
                                    sendAction(.showCopyToast)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if !(isSearching && !viewModel.isLoading && viewModel.searchingDepartments.isEmpty) {
                            DepartmentFooterView(updatedAt: isSearching ? viewModel.searchingUpdatedAt : viewModel.updatedAt)
                        }
                    }
                    .hideKeyboardWhenTapAround()
                    .containerShape(.rect)
                }
                .frame(minHeight: proxy.size.height)
                .background {
                    if isSearching && !viewModel.isLoading && viewModel.searchingDepartments.isEmpty {
                        DepartmentEmptyView()
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
