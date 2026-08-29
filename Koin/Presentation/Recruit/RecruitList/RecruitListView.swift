//
//  RecruitListView.swift
//  koin
//
//  Created by 홍기정 on 8/28/26.
//

import SwiftUI

struct RecruitListView: ActionBindableView {
    enum Action {
        case configureRightButtons(hasUnreadNotification: Bool)
        case showFilterBottomSheet(filterState: RecruitListFilter, onApplyTapped: ([FilterGroupModel])->Void)
        case showToast(message: String)
        case showLoginToast
        case showRecruitPost
    }
    
    // MARK: - Properties
    var sendAction: ((Action) -> Void) = { _ in }
    @State private var viewModel: RecruitListViewModel
    
    // MARK: - Initializer
    init(viewModel: RecruitListViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            RecruitListHeaderView(
                filterState: viewModel.filterState,
                onSearchTapped: { keyword in
                    viewModel.execute(.updateFilter(keyword: keyword))
                },
                onFilterButtonTapped: {
                    sendAction(.showFilterBottomSheet(
                        filterState: viewModel.filterState,
                        onApplyTapped: { filterGroups in
                            viewModel.execute(.updateFilter(filterState: RecruitListFilter(from: filterGroups)))
                        }
                    ))
                },
                onFilterDeleted: { rawValue in
                    viewModel.execute(.deleteFilter(rawvalue: rawValue))
                }
            )
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
            
            ScrollView {
                Text("전체(\(viewModel.recruitList?.totalCount ?? 0))")
                    .font(.appFont(.pretendardRegular, size: 12))
                    .foregroundStyle(Color.appColor(.neutral500))
                    .frame(height: 19)
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 12, trailing: 0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recruitList?.recruits ?? []) { row in
                        Button {
                            
                        } label: {
                            RecruitListRowView(model: row)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)
                
                if viewModel.hasNextPage {
                    ProgressView()
                        .frame(maxWidth: .infinity, idealHeight: 77, alignment: .center)
                        .task {
                            viewModel.execute(.loadNextPage)
                        }
                        .isHidden(!viewModel.isLoading)
                    
                } else {
                    Spacer(minLength: 77)
                }
            }
            .padding(.horizontal, 22)
            .background {
                RecruitListEmptyView()
                    .isHidden(!viewModel.isEmpty)
            }
            .refreshable {
                viewModel.execute(.refresh)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.appColor(.newBackground))
        .overlay(alignment: .bottomTrailing) {
            postButton
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 23, trailing: 30))
        }
        .onFirstAppear {
            viewModel.execute(.viewDidAppear)
        }
        .onChange(of: viewModel.errorMessage) {
            if let message = viewModel.errorMessage {
                sendAction(.showToast(message: message))
                viewModel.execute(.didShowToast)
            }
        }
        .onChange(of: viewModel.hasUnreadNotification) {
            sendAction(.configureRightButtons(hasUnreadNotification: viewModel.hasUnreadNotification))
        }
        .hideKeyboardWhenTapAround()
    }
    
    @ViewBuilder
    private var postButton: some View {
        Button {
            UserDataManager.shared.isLoggedIn ? sendAction(.showRecruitPost) : sendAction(.showLoginToast)
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Text("모집하기")
                    .font(.appFont(.pretendardSemiBold, size: 16))
                    .foregroundStyle(Color.appColor(.neutral0))
                Image.appImage(asset: .recruitPencil)
            }
            .padding(.horizontal, 22)
            .frame(height: 43)
            .background(Color.appColor(.new400))
            .clipShape(RoundedRectangle(cornerRadius: 43/2))
        }
        .buttonStyle(.plain)
    }
}
