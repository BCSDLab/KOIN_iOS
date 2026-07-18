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
    }
    
    // MARK: - Layout
    enum Layout {
        static let horizontalPadding: CGFloat = 22
    }
    
    // MARK: - Properties
    @State var viewModel: DepartmentCategoryViewModel
    var sendAction: (Action) -> Void = { _ in }
    
    // MARK: - Initializer
    init(viewModel: DepartmentCategoryViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - SpacerHeight
    private func spacerHeight(totalHeight: CGFloat) -> CGFloat {
        let spacerHeight: CGFloat = totalHeight
            - DepartmentSearchView.Layout.topPadding
            - DepartmentSearchView.Layout.height
            - DepartmentSearchView.Layout.bottomPadding
            - DepartmentCategoryRow.Layout.height * CGFloat(viewModel.categorys.count)
            - DepartmentFooterView.Layout.height
        return max(0, spacerHeight)
    }
    
    // MARK: - Body
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
                        VStack(spacing: 0) {
                            ForEach(viewModel.categorys) { category in
                                DepartmentCategoryRow(category: category) { category in
                                    sendAction(.showDepartment(category: category))
                                }
                            }
                        }
                        .background(Color.appColor(.neutral0))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Spacer(minLength: spacerHeight(totalHeight: proxy.size.height))
                        
                        DepartmentFooterView(updatedAt: viewModel.updatedAt) {
                            // TODO: - 제보하기
                        }
                    }
                    .hideKeyboardWhenTapAround()
                }
                .padding(.horizontal, Layout.horizontalPadding)
            }
            .background(Color.appColor(.newBackground))
            .onAppear {
                viewModel.execute(.viewDidAppear)
            }
        }
    }
}
