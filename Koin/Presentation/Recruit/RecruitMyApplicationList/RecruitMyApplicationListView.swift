//
//  RecruitMyApplicationListView.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import SwiftUI

struct RecruitMyApplicationListView: ActionBindableView {

    enum Action {
        case showFilterBottomSheet(
            filterState: RecruitMyApplicationFilter,
            onApplyTapped: ([FilterGroupModel]) -> Void
        )
        case showToast(message: String)
        case showRecruitData(id: Int)
        case showChat(recruitmentId: Int, chatRoomId: Int)
        case showAllRecruitList
    }

    // MARK: - Properties
    var sendAction: (Action) -> Void = { _ in }
    @State private var viewModel: RecruitMyApplicationListViewModel

    // MARK: - Initializer
    init(viewModel: RecruitMyApplicationListViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            RecruitMyApplicationListHeaderView(
                totalCount: viewModel.recruitList?.totalCount ?? 0,
                onFilterButtonTapped: {
                    sendAction(.showFilterBottomSheet(
                        filterState: viewModel.filterState,
                        onApplyTapped: { groupModels in
                            guard let filter = RecruitMyApplicationFilter(from: groupModels) else {
                                return
                            }
                            viewModel.execute(.updateFilter(filter))
                        }
                    ))
                }
            )
            .padding(.top, 20)
            .padding(.bottom, 12)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recruits) { recruit in
                        RecruitMyApplicationListRowView(
                            model: recruit,
                            onShowDetail: {
                                sendAction(.showRecruitData(id: recruit.id))
                            },
                            onShowChat: { chatRoomId in
                                sendAction(.showChat(recruitmentId: recruit.id, chatRoomId: chatRoomId))
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            loadNextPageIfNeeded(recruitId: recruit.id)
                        }
                    }
                }
                .animation(
                    .spring(duration: 0.3),
                    value: viewModel.recruits.map(\.id)
                )
                .frame(maxWidth: .infinity)

                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 24)
                    .padding(.top, 12)
                    .isHidden(!(viewModel.recruitList?.hasNextPage ?? false && viewModel.isLoading))

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 22)
            .background {
                RecruitMyApplicationListEmptyView {
                    sendAction(.showAllRecruitList)
                }
                .isHidden(!(viewModel.recruitList?.isEmpty ?? true) || viewModel.isLoading)
            }
            .refreshable {
                viewModel.execute(.refresh)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.appColor(.newBackground))
        .onFirstAppear {
            viewModel.execute(.onFirstAppear)
        }
        .onChange(of: viewModel.errorMessage) {
            guard let message = viewModel.errorMessage else {
                return
            }
            sendAction(.showToast(message: message))
            viewModel.execute(.didShowToast)
        }
    }
}

extension RecruitMyApplicationListView {
    private func loadNextPageIfNeeded(recruitId: Int) {
        guard viewModel.recruits.last?.id == recruitId,
              viewModel.recruitList?.hasNextPage ?? false,
              !viewModel.isLoading else {
            return
        }
        viewModel.execute(.loadNextPage)
    }
}
